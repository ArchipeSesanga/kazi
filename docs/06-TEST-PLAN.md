# Kazi — Test Plan & Quality Strategy

| | |
|---|---|
| **Version** | v1.0 |
| **Related** | [TDD](03-TDD.md) · [Coding standards](08-CODING-STANDARDS.md) · [Ops](09-DEVOPS-RELEASE.md) |

---

## 1. Test pyramid

| Level | Tooling | Scope | Gate |
|---|---|---|---|
| **Static** | `dart analyze` (zero warnings), `dart format --set-exit-if-changed`, `eslint`, `tsc --noEmit` | All code | Every PR |
| **Unit (Dart)** | `flutter_test`, `mocktail` | Models (JSON round-trip), utils (normalise, phone), controllers (with fake repositories) | Every PR |
| **Repository (Dart)** | `fake_cloud_firestore`, `firebase_auth_mocks` | Firestore mapping, query building, pagination | Every PR |
| **Widget** | `flutter_test` | Design-system widgets, each screen's states (loading/empty/error/data/offline) | Every PR |
| **Security rules** | `@firebase/rules-unit-testing` + Firestore/Storage emulators | Every rule branch, allow + deny | Every PR touching rules or data shape |
| **Functions** | `vitest` + emulators (`firebase emulators:exec`) | Triggers, callables, normalisation test vectors | Every PR touching `functions/` |
| **Integration (E2E)** | `integration_test` against emulators + `seed-demo` | Critical journeys (§3) | Nightly + before release |
| **Manual / exploratory** | Physical low-end Android device | Performance, offline, real SMS, WhatsApp hand-off | Before each release |

**Coverage targets:** controllers and utils ≥ 80% lines; repositories ≥ 70%; every rule path tested; every callable has success + failure tests.

## 2. Mandatory test cases by area

### 2.1 Normalisation (Dart + TS, identical vectors)
- Test vectors from TDD §8.1.
- Empty string → `[]`; stop words only → `[]`; length cap 200; prefixes start at 2 chars and cap at 15.

### 2.2 Phone utils
- `0812345678`, `812345678`, `+243812345678`, `00243812345678` → `+243812345678`.
- Invalid: too short, letters, a landline when mobile is required.
- WhatsApp URL generation encodes accents and `&`.

### 2.3 Security rules (minimum)

| Path | Allow | Deny |
|---|---|---|
| users create | owner whose `phone` equals the verified token phone (E.164), optional `email` | phone ≠ token phone; empty phone; email/password account with no verified phone; extra field `isProvider`; status `suspended` |
| users update | name change | changing `phone`, `status`, `isProvider` |
| providers create | exact `ProviderProfile.toCreateMap()` payload with pending status and zeroed server fields | extra keys; `verified: true`; `status: approved`; `ratingAvg: 5`; 4 categories |
| providers update | bio change; rejected → pending | pending → approved; owner when suspended; set `verified` |
| providers read | approved by guest; pending by owner | pending by another user |
| listings create | approved provider, valid | `visible: true` included; 7 photos; `priceType: quote` with amount; provider with listingCount 10 (denied) vs 9 (allowed) against `config/limits`; limit raised/lowered via `config/limits`; missing `config/limits` falls back to 10; other user's providerId |
| listings read | visible by guest; draft by owner | draft by another user; query without `visible == true` by guest |
| reviews create | after contact (`reviews.rules.test.ts`) | without contact (and a contact with another provider); self-review; rating 0 / 6 / 3.5; text 301 chars; doc id ≠ uid (a second review); guest; user being deleted |
| reviews update / delete | author edits rating + text, deletes; moderator deletes | other user, the provider; changing `authorUid`, `createdAt` |
| providers `rating*` | — | owner, other user or moderator writing `ratingAvg`, `ratingCount`, `ratingSum` or `ratingScore`; create with a rating or `ratingScore` |
| categories write | — | any client, admin and moderator included (callable / seed only) |
| contacts create | `uid_pid` id | wrong id format; self-contact |
| reports create | none from clients (callable only); moderator read | any client write, verified phone or not; `reportQuota` access; reading reports as user |
| verificationRequests | read own | write by client |
| storage media | owner image < 2 MB | other user's folder; PDF; 3 MB; write into `thumbs/` |
| storage private | owner create | read by anyone; overwrite |

