# Kazi — Technical Design Document (TDD)

| | |
|---|---|
| **Version** | v1.0 |
| **Status** | Draft for build |
| **Last updated** | 2026-11-14 |
| **Related** | [PRD](01-PRD.md) · [ADD](02-ADD.md) · [UI/UX Spec](04-UI-UX-SPEC.md) · [Test plan](06-TEST-PLAN.md) · starter files in [`firebase/`](firebase/) |

> **Source of truth:** if this document and the code disagree, fix one of them in the same PR. Field names, collection names, enum values and limits in this document are **contracts**. Agents must not invent new ones without updating this file.

---

## 1. Tech stack

### 1.1 Platforms and tooling

| Item | Choice |
|---|---|
| Flutter | Latest **stable** at project creation (Dart 3.x, null-safe) |
| Android | `minSdk 23`, `targetSdk` = latest required by Google Play, App Bundle |
| iOS | Code kept compatible; not released in v1 |
| Web | Admin panel: separate React + TypeScript app in `/admin` (Vite, Firebase JS SDK), not Flutter |
| Backend | Firebase (Blaze plan) — Auth, Firestore, Storage, Functions 2nd gen, FCM, Remote Config, App Check, Analytics, Crashlytics, Hosting |
| Functions runtime | TypeScript, Node.js 22, `firebase-functions` v2 API, `firebase-admin` |
| Region | `africa-south1` — Firestore, Storage, Functions 2nd gen, and all Firebase products. Confirmed available for all used products. |
| CI | GitHub Actions |

### 1.2 Flutter packages

Use the latest stable versions at creation time and pin them in `pubspec.lock`. Add a package only if it appears here or in an approved PR that updates this table.

| Purpose | Package |
|---|---|
| State management | `provider` |
| Routing / deep links | `go_router` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`, `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config`, `firebase_app_check` |
| Models | `freezed_annotation`, `json_annotation` (+ dev: `build_runner`, `freezed`, `json_serializable`) |
| i18n | `flutter_localizations` (SDK), `intl` |
| Images | `cached_network_image`, `image_picker`, `flutter_image_compress` |
| Contact / sharing | `url_launcher`, `share_plus` |
| Phone numbers | `phone_numbers_parser` |
| Icons | `lucide_icons_flutter` (Lucide, matches the Figma icons) |
| Brand logo | `flutter_svg` (renders the SVG logo kit in `assets/kazi-logo-kit/svg/` crisply at any size) |
| Device / misc | `connectivity_plus`, `package_info_plus`, `shared_preferences`, `uuid`, `collection` |
| Lints | `flutter_lints` + project rules in `analysis_options.yaml` |
| Testing (dev) | `flutter_test`, `integration_test`, `mocktail`, `fake_cloud_firestore`, `firebase_auth_mocks` |

**Forbidden:** `riverpod`, `flutter_bloc`, `get`/GetX, `google_fonts` runtime fetching (fonts are bundled), any HTTP client for Firebase data (use the SDKs).

### 1.3 Functions packages

`firebase-functions`, `firebase-admin`, `zod` (input validation for callables). Dev: `typescript`, `eslint`, `@firebase/rules-unit-testing`, `@firebase/firestore` (rules test client), `vitest` (or `jest`), `firebase-functions-test`.

## 2. Repository structure

```
kazi/
├── AGENTS.md                     # rules for AI coding agents (see 10-AGENTS.md)
├── CLAUDE.md                     # points to AGENTS.md
├── README.md
├── docs/                         # this document set
├── analysis_options.yaml
├── pubspec.yaml
├── l10n.yaml
├── android/  ios/  web/
├── assets/
│   ├── fonts/Montserrat-*.ttf
│   ├── images/                   # onboarding illustrations, empty states
│   └── icon/                     # app icon sources
├── lib/
│   ├── main.dart                 # mobile entry
│   ├── bootstrap.dart            # Firebase init, App Check, emulators, error handling
│   ├── firebase_options_dev.dart
│   ├── firebase_options_prod.dart
│   ├── app/
│   │   ├── kazi_app.dart
│   │   ├── app_providers.dart    # MultiProvider tree (global providers)
│   │   └── router/
│   │       ├── app_router.dart
│   │       ├── routes.dart       # route names/paths constants
│   │       └── guards.dart
│   ├── core/
│   │   ├── config/               # flavor.dart, env.dart, remote_config_keys.dart
│   │   ├── constants/            # limits.dart, firestore_paths.dart, storage_paths.dart
│   │   ├── errors/               # app_exception.dart, error_mapper.dart
│   │   ├── l10n/                 # app_fr.arb, app_en.arb (+ generated)
│   │   ├── models/               # shared freezed models (see §4)
│   │   ├── services/             # analytics, launcher, image, notifications, connectivity
│   │   ├── state/                # async_state.dart, paged_state.dart
│   │   ├── theme/                # kazi_colors, kazi_typography, kazi_spacing, kazi_theme
│   │   ├── utils/                # phone.dart, text_normalize.dart, formatters.dart, debouncer.dart
│   │   └── widgets/              # design-system widgets (see 04-UI-UX-SPEC.md §6)
│   ├── features/
│   │   ├── auth/                 # phone OTP sign-in, profile setup (email: dev/admin only)
│   │   ├── onboarding/           # language picker, intro slides
│   │   ├── home/
│   │   ├── catalog/              # categories, locations
│   │   ├── search/
│   │   ├── listings/             # listing detail, create/edit, my listings
│   │   ├── provider_profile/     # public provider profile
│   │   ├── provider_onboarding/  # become-a-provider flow
│   │   ├── provider_dashboard/
│   │   ├── reviews/
│   │   ├── favorites/
│   │   ├── contacts/             # contact action + "Messages" tab (recent contacts)
│   │   ├── reports/
│   │   ├── verification/
│   │   ├── account/              # settings, language, legal, delete account
│   └── (each feature) ──┬── data/          # Firebase implementations
│                        ├── domain/        # repository interfaces, query objects
│                        └── presentation/  # controllers + screens + widgets
├── test/                         # mirrors lib/
├── integration_test/
├── functions/
│   ├── package.json  tsconfig.json  .eslintrc.js
│   ├── src/
│   │   ├── index.ts              # exports only
│   │   ├── config.ts             # region, limits
│   │   ├── lib/                  # admin.ts, normalize.ts, notify.ts, audit.ts, errors.ts
│   │   ├── triggers/             # onProviderWritten.ts, onListingWritten.ts, ...
│   │   ├── callables/            # deleteAccount.ts, submitVerification.ts, admin/*.ts
│   │   └── scheduled/            # cleanupVerificationFiles.ts
│   └── test/
│       ├── rules/                # firestore.rules.test.ts, storage.rules.test.ts
│       └── functions/
├── scripts/                      # seed-categories.ts, seed-locations.ts, set-claims.ts
├── firebase.json  .firebaserc
├── firestore.rules  firestore.indexes.json  storage.rules
└── .github/workflows/            # ci.yml, deploy-dev.yml, release.yml
```

## 3. App bootstrap and configuration

### 3.1 Flavors

| Flavor | Firebase project (alias) | Firebase project ID | App ID (Android) | App name |
|---|---|---|---|---|
| `dev` | `dev` | `kazi-dev-8099c` | `com.arkepios.kazi.dev` | Kazi Dev |
| `prod` | `prod` | `kazi-prod` _(not yet created)_ | `com.arkepios.kazi` | Kazi |

Run with `flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev`. Add `--dart-define=USE_EMULATORS=true` for the local Emulator Suite. Generate `firebase_options_*.dart` with `flutterfire configure --project=kazi-dev-8099c` (dev) once per project. Always use the Firebase alias (`firebase use dev`) rather than the raw project ID.

> The application IDs are final. `com.arkepios.kazi.dev` (dev) and `com.arkepios.kazi` (prod) cannot be changed after the first Play Store upload.

### 3.2 `bootstrap.dart` responsibilities (in order)

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `Firebase.initializeApp(options: …)` for the flavor.
3. `FirebaseAppCheck.instance.activate(androidProvider: debug ? AndroidProvider.debug : AndroidProvider.playIntegrity, webProvider: ReCaptchaEnterpriseProvider(siteKey))`.
4. If `USE_EMULATORS`: connect Auth (9099), Firestore (8080), Storage (9199), Functions (5001).
5. Firestore settings: `persistenceEnabled: true`, `cacheSizeBytes: 100 * 1024 * 1024`.
6. Crashlytics: `FlutterError.onError` and `PlatformDispatcher.instance.onError` → `recordError` (disabled in `dev` unless `CRASHLYTICS=true`).
7. Remote Config defaults + `fetchAndActivate()` with a 3 s timeout (never blocks startup longer).
8. `runApp(AppProviders(child: KaziApp()))`.

### 3.3 Remote Config keys

| Key | Type | Default | Use |
|---|---|---|---|
| `min_supported_build` | int | `1` | Below this build → blocking "Mettre à jour" screen |
| `maintenance_mode` | bool | `false` | Show maintenance screen |
| `maintenance_message_fr` / `_en` | string | `""` | Message |
| `promo_banner_enabled` | bool | `true` | Home "Devenir prestataire" banner |
| `support_whatsapp` | string | `""` | E.164 number for "Contact support" |
| `terms_version` | string | `"2026-11"` | Re-prompt acceptance when changed |
| `max_listing_photos` | int | `6` | Must not exceed the rules limit |

## 4. Data model (Cloud Firestore)

### 4.1 Conventions

- Collection names: lower camelCase plural. Field names: lower camelCase.
- Timestamps: Firestore `Timestamp`, set to `FieldValue.serverTimestamp()` on the client (rules require `request.time`).
- Enums are stored as **lower_snake_case strings**.
- Money: `priceAmount` is a **number** in the listing's currency (USD up to 2 decimals; CDF integer). `currency` ∈ `USD | CDF`.
- Phone numbers: **E.164** strings (`+243812345678`).
- Localised text (categories): map `{ "fr": "...", "en": "..." }`.
- "Server" fields: written only by Cloud Functions (Admin SDK). Security rules reject client writes to them.
- IDs: auto IDs unless stated (deterministic IDs are used for uniqueness).

### 4.2 Collections overview

```
users/{uid}
  favorites/{providerId}
  blocks/{blockedUid}
  devices/{deviceId}
