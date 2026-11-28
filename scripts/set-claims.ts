/**
 * Grants or removes the staff claims `admin` / `moderator` on a user.
 *
 *   npx tsx set-claims.ts --project kazi-dev  --email staff@kazi.test --role moderator
 *   npx tsx set-claims.ts --project kazi-prod --uid <uid> --role admin --confirm-prod
 *   npx tsx set-claims.ts --project kazi-dev  --uid <uid> --role none      # remove
 *
 * Needs Application Default Credentials (`gcloud auth application-default login`
 * or GOOGLE_APPLICATION_CREDENTIALS). Other custom claims are preserved. The
 * user must sign in again (or their ID token must refresh) for it to apply.
 * Staff sign in with email/password to the admin web app; see docs/11.
 */
import * as admin from 'firebase-admin';
import { initAdmin, parseArgs } from './_init';

const ROLES = ['admin', 'moderator', 'none'] as const;
type Role = (typeof ROLES)[number];

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(`--${name}`);
  return i === -1 ? undefined : process.argv[i + 1];
}

function fail(message: string): never {
  console.error(message);
  process.exit(1);
}

/** Claims after applying [role]: only `admin` / `moderator` are touched. */
export function applyRole(existing: Record<string, unknown>, role: Role): Record<string, unknown> {
  const { admin: _a, moderator: _m, ...rest } = existing;
  void _a;
  void _m;
  if (role === 'admin') return { ...rest, admin: true };
  if (role === 'moderator') return { ...rest, moderator: true };
  return rest;
}

async function main(): Promise<void> {
  const { projectId, isProd } = parseArgs();
  const role = arg('role') as Role | undefined;
  if (!role || !ROLES.includes(role)) fail(`--role must be one of: ${ROLES.join(', ')}`);
  const uid = arg('uid');
  const email = arg('email');
  if (!uid === !email) fail('Give exactly one of --uid or --email.');
  if (isProd && !process.argv.includes('--confirm-prod')) {
    fail('Refusing to change claims in kazi-prod without --confirm-prod.');
  }

  initAdmin(projectId);
  const auth = admin.auth();
  const user = uid ? await auth.getUser(uid) : await auth.getUserByEmail(email!);
  const next = applyRole(user.customClaims ?? {}, role);
  await auth.setCustomUserClaims(user.uid, next);
  console.log(`${projectId}: ${user.email ?? user.uid} -> ${role === 'none' ? 'no staff role' : role}`);
  console.log('They must sign in again for the change to apply.');
}

if (require.main === module) {
  main().catch((e) => fail(String(e)));
}
