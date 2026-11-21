# Kazi — Production deploy runbook

| | |
|---|---|
| **Applies to** | `kazi-prod-d9c00`, package `com.arkepios.kazi` |
| **Pipeline** | [`.github/workflows/release.yml`](../.github/workflows/release.yml) (tag `vX.Y.Z`) |
| **Related** | [DevOps & Release](09-DEVOPS-RELEASE.md), [Security & Privacy](05-SECURITY-PRIVACY.md), [Test plan](06-TEST-PLAN.md) |

Rules that never bend: **indexes → rules → functions → hosting → app**; never seed demo data in prod; **no test phone numbers in prod, except one dedicated Google Play reviewer number added for the review period and removed right after**; no keystore, service-account key or `.env` in git.

---

## A. One-time setup (before the first release)

### A1. Firebase console, `kazi-prod`
- [ ] Blaze plan; budget alerts $25 / $50 / $100.
- [ ] **Auth → Sign-in method:** enable **Phone** and **Email/Password** (Email/Password is for staff accounts only; consumers can't use it, see TDD §5).
- [ ] **Auth → Settings → SMS region policy:** allow `CD` (+243) and the countries you expect.
- [ ] **Auth → Phone numbers for testing:** leave **empty** (Play reviewer number: see §D).
- [ ] **Project settings → Android app `com.arkepios.kazi`:** add SHA-1 and SHA-256 of the **upload key** and of the **Play app signing key** (after the first upload; Play Console → Setup → App signing).
- [ ] **App Check:** register the Android app with **Play Integrity**; keep **monitor** mode until the beta works, then enforce (KZ-106).
- [ ] Google Cloud: enable **Play Integrity API** and **Identity Toolkit API**; check the Cloud Functions region is `africa-south1` (scheduled functions run in `europe-west1`, see `config.ts`).
- [ ] Firestore in `africa-south1`, Storage bucket, **Resize Images** extension (TDD §7).
- [ ] Remote Config keys from TDD §3.3 (`min_supported_build`, `maintenance`, `store_url`, …).
- [ ] Analytics retention 14 months; Crashlytics enabled.
- [ ] Hosting site `kazi-prod-d9c00` exists (target `web`, mapped in `.firebaserc`).
- [ ] Admin app: `firebase hosting:sites:create <admin-site-id> --project kazi-prod-d9c00`, then `firebase target:apply hosting admin <admin-site-id> --project kazi-prod-d9c00`; build with `cd admin && npm ci && npm run build` and deploy with `firebase deploy --only hosting:admin --project prod` (not part of `release.yml` yet). Add the admin domain to Auth → Settings → Authorized domains.
- [ ] Seed reference data once: `cd scripts && npx tsx seed-categories.ts --project kazi-prod` and `npx tsx seed-locations.ts --project kazi-prod` (read each script first; **never** `seed-demo.ts`, it refuses prod anyway).
- [ ] First admin: create an email/password user in the console, then `cd scripts && npx tsx set-claims.ts --project kazi-prod --email <email> --role admin --confirm-prod` (Application Default Credentials or a service-account key kept outside git). Moderators: `--role moderator`. The user must sign in again. The admin app only lets `admin` / `moderator` stay signed in.

### A2. Legal pages
- [ ] Replace the placeholders in `web/public/**` (`{{LEGAL_ENTITY}}`, `{{SUPPORT_EMAIL}}`, `{{SUPPORT_WHATSAPP}}`). `scripts/check-legal-placeholders.sh` fails the release while any remain.
- [ ] Have a lawyer review Terms and Privacy (Code du numérique, RDC). Bump the version string in the pages and `AppDefaults.termsVersion` together when the text changes.
- [ ] Set `AppDefaults.legalBaseUrl` to your final domain when you have one.

### A3. Signing and GitHub
1. Create the upload keystore **once**, store it offline in two places:
   ```bash
   keytool -genkeypair -v -keystore kazi-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Repository **secrets**: `ANDROID_KEYSTORE_BASE64` (`base64 -i kazi-upload.jks | pbcopy`), `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `PLAY_SERVICE_ACCOUNT_JSON` (Play Console → API access, release-manager role on this app only), `FIREBASE_SERVICE_ACCOUNT_PROD` (a service account with only the deploy roles: Firebase Admin is the simplest; narrow later).
3. Repository **variable** `UPLOAD_CERT_SHA256`: the upload certificate's SHA-256 (`keytool -list -v -keystore kazi-upload.jks`). The workflow refuses a bundle signed with anything else.
4. **Environment `production`** (Settings → Environments): add yourself as a **required reviewer**. The backend deploy waits for your approval.
5. Local signed builds: `android/key.properties` (git-ignored) with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.

### A4. Play Console
- [ ] App created (`com.arkepios.kazi`), Play App Signing on, store listing FR + EN (see 09 §5).
- [ ] Privacy-policy URL: `https://<domain>/fr/privacy`. **Account-deletion URL:** `https://<domain>/delete-account`. Data-safety form consistent with Security & Privacy §2.
- [ ] Internal testing track with your testers. For app access ("login required"), see §D.

---

## B. Each release

1. **Freeze.** All stories for the release are *done* on the status board; CI green on `main`; no open S1/S2 bugs.
2. **Dry run on `kazi-dev`.** Deploy the same commit to dev and run the smoke journeys J1–J3 (Test plan §3) on a real device with a real SMS.
3. **Bump** `version:` in `pubspec.yaml` (`X.Y.Z+1`; CI sets the build number from the run) and update `CHANGELOG.md`.
4. **Tag:** `git tag vX.Y.Z && git push origin vX.Y.Z`.
5. The workflow runs: **verify** (tag = pubspec version, no legal placeholders, ARB parity, analyze, tests, functions lint/build/tests) → **build** the signed App Bundle and check its certificate → **deploy-backend** *waits for your approval* → **publish-play** uploads the bundle to the **internal** track as a **draft**.
6. **Approve** the backend deploy. It runs: indexes → rules (Firestore + Storage) → functions one at a time → Hosting `web`. New indexes can take minutes to build; for a release that adds an index *and* the code that needs it, deploy the index one release earlier when you can.
7. **Smoke test** the internal build on a real device (J1: phone sign-in with a real SMS; J2 contact a provider; J3 report a listing; delete a throwaway account).
8. **Promote** in Play Console: internal → closed testing → production with a staged rollout 10 % → 50 % → 100 % over about 3 days, watching Crashlytics and the Functions error rate.

## C. Verification after the deploy
- `firebase functions:list --project prod` shows every name printed by `node scripts/function-names.mjs`.
- Hosting: `/fr/terms`, `/en/privacy`, `/delete-account` open and show your entity and contact details, no `{{…}}`.
- Rules: a signed-in phone user reads categories; an unauthenticated request does not (Firebase console Rules playground).
- Auth: **no test phone numbers** listed (except the Play reviewer number during review).
- Crashlytics shows the new version; budget alerts active.

## D. The Play reviewer test account
Google's reviewers must be able to sign in. The only allowed exception to "no test numbers in prod":
1. Console → Auth → Phone → **Phone numbers for testing**: add **one** number you control and a 6-digit code.
2. Give those two values to Google in Play Console → App content → **App access**.
3. **Remove the number as soon as the review is approved.** Put a reminder on the review date; treat a forgotten number like a leaked password.

## E. Rollback
- **App:** halt the staged rollout in Play Console; fix forward with a new tag.
- **Functions / rules:** `git checkout vX.Y.(Z-1)` then `npm --prefix functions ci`, and redeploy the previous version with the same `firebase deploy` commands the workflow uses (functions one at a time, then rules). Do not roll back Firestore indexes that newer clients use.
- **Hosting:** Firebase console → Hosting → Release history → roll back.
- **Data:** Firestore PITR is on in `kazi-prod`; restoring is a deliberate, manual operation.

## F. Secrets hygiene
Rotate `FIREBASE_SERVICE_ACCOUNT_PROD` and `PLAY_SERVICE_ACCOUNT_JSON` when someone with access leaves. If the upload key leaks, Play can reset it (Play Console → App signing → Request upload key reset); the app-signing key stays with Google.