providers/{uid}                       # same id as the user
  reviews/{reviewerUid}               # one review per reviewer per provider
listings/{listingId}
contacts/{clientUid}_{providerId}
reports/{reporterUid}_{targetType}_{targetKey}
verificationRequests/{uid}
categories/{categoryId}
config/locations
config/limits
config/moderation
adminLogs/{logId}
```

### 4.3 `users/{uid}` — private account

Readable by the owner and moderators only.

| Field | Type | Writer | Notes |
|---|---|---|---|
| `displayName` | string 2–60 | client | |
| `photoUrl` | string? | client | Storage download URL |
| `phone` | string (E.164) | client (create only) | **The account identity.** Must equal the verified `phone_number` in the Auth token; email/password accounts cannot create a profile. |
| `email` | string? 3–254 | client | Optional contact email (unverified); not an identity |
| `locale` | `fr` \| `en` | client | |
| `city` | string | client | City id, e.g. `kinshasa` |
| `commune` | string? | client | Commune id, e.g. `gombe` |
| `termsVersion` | string | client | The version of the Terms and Privacy Policy in force when the profile was created (`AppDefaults.termsVersion`, equal to the "Version …" printed on the published pages) |
| `termsAcceptedAt` | timestamp | client | Server timestamp (`request.time`, enforced by the rules). Acceptance is by continuing: the phone and profile-setup screens show "By continuing you accept the Terms and Privacy Policy" with links to the pages (`LegalNotice`) |
| `isProvider` | bool | server | Set when a provider profile exists |
| `status` | `active` \| `suspended` \| `deleting` | create: client `active`; then server | |
| `createdAt`, `updatedAt` | timestamp | client | `request.time` |

**Subcollections**
- `favorites/{providerId}`: `{ providerId, displayName, photoUrl, headline, createdAt }`. The card snapshot avoids extra reads.
- `blocks/{blockedUid}`: `{ createdAt }`.
- `devices/{deviceId}`: `{ fcmToken, platform: 'android'|'ios'|'web', locale, updatedAt }`. `deviceId` = SHA-1 of the token.

### 4.4 `providers/{uid}` — public provider profile

Readable by any signed-in user when `status == 'approved'`; always by the owner and moderators.

| Field | Type | Writer | Notes |
|---|---|---|---|
| `displayName` | string 2–60 | client | Business or personal name |
| `bio` | string 0–600 | client | |
| `photoUrl` | string? | client | Avatar |
| `coverUrl` | string? | client | |
| `categoryIds` | string[1..3] | client | Category ids |
| `city` | string | client | v1: `kinshasa` |
| `baseCommune` | string | client | Commune id |
| `communes` | string[1..10] | client | Communes served (includes `baseCommune`) |
| `whatsappNumber` | string (E.164) | client | Public |
| `callNumber` | string? (E.164) | client | Public; defaults to `whatsappNumber` in the UI if null |
| `yearsExperience` | int 0–60 | client | |
| `portfolio` | `{id, path, url}[]` ≤ 12 | client | |
| `status` | `pending` \| `approved` \| `rejected` \| `suspended` | create: client `pending`; owner may set `rejected → pending` (resubmit); otherwise server | |
| `statusReason` | string? | server | Shown to the provider on rejection |
| `verified` | bool | server | ID-verified badge |
| `ratingAvg` | number | server | 0 when no reviews; 1 decimal |
| `ratingCount` | int | server | |
| `ratingSum` | int | server | Sum of the review stars |
| `ratingScore` | number | server | Smoothed average used **only** to rank "best rated": `(4.0 * 5 + ratingSum) / (5 + ratingCount)` (a provider with no review scores 4.0). Set by `onReviewWritten` / `onProviderWritten`; clients never write it and never see it as a rating |
| `listingCount` | int | server | Listings that hold a limit slot: **`active` + `paused` only** (drafts and listings hidden for the limit do not count). Maintained by `onListingWritten`; compared with `config/limits.maxListingsPerProvider` by the create rule |
| `headline` | `{ categoryId, fromAmount, fromCurrency, fromPriceType }` | server | For cards: "Plombier · dès 10 $" |
| `stats` | `{ contactsTotal, contactsByMonth: { "2026-11": n } }` | server | |
| `searchKeywords` | string[] | server | Provider name, categories, communes |
| `createdAt`, `updatedAt` | timestamp | client | |
| `approvedAt` | timestamp? | server | |

> **Create payload:** the client must send the server fields with their initial values (`status: 'pending'`, `verified: false`, `ratingAvg: 0`, `ratingCount: 0`, `ratingSum: 0`, `listingCount: 0`); the rules reject anything else (and any `ratingScore`: `onProviderWritten` adds it). All other server fields are added by Functions.
> **Listing create payload:** always include `photos: []` (drafts start without photos) and `communes` with at least one commune.

### 4.5 `providers/{pid}/reviews/{reviewerUid}`

| Field | Type | Writer | Notes |
|---|---|---|---|
| `authorUid` | string | client | Must equal doc id and `auth.uid` (needed for collection-group queries) |
| `authorName` | string 1–60 | client | Snapshot |
| `authorPhotoUrl` | string? | client | Snapshot |
| `rating` | int 1–5 | client | |
| `text` | string 0–300 | client | Optional comment |
| `providerReply` | string 0–500? | provider (P2) | |
| `providerReplyAt` | timestamp? | provider | |
| `createdAt`, `updatedAt` | timestamp | client | |

Create is allowed only if `contacts/{reviewerUid}_{pid}` exists (written by the client when it opens WhatsApp / the dialler) and the reviewer isn't the provider; the document id is the author's uid, so a user has one review per provider; the author may edit `rating` / `text` or delete it; a moderator may delete it. **Stars are whole numbers 1–5; the comment is optional, ≤ 300 characters.** The provider's `rating*` fields are never client-writable. The UI states the gate before the form: a user who has not contacted the provider sees "Contactez ce prestataire pour laisser un avis".

**Display** (provider card, list item, search results, profile, listing detail): `RatingSummary` = orange stars (`#F25912`; empty stars in the border colour; fill rounded to the nearest half) + `4,8 (32 avis)` in the Label style (locale number format); no review → a "Nouveau" chip, never `0,0`; screen-reader label "Note 4,8 sur 5, 32 avis"; tappable parts are ≥ 44 px.

### 4.6 `listings/{listingId}`

Readable by any signed-in user when `visible == true`; always by the owner and moderators.

