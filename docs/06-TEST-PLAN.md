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
| users create | owner with matching phone | phone ≠ token phone; extra field `isProvider`; status `suspended` |
| users update | name change | changing `phone`, `status`, `isProvider` |
| providers create | pending with zeroed server fields | `verified: true`; `status: approved`; `ratingAvg: 5`; 4 categories |
| providers update | bio change; rejected → pending | pending → approved; owner when suspended; set `verified` |
| providers read | approved by guest; pending by owner | pending by another user |
| listings create | approved provider, valid | `visible: true` included; 7 photos; `priceType: quote` with amount; provider with listingCount 10; other user's providerId |
| listings read | visible by guest; draft by owner | draft by another user; query without `visible == true` by guest |
| reviews create | after contact | without contact; self-review; rating 6; doc id ≠ uid |
| contacts create | `uid_pid` id | wrong id format; self-contact |
| reports create | deterministic id | wrong id; status `actioned`; reading reports as user |
| verificationRequests | read own | write by client |
| storage media | owner image < 2 MB | other user's folder; PDF; 3 MB; write into `thumbs/` |
| storage private | owner create | read by anyone; overwrite |

### 2.4 Functions
- `onReviewWritten`: create (avg updates), update rating (delta), delete (count decrements), last review deleted → avg 0.
- `onListingWritten`: visibility matrix (status × providerStatus × moderation); keywords generated; phone number in title → hidden; photo removal deletes Storage objects; listingCount maintained.
- `onProviderWritten`: name change propagates to all listings; suspension hides all listings; no write loop (function invocation count stable).
- `onContactWritten`: cooldown respected.
- `onReportCreated`: third distinct report hides target; duplicate reporter can't count twice (deterministic id).
- `deleteAccount`: provider with listings, reviews and contacts → everything removed; reports anonymised; Auth user deleted.
- Admin callables: reject without claim, reject without App Check (in an emulator with enforcement on), log every action.

### 2.5 Controllers (examples)
- `AuthController`: code sent → wrong code → `otpInvalid` → resend disabled for 60 s.
- `SearchResultsController`: debounce; filter change resets pagination; client-side commune filter when keyword present; auto-fetch extra pages when the filtered result is short.
- `ListingFormController`: validation messages; quote clears amount; upload progress; publish sets `status active`; can't add a 7th photo.
- `ContactController`: guest → redirect to sign-in; signed in → records the contact once, then launches the URL.

## 3. Critical user journeys (E2E)

| ID | Journey |
|---|---|
| J1 | Guest opens app → picks French → browses category Plomberie → opens provider → taps WhatsApp → asked to sign in → OTP (emulator code) → profile setup → returns to provider → WhatsApp intent launched |
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
- Auth emulator test phone numbers: `+243810000001`–`+243810000020`, code `123456`.
- **Never** seed demo data in `kazi-prod`.

## 6. Bug severity

| Severity | Definition | Release impact |
|---|---|---|
| S1 | Data leak, security hole, crash on launch, can't contact providers | Blocks release; hotfix |
| S2 | Core journey broken for some users; wrong rating/visibility | Blocks release |
| S3 | Non-core feature broken; visual defects on main screens | Fix in next sprint |
| S4 | Cosmetic | Backlog |
