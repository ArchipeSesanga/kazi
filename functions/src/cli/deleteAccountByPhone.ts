/* eslint-disable no-console */
// Operator CLI. Run through scripts/delete-account.ts (see docs/11 §G):
//   cd scripts && npx tsx delete-account.ts --project kazi-dev --phone +243812345678 \
//     --operator staff@example.com --reason "ticket 123"            (dry run)
//   ... add --execute (and --confirm-prod for kazi-prod) to delete.
const PROJECTS: Record<string, string> = {
  "kazi-dev": "kazi-dev-8099c",
  "kazi-dev-8099c": "kazi-dev-8099c",
  "kazi-prod": "kazi-prod-d9c00",
  "kazi-prod-d9c00": "kazi-prod-d9c00",
};

const arg = (name: string): string | undefined => {
  const i = process.argv.indexOf(`--${name}`);
  return i === -1 ? undefined : process.argv[i + 1];
};
const flag = (name: string) => process.argv.includes(`--${name}`);
const fail = (message: string): never => {
  console.error(message);
  process.exit(1);
};

async function main(): Promise<void> {
  const projectArg = arg("project") ?? "";
  const projectId = PROJECTS[projectArg] ?? fail("Usage: --project kazi-dev|kazi-prod (see the header of this file).");
  const isProd = projectId === "kazi-prod-d9c00";
  const execute = flag("execute");
  const phone = arg("phone") ?? fail("--phone is required (E.164).");
  const operatorEmail = arg("operator") ?? fail("--operator <staff email> is required.");
  const reason = arg("reason") ?? fail("--reason is required (a ticket reference, no personal data).");
  if (execute && isProd && !flag("confirm-prod")) fail("Refusing to delete in kazi-prod without --confirm-prod.");

  // The admin SDK reads these when the shared helper initialises the app.
  const bucketName = arg("bucket") ?? `${projectId}.firebasestorage.app`;
  process.env.GOOGLE_CLOUD_PROJECT = projectId;
  process.env.GCLOUD_PROJECT = projectId;
  process.env.FIREBASE_CONFIG = JSON.stringify({ projectId, storageBucket: bucketName });

  const [{ getAuth }, { getFirestore }, { getStorage }, op] = await Promise.all([
    import("firebase-admin/auth"),
    import("firebase-admin/firestore"),
    import("firebase-admin/storage"),
    import("../lib/operatorDelete.js"),
  ]);
  await import("../lib/firebaseAdmin.js");

  const auth = getAuth();
  const bucket = getStorage().bucket();
  const notFound = (e: unknown) => (e as { code?: string }).code === "auth/user-not-found";
  const lookup: import("../lib/operatorDelete.js").AccountLookup = {
    userByPhone: async (e164) => {
      try {
        return { uid: (await auth.getUserByPhoneNumber(e164)).uid };
      } catch (e) {
        if (notFound(e)) return null;
        throw e;
      }
    },
    userByEmail: async (email) => {
      try {
        const u = await auth.getUserByEmail(email);
        return { uid: u.uid, claims: (u.customClaims ?? {}) as Record<string, unknown> };
      } catch (e) {
        if (notFound(e)) return null;
        throw e;
      }
    },
  };

  const result = await op.operatorDeleteAccount(
    getFirestore(),
    lookup,
    {
      deleteStoragePrefix: async (prefix) => {
        await bucket.deleteFiles({ prefix, force: true });
      },
      deleteAuthUser: async (uid) => {
        try {
          await auth.deleteUser(uid);
        } catch (e) {
          if (!notFound(e)) throw e;
        }
      },
    },
    {
      phone,
      operatorEmail,
      reason,
      execute,
      countStorage: async (prefix) => (await bucket.getFiles({ prefix, maxResults: 1000 }))[0].length,
    },
  );

  console.log(`${projectId}: account ${result.uid} (found via ${result.via})`);
  console.log(JSON.stringify(result.plan, null, 2));
  if (result.dryRun) {
    console.log("\nDRY RUN: nothing was changed. Add --execute to delete.");
  } else {
    console.log("\nDELETED. Counts:", JSON.stringify(result.report));
    console.log("An adminLogs entry was written.");
  }
}

main().catch((e) => {
  const code = (e as { code?: string }).code;
  console.error(code ? `${code}: ${(e as Error).message}` : String(e));
  process.exit(1);
});
