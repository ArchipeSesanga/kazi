# Kazi — DevOps, Environments & Release

| | |
|---|---|
| **Version** | v1.0 |
| **Related** | [ADD](02-ADD.md) §8 · [Test plan](06-TEST-PLAN.md) |

---

## 1. One-time setup checklist

1. Create Firebase projects **`kazi-dev`** and **`kazi-prod`**; upgrade both to **Blaze** (needed for Cloud Storage default buckets, Functions and Phone Auth SMS beyond the free allowance). Set **budget alerts** in Google Cloud Billing: $25, $50, $100.
2. Firestore: Native mode, location **`africa-south1`**. This can't be changed later.
3. Storage: default bucket in the same region if offered; enable the **Resize Images** extension (`storage-resize-images`) with: sizes `200x200,800x800`, format `webp`, paths `/media`, keep originals, cache-control `public, max-age=31536000`.
4. Auth: enable **Phone** (users) and **Email/Password** (admins only, no public sign-up UI). Set the **SMS region policy** to allow `CD` and the countries you expect. Add test phone numbers for dev.
5. App Check: register the Android app with **Play Integrity** (SHA-256 of the upload key and of the Play app signing key) and web with **reCAPTCHA Enterprise**. Enforce for Firestore, Storage, Functions and Auth once the clients ship tokens (start in monitor mode during beta).
6. FCM: Android notification channel `kazi_default` created in the app.
7. Remote Config: create the keys from TDD §3.3 in both projects.
8. Analytics: data retention 14 months; enable Crashlytics.
9. Hosting targets: `admin` (admin panel) and `web` (legal pages, `/delete-account`, `/p/:id` share landing + Android App Links `assetlinks.json`).
10. Run `scripts/seed-categories.ts` and `scripts/seed-locations.ts` against both projects.
11. Create the first admin: create an email/password user in the console, then run `scripts/set-claims.ts --project kazi-prod --uid <uid> --role superAdmin` with a service account key stored **only** on your machine (never in git).
12. `flutterfire configure` for each flavor → `firebase_options_dev.dart` / `firebase_options_prod.dart`.

## 2. Local development

```bash
# Prerequisites: Flutter stable, Node 22, Firebase CLI, Java 17
firebase use kazi-dev
cd functions && npm ci && npm run build && cd ..
firebase emulators:start --import=./.emulator-data --export-on-exit
npx ts-node scripts/seed-demo.ts --emulator
flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev --dart-define=USE_EMULATORS=true
# Admin panel
flutter run -d chrome -t lib/main_admin.dart --dart-define=FLAVOR=dev --dart-define=USE_EMULATORS=true
```

Android emulator → host emulators: use `10.0.2.2`; physical device: use your machine's LAN IP (`--dart-define=EMULATOR_HOST=192.168.x.x`).

## 3. CI/CD (GitHub Actions)

| Workflow | Trigger | Steps |
|---|---|---|
| `ci.yml` | PR, push to `main` | Flutter: pub get → format check → analyze → `flutter test --coverage` → ARB key parity check. Functions: `npm ci` → lint → build → `firebase emulators:exec "npm test"` (rules + functions tests) |
| `deploy-dev.yml` | push to `main` | Deploy rules, indexes, functions and the admin (hosting) to `kazi-dev`; build dev APK and upload to Firebase App Distribution (testers group) |
| `release.yml` | tag `v*.*.*` | Deploy rules/indexes/functions/hosting to `kazi-prod`; build prod **App Bundle** signed with the upload key (from GitHub secrets); upload to Google Play **internal** track via `r0adkll/upload-google-play` or Fastlane |

Secrets (GitHub): `FIREBASE_SERVICE_ACCOUNT_DEV`, `FIREBASE_SERVICE_ACCOUNT_PROD` (least-privilege deploy roles), `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD`, `PLAY_SERVICE_ACCOUNT_JSON`.

Deploy order matters: **indexes → rules → functions → hosting → app**. New indexes can take minutes to build; deploy them in an earlier release than the code that needs them when possible.

## 4. Release process

1. Freeze: all stories in the release are Done; CI green on `main`.
2. Bump `version` in `pubspec.yaml`; update `CHANGELOG.md`.
3. Tag `vX.Y.Z` → `release.yml` deploys backend to prod and uploads to the **internal** track.
4. Smoke test on internal track (J1, J2, J3 from the test plan) on a real device with a real SMS.
5. Promote: internal → **closed testing** (beta) → **production** with staged rollout 10% → 50% → 100% over ~3 days, watching Crashlytics.
6. Use the Remote Config `min_supported_build` only for breaking backend changes.

**Rollback:** halt the Play staged rollout; redeploy previous functions/rules from the previous tag (`git checkout vX.Y.(Z-1) && firebase deploy --only functions,firestore:rules`); never roll back Firestore indexes that newer clients rely on.

## 5. Google Play launch checklist

- [ ] Developer account (organisation account recommended, matching the legal entity).
- [ ] App name "Kazi", short/long descriptions in French and English, screenshots (phone), feature graphic, icon 512 px.
- [ ] Privacy policy URL; **account deletion URL** (`/delete-account`).
- [ ] Data safety form (matches [Security & Privacy](05-SECURITY-PRIVACY.md) §2).
- [ ] Content rating questionnaire; target audience 18+ (user-generated content, contact with strangers).
- [ ] UGC policy compliance: reporting, blocking and moderation in place (F-42, F-44, admin queues).
- [ ] Closed testing requirement for new personal developer accounts (if applicable): enough testers for the required period before production access.
- [ ] Countries: DRC first; others optional.

## 6. Monitoring

| What | Where | Alert |
|---|---|---|
| Crashes | Crashlytics | Velocity alerts on; crash-free < 99.5% |
| Function errors | Cloud Logging / Error Reporting | Email on new error types |
| Costs | Cloud Billing budgets | $25 / $50 / $100 |
| SMS volume | Firebase Auth usage | Spike > 3× daily average → investigate SMS fraud |
| Moderation backlog | Admin dashboard counts | Pending providers > 20 or oldest > 24 h |

## 7. Backups

- Enable Firestore **point-in-time recovery** (PITR) on `kazi-prod`.
- Weekly scheduled export (Cloud Scheduler → `firestore export`) to a separate bucket with 30-day lifecycle.
