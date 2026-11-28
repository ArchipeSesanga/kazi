/**
 * Writes (overwrites) the config/moderation document.
 *
 * `autoApproveProviders: true` is a v1 product decision (no admin panel
 * yet): new providers are approved automatically by the
 * `onProviderWritten` Cloud Function instead of waiting on manual review.
 * Flip to false once the admin panel ships.
 *
 * Idempotent: safe to run multiple times.
 *
 * Usage: tsx seed-moderation.ts --project kazi-dev|kazi-prod
 */
import { initAdmin, parseArgs, db } from './_init.js';

const MODERATION = {
  autoApproveProviders: true,
};

async function main() {
  const { projectId } = parseArgs();
  initAdmin(projectId);
  const firestore = db();

  console.log(`Writing config/moderation → ${projectId} …`);
  await firestore.collection('config').doc('moderation').set(MODERATION);
  console.log(`✓ config/moderation written (autoApproveProviders=${MODERATION.autoApproveProviders}).`);
}

main().catch((err) => { console.error(err); process.exit(1); });
