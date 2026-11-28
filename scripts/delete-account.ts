/**
 * Operator tool: delete an account on request (privacy request by email or
 * WhatsApp). Staff only, dry run unless --execute, writes adminLogs.
 *
 *   npx tsx delete-account.ts --project kazi-dev --phone +243812345678 \
 *       --operator staff@example.com --reason "ticket-123"
 *   npx tsx delete-account.ts ... --execute [--confirm-prod]
 *
 * The logic lives in functions/src/lib/operatorDelete.ts and reuses the same
 * `deleteAccountData` as the app's deleteAccount callable. See docs/11 §G.
 */
import '../functions/src/cli/deleteAccountByPhone';
