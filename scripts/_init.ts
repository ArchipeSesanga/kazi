import * as admin from 'firebase-admin';
import { applicationDefault } from 'firebase-admin/app';

const PROJECT_MAP: Record<string, string> = {
  'kazi-dev': 'kazi-dev-8099c',
  'kazi-dev-8099c': 'kazi-dev-8099c',
  'kazi-prod': 'kazi-prod-d9c00',
  'kazi-prod-d9c00': 'kazi-prod-d9c00',
};

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

export function initAdmin(projectId: string): admin.app.App {
  if (admin.apps.length) return admin.apps[0]!;
  return admin.initializeApp({ credential: applicationDefault(), projectId });
}

export function db(): FirebaseFirestore.Firestore {
  return admin.firestore();
}