| Field | Type | Writer | Notes |
|---|---|---|---|
| `providerId` | string | client (immutable) | `== auth.uid` |
| `title` | string 4–80 | client | No phone numbers (validated in the app and by function) |
| `description` | string 0–1000 | client | |
| `categoryId` | string | client | |
| `priceType` | `fixed` \| `from` \| `quote` | client | `quote` → `priceAmount == null` |
| `priceAmount` | number? ≥ 0 | client | |
| `currency` | `USD` \| `CDF` | client | |
| `photos` | `{id, path, url}[]` 0–6 | client | Thumbnail URLs derived (see §7) |
| `city` | string | client | |
| `communes` | string[1..10] | client | Service area |
| `status` | `draft` \| `active` \| `paused` | client | Provider intent |
| `createdAt`, `updatedAt` | timestamp | client | |
| `visible` | bool | server | `status == active && providerStatus == approved && moderation == ok` |
| `moderation` | `ok` \| `hidden` | server | Admin/auto-hide |
| `moderationReason` | string? | server | |
| `providerStatus` | provider status enum | server | Denormalised |
| `providerName`, `providerPhotoUrl` | string | server | Denormalised |
| `providerVerified` | bool | server | Denormalised |
| `ratingAvg`, `ratingCount`, `ratingScore` | number, int, number | server | Provider rating, denormalised (`ratingScore` is what "best rated" sorts on) |
| `categoryName` | `{fr, en}` | server | Denormalised |
| `searchKeywords` | string[] ≤ 200 | server | See §8 |
| `contactCount` | int | server | |
| `publishedAt` | timestamp? | server | First time `visible` became true |
| `countsTowardLimit` | bool | server | The listing holds one of the provider's limit slots (`status` active/paused and a slot was free). Makes slot accounting idempotent |
| `moderationReason = 'over_limit'` | — | server | The provider was at `config/limits.maxListingsPerProvider` when the listing became active/paused: `moderation = hidden`, **not deleted, photos kept**. The app shows "Limite atteinte" with an explanation. Any later write of the listing (edit/save, resume) retries; it is restored once a slot is free |

> Because `visible` is computed by a function, a newly created active listing becomes public a few seconds after creation. The UI shows "Publication en cours…" until the owner's listener sees `visible == true`.

### 4.7 `contacts/{clientUid}_{providerId}`

| Field | Type | Writer |
|---|---|---|
| `clientUid` | string | client (= auth.uid) |
| `providerId` | string | client |
| `providerName`, `providerPhotoUrl` | string | client (snapshot for the "Messages" tab) |
| `listingId` | string? | client |
| `channel` | `whatsapp` \| `call` | client |
| `providerVerified` | bool | client (provider verification snapshot at contact time) |
| `whatsappNumber` | string (E.164) | client (provider contact snapshot) |
| `callNumber` | string? (E.164) | client (provider contact snapshot) |
| `firstAt` | timestamp | client (create) |
| `lastAt` | timestamp | client |

**Rules changes recorded:** `users/{uid}` create now requires `phone == request.auth.token.phone_number` (phone OTP is the identity; the former dev exception for email/password accounts is removed); contact documents include the `providerVerified`, `whatsappNumber`, and `callNumber` snapshot fields.

### 4.8 `reports/{reporterUid}_{targetType}_{targetKey}`

`targetKey` = `listingId`, `providerId`, or `{providerId}__{reviewerUid}` for reviews. The deterministic ID gives one report per user per target. **Reports are created only by the `submitReport` callable** (rules deny client writes): it checks the target exists and is not the reporter's own (for a review: not the reviewer), applies the per-user limit and returns `already_reported` for a repeat. `listing`, `provider` and `review` targets are accepted. A reported review shows in the admin queue (dismiss only); an abusive review is removed by a moderator (rules allow `delete`), there is no removal callable yet. The limit is `REPORTS_PER_DAY` (10 new reports per rolling 24 h) tracked in the server-only `reportQuota/{uid}` (`{ windowStart, count }`).

| Field | Type | Writer |
|---|---|---|
| `reporterUid` | string | client |
| `targetType` | `listing` \| `provider` \| `review` | client |
| `targetKey` | string | client |
| `reason` | `scam` \| `inappropriate` \| `fake` \| `wrong_category` \| `other` | client |
| `details` | string 0–500 | client |
| `status` | `open` \| `dismissed` \| `actioned` | create `open`; then server |
| `resolution` | `{ action, note, by, at }`? | server |
| `createdAt` | timestamp | client |

### 4.9 `verificationRequests/{uid}`

Created only through the `submitVerification` callable.

| Field | Type |
|---|---|
| `status` | `pending` \| `approved` \| `rejected` |
| `idDocumentPath`, `selfiePath` | string (private Storage paths; cleared after decision) |
| `submittedAt`, `decidedAt` | timestamp |
| `decidedBy` | admin uid |
| `reason` | string? |

### 4.10 `categories/{categoryId}`

`{ names: {fr, en}, iconKey: string, order: int, featured: bool, active: bool, synonyms: {fr: string[], en: string[], ln: string[], sw: string[]}, listingCount: int (server) }`. Readable by any signed-in user; **never written by a client** (rules: `allow write: if false`): the seed script and, later, `admin_upsertCategory` write them.

- **The id is a permanent slug** (`plomberie`, `froid-clim`, `mecanique-auto`…). Once data exists it is never renamed: rename only `names`, and retire a category with `active: false` (never delete it; listings and providers keep pointing at it).
- `iconKey` is a Material icon name resolved in the app (`lib/core/utils/category_icon.dart`); an unknown key falls back to a generic icon, so a category can be added without an app update.
- `featured` (exactly 8) are the only ones Home shows, followed by "Voir tout" (Explorer lists all active ones). `autres` always has the last `order`.
- `synonyms`: 4–8 words per language in `fr` and `en` (`ln` and `sw` stay empty for now). `onListingWritten` adds them (with the names) to the listing's `searchKeywords` through the usual normalise/keywords code, so searching "plombier" finds Plomberie. Existing listings pick up changed synonyms the next time they are written.
- A provider picks at most 3 categories (`Limits.maxCategoriesPerProvider`); the listing form picks exactly one. Both use the active list.
- An empty category shows "Soyez le premier à proposer ce service", which opens the listing form with that category pre-selected (`/provider/listings/new?cat={slug}`).

**One source of truth: [`assets/data/categories.json`](../assets/data/categories.json)**, read by `scripts/seed-categories.ts` (via `shared/categories.ts`, which validates it) and bundled in the app as its offline fallback. Seeding is idempotent and keeps `listingCount`; in dev it also removes the old placeholder categories and `demo_*` data and remaps placeholder ids on dev providers/listings. It refuses `kazi-prod`.

| id | fr | en | iconKey | featured |
|---|---|---|---|---|
| plomberie | Plomberie | Plumbing | `plumbing` | yes |
| electricite | Électricité | Electrical | `electrical_services` | yes |
| maconnerie | Maçonnerie & carrelage | Masonry & tiling | `construction` |  |
| peinture | Peinture & décoration | Painting & decoration | `format_paint` |  |
| menuiserie | Menuiserie & meubles | Carpentry & furniture | `carpenter` |  |
| soudure | Soudure & métallerie | Welding & metalwork | `hardware` |  |
| froid-clim | Frigo & climatisation | Fridge & air conditioning | `ac_unit` |  |
| menage | Ménage & nettoyage | Cleaning | `cleaning_services` | yes |
| jardinage | Jardinage | Gardening | `yard` |  |
| coiffure | Coiffure & tresses | Hairdressing & braiding | `content_cut` | yes |
| beaute | Beauté & ongles | Beauty & nails | `face_retouching_natural` |  |
| couture | Couture & mode | Tailoring & fashion | `checkroom` | yes |
| telephones | Réparation de téléphones | Phone repair | `phone_android` | yes |
| informatique | Informatique & réseaux | IT & networks | `computer` |  |
| electromenager | Réparation électroménager | Appliance repair | `home_repair_service` |  |
| mecanique-auto | Mécanique auto | Auto repair | `car_repair` | yes |
| transport | Transport & déménagement | Transport & moving | `local_shipping` |  |
| livraison | Livraison & coursier | Delivery & courier | `delivery_dining` |  |
| cours | Cours particuliers | Tutoring | `school` | yes |
| evenements | Événements, traiteur & DJ | Events, catering & DJ | `celebration` |  |
| photo-video | Photo & vidéo | Photo & video | `photo_camera` |  |
| securite | Sécurité & gardiennage | Security | `security` |  |
| autres | Autres services | Other services | `more_horiz` |  |