### 2.4 Functions
- `onReviewWritten` (`ratings.emulator.test.ts`, `ratings.test.ts`): add, edit (sum moves, count does not), delete, last review deleted → 0 and score 4.0; anonymising move (delete + create, same rating) is net zero; duplicate delivery changes nothing; never creates a provider; malformed rating ignored; score formula `(4.0·5 + sum)/(5 + count)`.
- Categories (`categories.test.ts`, `seedCategories.emulator.test.ts`): taxonomy valid (slugs, 4–8 fr/en synonyms, ln/sw empty, 8 featured, `autres` last); every synonym survives the keyword cap; "plombier" finds Plomberie; seed idempotent, keeps `listingCount`, rename keeps the id, retired ≠ deleted, dev wipe + legacy id remap.
- `onListingWritten`: over-limit → hidden `over_limit`, doc and photos kept, restored when a slot frees; only active + paused count; no write loop (self-triggered run is a no-op); visibility matrix (status × providerStatus × moderation); keywords generated; phone number in title → hidden; photo removal deletes Storage objects; listingCount maintained.
- `onProviderWritten`: name change propagates to all listings; suspension hides all listings; no write loop (function invocation count stable).
- `onContactWritten`: cooldown respected.
- `submitReport`: creates, repeat = already reported (no quota), own/missing target, 10 per 24 h, per user, window rollover, concurrent calls.
- `onReportCreated`: third distinct report hides target; duplicate reporter can't count twice (deterministic id); provider → all listings hidden, provider stays approved; idempotent; other hide reasons untouched.
- Moderator callables: hide / restore (`over_limit` refused) / suspend / dismiss, report resolution, `adminLogs`, permission matrix (`canPerform`).
- `cleanupDraftListings`: only drafts older than 30 days, pagination, idempotent, counters untouched.
- `deleteAccount`: provider with listings, reviews and contacts → everything removed; reports anonymised; Auth user deleted.
- Admin callables: reject without claim, reject without App Check (in an emulator with enforcement on), log every action.

### 2.4a Operator tooling and legal consent
- `operatorDelete`: staff-only operator (admin or moderator; ordinary user, unknown email and falsy claims rejected), find by phone (Auth user, else profile, not found, ambiguous), plan counts, dry run changes nothing and writes no log, execute deletes like the app and logs without the phone number, a failed run is logged and a rerun finishes, bad phone/reason rejected first.
- Legal consent: the phone and profile-setup screens show the notice in FR and EN, the links open the `/fr|en/terms|privacy` pages, saving stores `termsVersion` and a server timestamp. The published pages carry the same version as `AppDefaults.termsVersion` and a last-updated and effective date; `AppDefaults.legalBaseUrl` is the only place the base URL lives.

### 2.4b Admin web app (`/admin`)
- `npm test` (Vitest + Testing Library): claims gate (admin and moderator stay, others signed out with a message, fail closed, session restored on reload), report grouping and ordering, error mapping, FR/EN key parity, the Reports page (loading, empty, load error + retry, each action with its confirm dialog, required suspend reason, error kept in the dialog, buttons disabled while working, restore disabled for `over_limit`, deleted target dismiss-only).
- Rules: the exact queue query (`status == open` ordered by `createdAt`) is allowed for admin and moderator and denied for a phone user and an email-only account.
- CI job `admin`: lint, typecheck, test, build.

