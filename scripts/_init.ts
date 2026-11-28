import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import * as admin from 'firebase-admin';
import { applicationDefault } from 'firebase-admin/app';

const PROJECT_MAP: Record<string, string> = {
  'kazi-dev': 'kazi-dev-8099c',
  'kazi-dev-8099c': 'kazi-dev-8099c',
  'kazi-prod': 'kazi-prod-d9c00',
  'kazi-prod-d9c00': 'kazi-prod-d9c00',
};

// Public OAuth client of firebase-tools (not a secret).
const FIREBASE_CLI_CLIENT_ID = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const FIREBASE_CLI_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

const PROD_IDS = new Set(['kazi-prod', 'kazi-prod-d9c00']);

export function parseArgs(): { projectId: string; isProd: boolean } {
  const idx = process.argv.indexOf('--project');
  if (idx === -1 || !process.argv[idx + 1]) {
    console.error('Usage: tsx <script>.ts --project kazi-dev|kazi-prod');
    process.exit(1);
  }
  const arg = process.argv[idx + 1];
  const projectId = PROJECT_MAP[arg];
  if (!projectId) {
    console.error(`Unknown project "${arg}". Use kazi-dev or kazi-prod.`);
    process.exit(1);
  }
  return { projectId, isProd: PROD_IDS.has(arg) };
}

function hasApplicationDefaultCredentials(): boolean {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) return true;
  const adcPath = path.join(
    process.env.HOME || process.env.USERPROFILE || '',
    '.config', 'gcloud', 'application_default_credentials.json',
  );
  return fs.existsSync(adcPath);
}

export function initAdmin(projectId: string): admin.app.App {
  if (admin.apps.length) return admin.apps[0]!;
  if (hasApplicationDefaultCredentials()) {
    return admin.initializeApp({ credential: applicationDefault(), projectId });
  }
  // No gcloud ADC: reuse the `firebase login` session (same account the CLI deploys with).
  const refreshToken = getFirebaseCliRefreshToken();
  if (!refreshToken) {
    console.error(
      'No credentials found.\n' +
      'Run `firebase login` (or `gcloud auth application-default login`) and retry.',
    );
    process.exit(1);
  }
  // Firestore only accepts application-default style credentials, so hand it the
  // CLI session as an `authorized_user` file (0600, deleted when the script ends).
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'kazi-seed-'));
  const file = path.join(dir, 'adc.json');
  fs.writeFileSync(
    file,
    JSON.stringify({
      type: 'authorized_user',
      client_id: FIREBASE_CLI_CLIENT_ID,
      client_secret: FIREBASE_CLI_CLIENT_SECRET,
      refresh_token: refreshToken,
    }),
    { mode: 0o600 },
  );
  process.on('exit', () => fs.rmSync(dir, { recursive: true, force: true }));
  process.env.GOOGLE_APPLICATION_CREDENTIALS = file;
  return admin.initializeApp({ credential: applicationDefault(), projectId });
}

export function db(): FirebaseFirestore.Firestore {
  return admin.firestore();
}

// ── REST API helpers (uses Firebase CLI token, no ADC needed) ────────────────

function getFirebaseCliRefreshToken(): string | null {
  try {
    const Configstore =
      require('/opt/homebrew/lib/node_modules/firebase-tools/node_modules/configstore');
    const store = new Configstore('firebase-tools');
    const tokens = store.get('tokens');
    return tokens?.refresh_token ?? null;
  } catch {
    return null;
  }
}

async function getAccessToken(): Promise<string> {
  const refreshToken = getFirebaseCliRefreshToken();
  if (!refreshToken) {
    throw new Error('No Firebase CLI credentials. Run `firebase login` first.');
  }
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: FIREBASE_CLI_CLIENT_ID,
      client_secret: FIREBASE_CLI_CLIENT_SECRET,
    }),
  });
  if (!res.ok) throw new Error(`Token exchange failed: ${res.status} ${await res.text()}`);
  const data = await res.json() as { access_token: string };
  return data.access_token;
}

const FIRESTORE_BASE = 'https://firestore.googleapis.com/v1';

function toFirestoreValue(v: unknown): Record<string, unknown> {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: `${v}` } : { doubleValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toFirestoreValue) } };
  if (typeof v === 'object') {
    const fields: Record<string, unknown> = {};
    for (const [k, val] of Object.entries(v as Record<string, unknown>)) {
      fields[k] = toFirestoreValue(val);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(v) };
}

function toFirestoreFields(obj: Record<string, unknown>): Record<string, unknown> {
  const fields: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(obj)) {
    fields[k] = toFirestoreValue(v);
  }
  return fields;
}

export async function restBatchWrite(
  projectId: string,
  writes: { collection: string; docId: string; data: Record<string, unknown> }[],
): Promise<void> {
  const token = await getAccessToken();
  const dbPath = `projects/${projectId}/databases/(default)/documents`;

  // Firestore REST batchWrite supports max 500 writes per request
  for (let i = 0; i < writes.length; i += 500) {
    const batch = writes.slice(i, i + 500);
    const body = {
      writes: batch.map((w) => ({
        update: {
          name: `${dbPath}/${w.collection}/${w.docId}`,
          fields: toFirestoreFields(w.data),
        },
      })),
    };

    const res = await fetch(`${FIRESTORE_BASE}/${dbPath}:batchWrite`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      throw new Error(`batchWrite failed: ${res.status} ${await res.text()}`);
    }
  }
}

export async function restSetDocument(
  projectId: string,
  docPath: string,
  data: Record<string, unknown>,
): Promise<void> {
  const token = await getAccessToken();
  const dbPath = `projects/${projectId}/databases/(default)/documents`;
  const res = await fetch(`${FIRESTORE_BASE}/${dbPath}/${docPath}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: toFirestoreFields(data) }),
  });
  if (!res.ok) {
    throw new Error(`setDocument failed: ${res.status} ${await res.text()}`);
  }
}