### 4.11 `config/locations`

```json
{
  "cities": [
    {
      "id": "kinshasa",
      "name": "Kinshasa",
      "active": true,
      "communes": [
        {"id": "bandalungwa", "name": "Bandalungwa"}, {"id": "barumbu", "name": "Barumbu"},
        {"id": "bumbu", "name": "Bumbu"}, {"id": "gombe", "name": "Gombe"},
        {"id": "kalamu", "name": "Kalamu"}, {"id": "kasa_vubu", "name": "Kasa-Vubu"},
        {"id": "kimbanseke", "name": "Kimbanseke"}, {"id": "kinshasa", "name": "Kinshasa"},
        {"id": "kintambo", "name": "Kintambo"}, {"id": "kisenso", "name": "Kisenso"},
        {"id": "lemba", "name": "Lemba"}, {"id": "limete", "name": "Limete"},
        {"id": "lingwala", "name": "Lingwala"}, {"id": "makala", "name": "Makala"},
        {"id": "maluku", "name": "Maluku"}, {"id": "masina", "name": "Masina"},
        {"id": "matete", "name": "Matete"}, {"id": "mont_ngafula", "name": "Mont-Ngafula"},
        {"id": "ndjili", "name": "N'djili"}, {"id": "ngaba", "name": "Ngaba"},
        {"id": "ngaliema", "name": "Ngaliema"}, {"id": "ngiri_ngiri", "name": "Ngiri-Ngiri"},
        {"id": "nsele", "name": "Nsele"}, {"id": "selembao", "name": "Selembao"}
      ]
    }
  ]
}
```

Cached on device by `CatalogController` (Firestore cache + `shared_preferences` copy for first launch offline).

### 4.11a `config/limits`

```json
{ "maxListingsPerProvider": 10 }
```

**Single source of truth** for the per-provider listing limit. Free v1 value: `10`, counted over `active` + `paused` listings (`providers.listingCount`; drafts are free). Future paid tiers change this value (or add per-tier fields) without a rules or app release.

| Reader | Use |
|---|---|
| `firestore.rules` | `listings` create: `providers.listingCount < maxListingsPerProvider` |
| App (`ListingRepository.fetchMaxListings` / `getQuota`) | "3/10 annonces" on the dashboard; the "Nouvelle annonce" button and the form explain the limit instead of failing |
| Cloud Functions (`getMaxListingsPerProvider`) | `onListingWritten` is the enforcement point for activation: a listing that becomes active/paused with no free slot is hidden with `moderationReason = over_limit` (never deleted). The create rule only gates *creating* a listing while the provider is at the limit |

Readable by all, written by seed/admin only (`config/{docId}` rule). Missing document → fallback `10` everywhere (`Limits.maxListingsPerProvider`, `DEFAULT_MAX_LISTINGS_PER_PROVIDER`, rules). Seed: `scripts/seed-rest.ts`.

### 4.11b `config/moderation`

`{ autoApproveProviders: bool }`. v1: `true` (the admin panel only has the reports queue so far), so `onProviderWritten` approves a provider as soon as it is created `pending` (or resubmitted from `rejected`). Set to `false` once admin moderation is live.

### 4.12 `adminLogs/{logId}`

`{ actorUid, action, targetType, targetId, before?: map, after?: map, note?, createdAt }`. Server only; admin read.

## 5. Security rules

Starter files: [`firebase/firestore.rules`](firebase/firestore.rules) and [`firebase/storage.rules`](firebase/storage.rules). Summary:

**Access model (beta: sign-in only).** "Signed in" means a verified phone number (`phone_number` in the token) **or** a staff claim (`admin` / `moderator`). Guests and email-only accounts can read and write nothing: there are no public reads. `moderator` may perform moderation actions only (read queues, resolve reports, remove abusive reviews, decide verification, set provider status); `admin` adds roles, categories and the audit log (admin-only: `admin_upsertCategory`, `admin_setRole`, `adminLogs`). Callables use the same definitions (`functions/src/lib/caller.ts`). Where the table below says "anyone", read "any signed-in user".

| Path | Read | Create | Update | Delete |
|---|---|---|---|---|
| `users/{uid}` | owner, moderator | owner (whitelisted fields, `phone` = verified Auth phone, status `active`) | owner (whitelisted mutable fields) | ❌ (callable) |
| `users/{uid}/favorites|blocks|devices` | owner | owner | owner | owner |
| `providers/{uid}` | signed-in if approved; owner; moderator | owner, status `pending`, server fields zeroed | owner, client fields only; `rejected → pending` resubmit | ❌ |
| `providers/{pid}/reviews/{rid}` | signed-in | rid = auth.uid ≠ pid, contact exists, valid | author (rating/text); provider (reply only) | author, moderator |
| `listings/{id}` | signed-in if `visible`; owner; moderator | owner, client fields only, `providers.listingCount < config/limits.maxListingsPerProvider` (fallback 10 if the doc is missing; the count is active + paused only), provider not suspended | owner, client fields only | owner |
| `contacts/{id}` | client or provider of the pair; moderator | client, id = `uid_providerId` | client (`listingId`, `channel`, `lastAt`, snapshots) | ❌ |
| `reports/{id}` | moderator | ❌ (`submitReport` callable) | ❌ | ❌ |
| `reportQuota/{uid}` | ❌ | ❌ | ❌ | ❌ (server only) |
| `verificationRequests/{uid}` | owner, moderator | ❌ (callable) | ❌ | ❌ |
| `categories`, `config` | signed-in | ❌ | ❌ | ❌ |
| `adminLogs` | admin | ❌ | ❌ | ❌ |

**Storage**

| Path | Read | Write |
|---|---|---|
| `media/{uid}/{kind}/{...}` where kind ∈ `avatar, cover, portfolio, listings` | signed-in | owner; `image/*`; < 2 MB; delete by owner |
| `media/{uid}/**/thumbs/*` | signed-in | ❌ (extension writes with Admin SDK) |
| `private/verification/{uid}/{file}` | ❌ (admin uses signed URLs) | owner; `image/*`; < 5 MB; create only |

> **Listing limit.** The limit is read from `config/limits` (§4.11a), never hard-coded in the rules. Rules tests cover: allowed at 9 of 10, denied at 10 of 10, follows a raised/lowered value, fallback to 10 when the doc is missing, clients cannot write `config/limits`.

**Rules testing is mandatory**: every rule branch has an allow and a deny test in `functions/test/rules/` (see [Test plan](06-TEST-PLAN.md)).

## 6. Cloud Functions

All functions use `region: config.REGION` and are 2nd gen. Callables use `enforceAppCheck: true` and validate input with `zod`. Errors are thrown as `HttpsError` with codes from §11.

### 6.1 Firestore triggers

| Function | Trigger | Behaviour |
|---|---|---|
| `onProviderWritten` | `providers/{uid}` written | (1) Recompute `searchKeywords`. (2) If `displayName`, `photoUrl`, `verified`, `ratingAvg`, `ratingCount`, `ratingScore` or `status` changed → batch-update the provider's listings (denormalised fields + recompute `visible`). (3) **v1 auto-approval:** if `status == pending` on create (or `rejected → pending`) and `config/moderation.autoApproveProviders == true`, set `status = approved`, `approvedAt`. (3b) On create: set `users/{uid}.isProvider = true` *(not yet implemented)*. (4) Guard against infinite loops: compare before/after, and only write when values differ |
| `onListingWritten` | `listings/{id}` written | (1) On create/update: fill denormalised provider + category fields, compute `searchKeywords`, `visible`, set `publishedAt` the first time it becomes visible. (2) Validate content (no phone numbers in title; profanity list) → set `moderation = hidden`, `moderationReason = 'auto_content'` if it fails. (3) Maintain `providers.listingCount` through `countsTowardLimit` (state-based, idempotent: +1 when a listing becomes active/paused with a free slot, −1 when it goes to draft or is deleted); with no free slot the listing is hidden with `over_limit` instead of counted. `providers.headline` and `categories.listingCount` are **not yet implemented**. (4) On delete: delete the listing's Storage objects (also on update when photos are removed); only paths under `media/{providerId}/listings/` are ever deleted (the `photos` array is client-written). Server writes happen only when a computed value differs, so the invocation caused by the function's own write is a no-op (logged as `wrote: false`) |
| `onReviewWritten` | `providers/{pid}/reviews/{rid}` written (rating added, edited or deleted) | In a transaction, **recompute** `ratingSum` / `ratingCount` from the reviews, then `ratingAvg = round(sum / count, 1)` (0 when no review) and `ratingScore`. Recomputing (not applying a delta) makes it idempotent on re-delivery and makes the anonymising move of `deleteAccount` (delete + create, same rating) net zero. Writes only when a value changed; never creates the provider; the provider write then reaches the listings through `onProviderWritten` |
| `onContactWritten` | `contacts/{id}` written | Increment `providers.stats.contactsTotal`, `stats.contactsByMonth[YYYY-MM]` and `listings.contactCount`. **Ignore** updates where `lastAt - before.lastAt < 10 min` (anti-inflation) |
| `onReportCreated` | `reports/{id}` created | **Implemented.** Count open reports for the target (`where targetType, targetKey, status == open`). If ≥ `AUTO_HIDE_THRESHOLD` (3): hide the listing (`moderation = hidden`, reason `auto_reports`) or, for a provider, set every listing to `hidden` (the provider stays approved until an admin decides). Write `adminLogs` |