### 2.5 Controllers (examples)
- `PhoneAuthController`: E.164 normalisation (+243 default), invalid number, send failures, wrong/expired/too-many code, resend cooldown (uses a fake repository modelled on Firebase test numbers; no real SMS). Router: the removed `/auth/email` route falls back to `/auth/phone`.
- Guards (`guards_test.dart`): the three access levels, provider and staff routes, loop-freedom.
- `SearchResultsController`: debounce; filter change resets pagination; client-side commune filter when keyword present; auto-fetch extra pages when the filtered result is short.
- `ListingFormController`: validation messages; quote clears amount; upload progress; publish sets `status active`; can't add a 7th photo.
- `ContactController`: guest → redirect to sign-in; signed in → records the contact once, then launches the URL.
- `WriteReviewController` / screen: no prior contact → "Contactez ce prestataire pour laisser un avis" and no form; contact with another provider does not count; own profile; signed out; 1–5 stars required, comment ≤ 300; publish, then edit (still one review); delete; failed write keeps the form.
- `RatingStars` / `RatingSummary` / `RatingInput`: 0, 1, 4.6, 5 stars (4.6 → 4½, 4.8 → 5); orange vs border colour; "4,8 (32 avis)" FR / "4.8 (32 reviews)" EN; "Nouveau" never "0,0"; Label style; semantics "Note 4,8 sur 5, 32 avis"; 44 px targets.
- Categories: `iconKey` fallback and every bundled key known; catalog reads the new shape and falls back to the bundled list; Home = 8 featured; onboarding picker max 3; empty category state opens the listing form with `?cat=`; FR/EN ARB parity (`arb_parity_test.dart`).

## 3. Critical user journeys (E2E)

| ID | Journey |
|---|---|
| J1 | App opens → picks French → sees onboarding → enters a phone number → confirms the OTP → completes profile setup → reaches the app |
| J2 | New user → becomes a provider (5 steps) → sees "En attente" → admin approves (callable in test) → provider creates listing with 2 photos → listing appears in search for its commune |
| J3 | Client who contacted provider → leaves 4-star review → provider rating shows 4,0 (1 avis) |
| J4 | Three users report a listing → listing disappears from search → admin un-hides it → visible again |
| J5 | Provider requests verification → admin approves → badge visible on cards and profile; files deleted |
| J6 | User deletes account → can no longer sign in to the same data; their review is gone; rating recalculated |
| J7 | Offline: open the app with airplane mode after one online session → home and last provider profile render from cache with the offline banner |

## 4. Non-functional testing

| Area | Method | Pass criteria |
|---|---|---|
| Cold start | Release build on a 2 GB RAM device (e.g. Android Go), `adb shell am start -W` | < 3 s |
| Scroll performance | Flutter DevTools performance overlay on the results list (50 items) | No janky frames > 5% |
| App size | `flutter build appbundle --analyze-size` | Per-device download ≤ 25 MB |
| Data usage | Fresh install, browse home + 1 category + 2 profiles; measure with Android data usage | ≤ 3 MB |
| Accessibility | TalkBack walk-through J1; text scale 1.3× screenshots | All actions reachable; no clipped text |
| Localisation | Switch FR ↔ EN on every screen | No missing keys (CI check), no overflow |

## 5. Test data

- `scripts/seed-demo.ts` creates deterministic demo data (fixed IDs) for emulators and `kazi-dev`.
- Auth emulator test phone numbers: `+243810000001`–`+243810000020`, code `123456`. Dev project and emulator only; **do not configure the numbers above in `kazi-prod`.** The only exception is **one** dedicated test number for the Google Play reviewer (Play requires a working login), added just for the review period and **removed as soon as the review is done**; it is never reused for anything else. CI never sends real SMS.
- **Never** seed demo data in `kazi-prod`.

## 6. Bug severity

| Severity | Definition | Release impact |
|---|---|---|
| S1 | Data leak, security hole, crash on launch, can't contact providers | Blocks release; hotfix |
| S2 | Core journey broken for some users; wrong rating/visibility | Blocks release |
| S3 | Non-core feature broken; visual defects on main screens | Fix in next sprint |
| S4 | Cosmetic | Backlog |