### 6.2 Callables (mobile)

| Function | Input | Behaviour |
|---|---|---|
| `submitVerification` | `{ idDocumentPath, selfiePath }` | Caller must be a provider. Verify both files exist under `private/verification/{uid}/`. Upsert `verificationRequests/{uid}` with `status = pending` |
| `submitReport` | `{ targetType: listing\|provider, targetKey, reason, details? }` | Verified callers only. One report per user and target (`already_reported` otherwise, no quota used); target must exist and not be the caller's; `resource-exhausted: rate-limited` beyond 10 new reports per 24 h. Creates `reports/{uid}_{type}_{key}` with status `open` |
| `deleteAccount` | `{}` | Caller must have a verified phone and a sign-in at most **5 minutes old** (`auth_time`): the client re-confirms with a fresh OTP first, otherwise `failed-precondition: recent-login-required`. See §6.5 |

### 6.3 Callables (admin — require `admin` or `moderator` claim)

| Function | Input | Behaviour |
|---|---|---|
| `admin_setProviderStatus` | `{ providerId, status: approved\|rejected\|suspended\|pending, reason? }` | Update the provider; `approvedAt` on first approval; notify provider (FCM); `adminLogs` |
| `admin_getVerificationFiles` | `{ uid }` | Returns signed read URLs (10 min) for both files |
| `admin_decideVerification` | `{ uid, approved: bool, reason? }` | Set `providers.verified`; update request; **delete both files** and clear paths; notify; `adminLogs` |
| `moderator_hideListing` | `{ listingId, note? }` | **Implemented.** Staff (moderator or admin). `moderation = hidden`, reason `admin`; open reports on it → `actioned`; `adminLogs` |
| `moderator_restoreListing` | `{ listingId, note? }` | **Implemented.** Clears an `admin`/`auto_reports` hide (refuses `over_limit`, which the slot logic owns); open reports → `dismissed`; `adminLogs` |
| `moderator_suspendProvider` | `{ providerId, reason }` | **Implemented.** `providers.status = suspended` (`onProviderWritten` then hides their listings); open reports on the provider → `actioned`; `adminLogs` |
| `moderator_dismissReport` | `{ reportId, note? }` | **Implemented.** Dismisses the report and every other open report on the same target; `adminLogs` |
| `admin_resolveReport` | `{ reportId, action: dismiss\|hide_target\|unhide_target\|suspend_provider\|delete_review, note? }` | Apply the action; mark all open reports on the same target as resolved; `adminLogs` |
| `admin_upsertCategory` | `{ id, names: {fr,en}, iconKey, order, featured, active, synonyms }` | `adminLogs` |
| `admin_setRole` | `{ uid, role: admin\|moderator, enabled }` | **superAdmin claim only**. Sets custom claims |

### 6.4 Scheduled

| Function | Schedule | Behaviour |
|---|---|---|
| `cleanupVerificationFiles` | daily 02:00 Africa/Kinshasa | Delete `private/verification/**` files older than 30 days and mark stale pending requests `rejected` (reason `expired`) |
| `cleanupDraftListings` | daily 03:30 Africa/Kinshasa (runs in `europe-west1`) | **Implemented.** Delete `draft` listings not updated for **30 days**; `onListingWritten` removes their media; needs the composite index `listings(status, updatedAt)` |
| `cleanupOrphanMedia` | daily 03:00 Africa/Kinshasa | List files under `media/{uid}/listings/{listingId}/`. For each group: if the listing doc doesn't exist or doesn't reference the file in its `photos` array, and the file is older than 24 hours, delete it. Logs the count of deleted files. |

### 6.5 Account deletion (`deleteAccount`)

The app asks the user to type the confirmation word, **re-confirms with a fresh OTP** sent to the account's own number (`reauthenticateWithCredential`, then a new ID token so `auth_time` is current), then calls the callable. The callable (`functions/src/callables/deleteAccount.ts`, logic in `lib/deleteAccount.ts`) runs these steps, each **idempotent**, so a call can simply be repeated after a partial failure:

1. Set `users/{uid}.status = 'deleting'` (if the doc exists).
2. Reviews the user **wrote** (`collectionGroup('reviews').where('authorUid','==',uid)`) are **anonymised, not deleted**: moved to a neutral id (`deleted_<hash>`, never the uid) with `authorUid = 'deleted'`, `authorName = 'Utilisateur supprimé'`, no `authorPhotoUrl`; rating, text and dates are kept so provider ratings do not change. (Set + delete in one batch; the id is deterministic so a retry cannot duplicate.)
3. `reports` filed by the user are kept (safety record, 12-month retention) with `reporterUid = 'deleted'`.
4. Delete `contacts` where `clientUid == uid` **and** where `providerId == uid` (those hold this account's phone numbers as a snapshot).
5. Delete other users' `favorites` that point at this account (`collectionGroup('favorites').where('providerId','==',uid)`).
6. Delete all `listings` with `providerId == uid`, then `providers/{uid}` with its `reviews` subcollection, then `verificationRequests/{uid}` and the report rate-limit counter `reportQuota/{uid}`.
7. Delete Storage prefixes `media/{uid}/` and `private/verification/{uid}/`.
8. Delete `users/{uid}` with `favorites`, `blocks`, `devices`, and **last** the Auth user (`admin.auth().deleteUser`, "not found" ignored). Until the Auth user is gone the user can sign in again and retry.

Nothing creates a document: triggers touch `providers/{uid}` with `update()` only after checking it exists (`syncListingSlot`, `releaseSlotOnDelete`, `approveProviderIfExists`), so deleting listings or racing writes cannot recreate a deleted provider. Logs contain counts only. Collection-group queries on `reviews.authorUid` and `favorites.providerId` have field overrides in `firestore.indexes.json`. `onReviewWritten` recomputes from the reviews, so the anonymising move (delete + create, same rating) is net zero.

**Operator deletion on request** (`scripts/delete-account.ts`, logic in `functions/src/lib/operatorDelete.ts`): staff only (the `--operator` Auth user must have `admin` or `moderator`), finds the account by phone number (Auth user, else a `users` doc with that phone), dry-run unless `--execute` (`--confirm-prod` for prod), reuses `deleteAccountData`, writes `adminLogs` (`operator_delete_account` / `_failed`) with the uid and a reason that may not contain phone numbers or emails. See the runbook §G.

The app signs out locally after the callable resolves. A public web page (Firebase Hosting `/delete-account`) explains how to request deletion without the app, as Google Play requires.

### 6.6 Notifications

| Type (`data.type`) | Trigger | FR title | EN title |
|---|---|---|---|
| `provider_approved` | admin approves | "Votre profil est approuvé 🎉" | "Your profile is approved 🎉" |
| `provider_rejected` | admin rejects | "Votre profil doit être corrigé" | "Your profile needs changes" |
| `verification_approved` | badge granted | "Vous êtes vérifié ✔" | "You're verified ✔" |
| `verification_rejected` | badge denied | "Vérification refusée" | "Verification declined" |
| `listing_hidden` | moderation | "Une annonce a été masquée" | "A listing was hidden" |

Language = `users/{uid}.locale`. Sent to all tokens in `devices`; tokens with `messaging/registration-token-not-registered` are deleted. Android channel `kazi_default`. Tapping a notification deep-links to the provider dashboard.

## 7. Media handling

| Kind | Path | Max | Client processing |
|---|---|---|---|
| Avatar | `media/{uid}/avatar/{imageId}.jpg` | 1 | Square crop, 512 px, q80 |
| Cover | `media/{uid}/cover/{imageId}.jpg` | 1 | 1280 px longest, q75 |
| Portfolio | `media/{uid}/portfolio/{imageId}.jpg` | 12 | 1280 px, q75 |
| Listing photo | `media/{uid}/listings/{listingId}/{imageId}.jpg` | 6 / listing | 1280 px, q75 |
| ID document / selfie | `private/verification/{uid}/{id\|selfie}_{ts}.jpg` | 2 | 1600 px, q85 |

- `imageId` = UUID v4.
- **Resize Images extension** config: sizes `200x200,800x800`; output `webp`; resize path `/media`; thumbnails folder `thumbs`; keep originals.
- Thumbnail path convention: `…/thumbs/{imageId}_200x200.webp` and `_800x800.webp`. `KaziNetworkImage` takes the original `path` plus a `ThumbSize` and builds the thumb URL with `FirebaseStorage.ref(path).getDownloadURL()`, cached in memory. It falls back to the original if the thumb doesn't exist yet.
- **Upload flow (upload-on-submit):** Picking a photo only compresses it and stores it locally (`XFile` in controller state). The UI previews from the local file. No Storage call on pick. On publish/save: (1) validate the form — if invalid, nothing is uploaded; (2) create the listing doc as `draft` if it doesn't exist (single in-flight Future, no duplicate drafts); (3) upload pending photos sequentially with per-photo progress; (4) update the doc with `photos` + `status` in one write. On failure: stay on form, keep local files, keep photos that did upload on the draft, retry uploads only the missing ones. Back/cancel: nothing to clean up; if a draft exists, prompt "Garder le brouillon?" — discard deletes doc + uploaded photos. Editing: existing photos stay as remote entries; removed remote photos deleted from Storage only after save succeeds. Provider onboarding avatar/cover: upload only after form validates, right before provider doc is written.
- **Safety net:** `cleanupOrphanMedia` scheduled function (daily) deletes orphan files under `media/{uid}/listings/{listingId}/` whose listing doc no longer exists or doesn't reference them, older than 24 hours (see §6.4).

## 8. Search

### 8.1 Normalisation (identical in Dart and TypeScript)

```
normalize(text):
  1. lower-case
  2. strip diacritics (é→e, è→e, ê→e, à→a, ç→c, ô→o, î→i, ï→i, û→u, ù→u …; use NFD and remove combining marks)
  3. replace any char not [a-z0-9] with a space
  4. split on whitespace, drop tokens shorter than 2 chars
  5. drop stop words: de, du, des, la, le, les, et, en, a, au, aux, un, une, pour, sur, avec, the, and, of, for, in
tokens(text) = distinct(normalize(text))
prefixes(token) = [token[0..k] for k in 2..min(len, 15)]
```

`searchKeywords` (listing) = distinct prefixes of tokens from `title`, `categoryName.fr`, `categoryName.en`, `providerName`, commune names. Capped at 200 entries (longest prefixes dropped first).

Test vectors (must pass in both languages):

| Input | Tokens |
|---|---|
| `"Réparation de fuite d'eau"` | `["reparation","fuite","eau"]` |
| `"Électricité générale"` | `["electricite","generale"]` |
| `"Coiffure & beauté à Gombe"` | `["coiffure","beaute","gombe"]` |

### 8.2 Query planning

Firestore allows **one** `array-contains` per query. `SearchResultsController` builds the query as follows:

1. Always: `where('visible', '==', true)`, `where('city', '==', city)`.
2. If keyword present → `where('searchKeywords', 'array-contains', firstTokenPrefix)` (use the longest token in the query, truncated to 15 chars). The commune filter is then applied **client-side**.
3. Else if commune selected → `where('communes', 'array-contains', commune)`.
4. Optional equality filters: `categoryId`, `providerVerified == true`.
5. Order: `ratingScore desc` (default; the smoothed "best rated" score, see §4.4) or `publishedAt desc` ("Récents"). `minRating` is applied client-side.
6. Page size 20; if client-side filtering leaves < 10 results and more pages exist, fetch up to 2 more pages automatically.

All combinations must have composite indexes in [`firebase/firestore.indexes.json`](firebase/firestore.indexes.json).

## 9. Flutter application design

### 9.1 Shared state primitives

```dart
// lib/core/state/async_state.dart
sealed class AsyncState<T> { const AsyncState(); }
class AsyncIdle<T> extends AsyncState<T> { const AsyncIdle(); }
class AsyncLoading<T> extends AsyncState<T> { const AsyncLoading(); }
class AsyncData<T> extends AsyncState<T> { const AsyncData(this.value); final T value; }
class AsyncError<T> extends AsyncState<T> { const AsyncError(this.error); final AppException error; }

// lib/core/state/paged_state.dart
@freezed
class PagedState<T> with _$PagedState<T> {
  const factory PagedState({
    @Default([]) List<T> items,
    @Default(false) bool isLoadingFirst,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    AppException? error,
    Object? cursor, // DocumentSnapshot, kept opaque to the UI
  }) = _PagedState<T>;
}

// lib/core/state/page_result.dart — returned by repositories
// (named PageResult to avoid clashing with Flutter's Navigator `Page` class)
class PageResult<T> {
  const PageResult({required this.items, required this.hasMore, this.cursor});
  final List<T> items;
  final bool hasMore;
  final Object? cursor; // last DocumentSnapshot; opaque outside the data layer
}
```

> Naming note: the search controller is `SearchResultsController` (Flutter's Material library already has a `SearchController`).

### 9.2 Models (`lib/core/models/`)

`AppUser`, `ProviderProfile`, `ProviderHeadline`, `ProviderStats`, `Listing`, `ListingPhoto`, `Category`, `LocalizedText`, `City`, `Commune`, `Review`, `ContactRecord`, `Favorite`, `Report`, `VerificationRequest`. Every model is a `@freezed` class with `fromJson`/`toJson`, using `@TimestampConverter()` for timestamps and enums with `@JsonValue('snake_case')`.

```dart
@freezed
class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String providerId,
    required String title,
    @Default('') String description,
    required String categoryId,
    required PriceType priceType,
    double? priceAmount,
    required Currency currency,
    @Default([]) List<ListingPhoto> photos,
    required String city,
    @Default([]) List<String> communes,
    required ListingStatus status,
    @Default(false) bool visible,
    @Default(Moderation.ok) Moderation moderation,
    String? providerName,
    String? providerPhotoUrl,
    @Default(false) bool providerVerified,
    @Default(0) double ratingAvg,
    @Default(0) int ratingCount,
    LocalizedText? categoryName,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? publishedAt,
  }) = _Listing;
  factory Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);
}
```

Repositories map `DocumentSnapshot` → model by injecting the doc id (`{...doc.data()!, 'id': doc.id}`), and model → map with **client fields only** (`toCreateMap()` / `toUpdateMap()` extension methods), so server fields are never sent.

### 9.3 Repository interfaces (`features/*/domain/`)

```dart
abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  // Phone OTP: the production sign-in path. Provider-agnostic: Firebase SMS
  // today, a WhatsApp OTP provider may replace the implementation later.
  Future<void> verifyPhone(String e164, {bool resend = false}); // throws AuthFailure
  Future<void> confirmCode(String code, {bool reauthenticate = false}); // throws AuthFailure
  // No email/password in the Flutter app: staff sign in to the React admin app.
  Future<void> signOut();
}

abstract interface class UserRepository {
  Stream<AppUser?> watchUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(String uid, AppUserUpdate update);
  Future<void> deleteAccount(); // callable
  Future<void> registerDevice(String uid, String fcmToken);
}

abstract interface class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<City>> getLocations();
}

abstract interface class ProviderRepository {
  Future<ProviderProfile?> getProvider(String id);
  Stream<ProviderProfile?> watchProvider(String id);
  Future<PageResult<ProviderProfile>> fetchPopular({required String city, Object? cursor});
  Future<void> createProvider(ProviderProfileDraft draft);
  Future<void> updateProvider(String id, ProviderProfileUpdate update);
  Future<void> resubmit(String id);
}

abstract interface class ListingRepository {
  Future<Listing?> getListing(String id);
  Future<PageResult<Listing>> fetchByProvider(String providerId, {Object? cursor}); // public, visible only
  Stream<List<Listing>> watchMine(String uid);                                  // owner, all statuses
  Future<String> createDraft(ListingDraft draft);
  Future<void> update(String id, ListingUpdate update);
  Future<void> setStatus(String id, ListingStatus status);
  Future<void> delete(String id);
}

abstract interface class SearchRepository {
  Future<PageResult<Listing>> search(SearchQuery query, {Object? cursor});
}

abstract interface class MediaRepository {
  Future<UploadedImage> upload(XFile file, MediaKind kind, {String? listingId, void Function(double)? onProgress});
  Future<void> delete(String path);
  Future<String> thumbUrl(String path, ThumbSize size);
}

abstract interface class ReviewRepository {
  Future<PageResult<Review>> fetch(String providerId, {Object? cursor});
  Future<Review?> getMine(String providerId, String uid);
  Future<void> upsert(String providerId, ReviewDraft draft);
  Future<void> delete(String providerId, String uid);
}

abstract interface class ContactRepository {
  Future<void> record(ContactDraft draft); // set(merge) on contacts/{uid}_{pid}
  Stream<List<ContactRecord>> watchMine(String uid);
  Future<bool> hasContacted(String uid, String providerId);
}

abstract interface class FavoritesRepository {
  Stream<List<Favorite>> watch(String uid);
  Future<void> add(String uid, ProviderProfile provider);
  Future<void> remove(String uid, String providerId);
}

abstract interface class ReportRepository {
  Future<void> submit(ReportDraft draft);
}

abstract interface class VerificationRepository {
  Stream<VerificationRequest?> watch(String uid);
  Future<String> uploadDocument(XFile file, VerificationDocKind kind);
  Future<void> submit({required String idDocumentPath, required String selfiePath});
}
```

The admin panel is not part of the Flutter app: it lives in `/admin` (React). The moderation contract both sides share (callable names, enums, limits, `staffRoleFromClaims`) is in `/shared/moderation.ts`; the functions compile it (`functions/tsconfig.json` has `rootDir: ".."`, output under `lib/functions/src` and `lib/shared`) and the admin imports it as `@shared/moderation`.

### 9.4 Controllers (`features/*/presentation/`)

| Controller | Scope | Responsibilities |
|---|---|---|
| `PhoneAuthController` | global | Phone entry + OTP (E.164 normalisation, resend timer, `AuthFailure` reasons); the production sign-in path |
| `DeleteAccountController` | screen | Typed word → OTP re-confirmation → `deleteAccount` callable, retry-safe |
| `OnboardingController` | global | Persists completion of the first-launch intro |
| `SessionController` | global (proxy on `AuthRepository`) | Current `AppUser` + `ProviderProfile?` streams; `needsProfileSetup`, `isProvider`, `providerStatus`; registers FCM token |
| `LocaleController` | global | Locale from `shared_preferences` → user doc |
| `CatalogController` | global | Categories + locations cached; lookups by id |
| `ConnectivityController` | global | Online/offline flag for `OfflineBanner` |
| `RemoteConfigController` | global | Maintenance / force update flags |
| `FavoritesController` | global (proxy on session) | Favourite ids set + list; toggle |
| `HomeController` | screen | Popular providers, recent listings, refresh |
| `SearchResultsController` | screen | `SearchQuery` (keyword, category, commune, verifiedOnly, minRating, sort), debounced 400 ms, `PagedState<Listing>` |
| `ProviderProfileController` | screen | Provider, their listings, first page of reviews, `hasContacted`, my review |
| `ContactController` | screen-level helper | Ensures sign-in, records the contact, launches WhatsApp/tel, logs analytics |
| `WriteReviewController` | screen | Gate (sign-in / own profile / no contact yet / ready), rating 1–5, comment ≤ 300, publish, edit, delete |
| `ProviderReviewsController` | screen | Rating summary (from the provider document) + paged reviews, newest first |
| `ReportController` | sheet | Reason, details, submit |
| `ProviderOnboardingController` | screen (multi-step) | Steps: identity → categories → area → contact numbers → photos → review & submit |
| `ListingFormController` | screen | Create/edit; photo upload queue with progress; validation; publish/pause |
| `MyListingsController` | screen | `watchMine`, status changes, delete |
| `ProviderDashboardController` | screen | Status, stats, verification state |
| `VerificationController` | screen | Pick/upload ID + selfie, submit |
| `AccountController` | screen | Update profile, language, sign out, delete account |

Controller rules:
- Extend `ChangeNotifier`, expose **read-only getters** of immutable state, and call `notifyListeners()` only after state changes.
- Never import `cloud_firestore` or other Firebase packages; depend on repository interfaces.
- Cancel stream subscriptions in `dispose()`.
- Methods return `Future<void>` and catch `AppException`, storing it in state. UI errors are shown via the state, not via thrown exceptions.

### 9.5 Provider tree

```dart
// lib/app/app_providers.dart (abridged)
MultiProvider(
  providers: [
    // Firebase singletons
    Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
    Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
    Provider<FirebaseStorage>.value(value: FirebaseStorage.instance),
    Provider<FirebaseFunctions>.value(value: FirebaseFunctions.instanceFor(region: Env.functionsRegion)),

    // Services
    Provider<AnalyticsService>(create: (_) => FirebaseAnalyticsService()),
    Provider<LauncherService>(create: (_) => UrlLauncherService()),

    // Repositories (interfaces bound to Firebase implementations)
    Provider<AuthRepository>(create: (c) => FirebaseAuthRepository(c.read())),
    Provider<UserRepository>(create: (c) => FirestoreUserRepository(c.read(), c.read())),
    Provider<CatalogRepository>(create: (c) => FirestoreCatalogRepository(c.read())),
    Provider<ProviderRepository>(create: (c) => FirestoreProviderRepository(c.read())),
    Provider<ListingRepository>(create: (c) => FirestoreListingRepository(c.read())),
    Provider<SearchRepository>(create: (c) => FirestoreSearchRepository(c.read())),
    Provider<MediaRepository>(create: (c) => FirebaseMediaRepository(c.read(), c.read())),
    // … reviews, contacts, favorites, reports, verification

    // Global controllers
    ChangeNotifierProvider(create: (c) => PhoneAuthController(c.read())),
    ChangeNotifierProxyProvider<AuthRepository, SessionController>(
      create: (c) => SessionController(c.read(), c.read(), c.read()),
      update: (_, auth, session) => session!..onAuthChanged(auth.user),
    ),
    ChangeNotifierProvider(create: (c) => LocaleController(c.read())),
    ChangeNotifierProvider(create: (c) => CatalogController(c.read())..load()),
    ChangeNotifierProvider(create: (_) => ConnectivityController()),
    ChangeNotifierProxyProvider<SessionController, FavoritesController>(
      create: (c) => FavoritesController(c.read()),
      update: (_, session, fav) => fav!..onUserChanged(session.uid),
    ),
  ],
  child: child,
)
```

Screen-scoped example:

```dart
GoRoute(
  path: '/p/:providerId',
  builder: (context, state) => ChangeNotifierProvider(
    create: (c) => ProviderProfileController(
      providerId: state.pathParameters['providerId']!,
      providers: c.read(), listings: c.read(), reviews: c.read(), contacts: c.read(),
      session: c.read(),
    )..load(),
    child: const ProviderProfileScreen(),
  ),
),
```

In widgets, use `context.select` for fine-grained rebuilds, e.g. `context.select<SearchResultsController, bool>((c) => c.state.isLoadingMore)`.

### 9.6 Routes

| Path | Screen | Auth |
|---|---|---|
| `/splash` | Splash / bootstrap gate | — |
| `/welcome` | Language picker + intro slides (first launch) | — |
| `/home` | Accueil (tab 1) | signed in |
| `/explore` | Explorer: categories + search (tab 2) | signed in |
| `/publish` | Publier hub (tab 3): routes to sign-in / onboarding / status / new listing | signed in |
| `/messages` | Recent contacts + "chat coming soon" (tab 4) | signed in |
| `/me` | Profil (tab 5): account, favourites, provider space, settings | signed in |
| `/auth/phone` → `/auth/otp` → `/auth/profile` | Phone number (+243 default), one-time code, profile setup (`?from=` return path) | — |
| `/search?q=&cat=&commune=&verified=&sort=` | Results | signed in |
| `/category/:categoryId` | Results pre-filtered by category | signed in |
| `/p/:providerId` | Provider profile | signed in |
| `/l/:listingId` | Listing detail (photos, price, description, provider card, CTAs) | signed in |
| `/p/:providerId/reviews` | All reviews | signed in |
| `/p/:providerId/review` | Write/edit review | signed in + contacted |
| `/provider/onboarding` | Become a provider (multi-step) | signed in |
| `/provider/dashboard` | Provider space | provider |
| `/provider/listings/new`, `/provider/listings/:id/edit` | Listing form | approved provider (new) / owner (edit) |
| `/provider/verification` | ID verification | provider |
| `/me/language` | Language selector | — |
| `/me/favorites`, `/me/settings`, `/me/delete` | Account | signed in |
| `/legal/terms`, `/legal/privacy`, `/help` | Static pages (bundled Markdown) | — |
| `/update-required`, `/maintenance` | Remote Config gates | — |

Guards (in `guards.dart`, one `resolveRedirect`): level 1 no session → only `/welcome` and `/auth/phone` (+ OTP); level 2 session without `users/{uid}` → only `/auth/profile`; level 3 complete profile → the app, with provider-space routes needing `providers/{uid}` and `/admin` routes needing a staff claim (`/admin/categories|roles|logs` admin only). The `?from=` return path is not used in the sign-in-only beta.

**Admin web app (React, `/admin`):** v0 has only the sign-in and the reports queue. Planned screens: providers queue/detail, verifications, categories, audit log. Every route requires the `admin` or `moderator` claim (`getIdTokenResult(true)`); `/categories` and `/audit` (and role management) are admin-only, moderators get the moderation queues only.

### 9.7 Contact action (WhatsApp / call)

```
onTapContact(channel):
  if no session → /auth/phone (beta: the whole app is sign-in only)
  if provider is self → disabled
  record contact (fire-and-forget, offline-queued)
  analytics.log('contact_tap', {channel, provider_id, listing_id, category_id})
  whatsapp: launch https://wa.me/{e164 without '+'}?text={urlencoded message}
  call:     launch tel:{e164}
  LaunchMode.externalApplication; on failure show snackbar "WhatsApp n'est pas installé" with copy-number action
```

Pre-filled message (FR): `Bonjour {providerName}, je vous ai trouvé sur Kazi pour « {listingTitle} ». Êtes-vous disponible ?` (EN equivalent in ARB).

### 9.8 Phone numbers

- A user's verified phone number (E.164) is their account identity (`users/{uid}.phone`, phone OTP via `AuthRepository.verifyPhone`/`confirmCode`). Phone numbers are also provider contact details. Input with a country picker defaulting to **CD (+243)**, using `phone_numbers_parser`. Accept national formats (`0812345678`, `812345678`) and normalise to E.164.
- Validate as a **mobile** number for the selected country.
- Display format: `+243 81 234 5678`.

### 9.9 Localisation

- `l10n.yaml`: `arb-dir: lib/core/l10n`, `template-arb-file: app_fr.arb`, `output-localization-file: app_localizations.dart`.
- Supported locales: `fr` (default and fallback), `en`.
- Key naming: `screenName_element_purpose`, e.g. `home_search_hint`, `listing_price_from`.
- Plurals and placeholders use ICU syntax (`{count, plural, =0{Aucun avis} =1{1 avis} other{{count} avis}}`).
- Currency formatting: USD → `10 $` (fr) / `$10` (en); CDF → `15 000 FC` / `CDF 15,000`, via `NumberFormat`.

### 9.10 Error handling

`AppException` (sealed) with codes: `network`, `permissionDenied`, `notFound`, `invalidInput`, `rateLimited`, `tooManyRequests`, `quotaExceeded`, `unauthenticated`, `unknown`. `error_mapper.dart` maps `FirebaseException` / `FirebaseAuthException` / `FirebaseFunctionsException` codes to these. Each code has a localised message key `error_{code}`. Unknown errors are reported to Crashlytics with the original exception.

### 9.11 Analytics

Implement events from PRD §9 in `AnalyticsService`. Event names are lower_snake_case and parameters primitive. **No PII** (no names or phone numbers) in parameters; IDs only.

## 10. Admin panel

A separate **React + TypeScript** web app in `/admin` (Vite, Firebase JS SDK, no UI framework), deployed to Firebase Hosting target `admin` with `noindex` (meta tag, `robots.txt`, `X-Robots-Tag`), `X-Frame-Options: DENY` and `no-referrer`.

- **Auth:** email/password. After every sign-in and on every page load the ID token is force-refreshed and its claims read; only `admin` or `moderator` stay (`staffRoleFromClaims` in `/shared`). Anyone else is signed out at once with a message; if the claims cannot be read the app fails closed. A staff claim is enough to be "signed in" in the rules: no phone and no consumer profile.
- **Data access:** reads Firestore directly (the rules allow staff reads) and **never writes it**; every change goes through callables (`moderator_*`, later `admin_*`). The check is structural: the Firebase service layer exposes only `listOpenReports`, `loadTarget` and the four callable wrappers.
- **v0 scope: Reports queue only.** Open reports (`status == open`, newest first, max 500; composite index `reports(status, createdAt desc)`), grouped by target with a count and a reason tally, showing the target (listing title and first photo, or provider name and status). Actions through confirm dialogs with an optional note (a reason of at least 3 characters for suspend) and loading / success / error states: **Hide** / **Restore** a listing, **Suspend** a provider, **Dismiss** (closes every open report on the target). Restore is disabled for a listing hidden for `over_limit`; a deleted target can only be dismissed.
- **Languages:** French and English (browser language, switchable, remembered).
- **Config:** Firebase web config per environment in `admin/.env.development` / `.env.production` (public client config, not secrets); `VITE_USE_EMULATORS=true` points the app at the local emulators.
- **CI:** job `admin` runs lint, typecheck, tests and the build.
- **Staff accounts:** created in the Firebase console (email/password), then `scripts/set-claims.ts --project <p> --email <e> --role admin|moderator|none` (needs Application Default Credentials; `--confirm-prod` for `kazi-prod`; the user must sign in again).

## 11. Error codes (Functions → app)

| HttpsError code | Meaning | App mapping |
|---|---|---|
| `unauthenticated` | Not signed in | `unauthenticated` |
| `permission-denied` | Missing claim / not owner | `permissionDenied` |
| `invalid-argument` | Zod validation failed | `invalidInput` |
| `failed-precondition` | e.g. not a provider, files missing | `invalidInput` |
| `resource-exhausted` | Rate limit | `rateLimited` |
| `not-found` | Target missing | `notFound` |
| `internal` | Unexpected | `unknown` |

## 12. Limits (single source: `lib/core/constants/limits.dart` and `functions/src/config.ts`; the listing limit is the exception — it lives in Firestore `config/limits`)

| Limit | Value |
|---|---|
| Listings per provider (active + paused) | 10 in v1 (free). **Live value: Firestore `config/limits.maxListingsPerProvider`** (§4.11a); `Limits.maxListingsPerProvider` and `DEFAULT_MAX_LISTINGS_PER_PROVIDER` are fallbacks only |
| Photos per listing | 6 |
| Portfolio photos | 12 |
| Categories per provider | 3 |
| Communes served | 10 |
| Bio | 600 chars |
| Listing title / description | 4–80 / 1000 chars |
| Review text | 500 chars |
| Report details | 500 chars |
| Upload size (media / private) | 2 MB / 5 MB after compression |
| Minimum password length | 6 characters |
| Auto-hide threshold | 3 open reports |
| Contact counting cooldown | 10 min per client–provider pair |
| Page size | 20 |

## 13. Seed and scripts

| Script | Purpose |
|---|---|
| `scripts/seed-categories.ts` | Upsert §4.10 categories from `assets/data/categories.json` (dev only; idempotent; dev wipe of placeholder data) |
| `scripts/seed-locations.ts` | Write `config/locations` (§4.11) |
| `scripts/seed-demo.ts` | **dev/emulator only**: 10 fake providers, 25 listings, reviews and contacts with placeholder images |
| `scripts/set-claims.ts` | Grant/revoke `superAdmin`, `admin`, `moderator` |

All scripts take `--project kazi-dev|kazi-prod` and refuse to run `seed-demo` against prod.
