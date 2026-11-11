# Kazi — Backlog, Stories & Sprint Plan (v1)

| | |
|---|---|
| **Version** | v1.0 |
| **Cadence** | 2-week sprints, solo developer + AI agents |
| **Target** | MVP in Play closed testing after Sprint 5 (~10 weeks), public launch after Sprint 6 |

Story IDs (`KZ-xxx`) are referenced in branch names and commits. **Agents take one story at a time**, in order, unless dependencies say otherwise. Each story's acceptance criteria (AC) and the [Definition of Done](08-CODING-STANDARDS.md#4-definition-of-done-per-story) must be met.

---

## Epic map

| Epic | Name | Stories |
|---|---|---|
| E0 | Foundations | KZ-001 – KZ-012 |
| E1 | Auth & account | KZ-020 – KZ-027 |
| E2 | Catalog & discovery | KZ-030 – KZ-039 |
| E3 | Provider profile & contact | KZ-040 – KZ-046 |
| E4 | Provider onboarding & listings | KZ-050 – KZ-058 |
| E5 | Reviews, favourites, reports | KZ-060 – KZ-066 |
| E6 | Cloud Functions | KZ-070 – KZ-079 |
| E7 | Admin panel | KZ-080 – KZ-087 |
| E8 | Verification & notifications | KZ-090 – KZ-094 |
| E9 | Launch readiness | KZ-100 – KZ-108 |

---

## E0 — Foundations

**KZ-001 Project scaffolding.** Flutter app at repo root with `dev`/`prod` flavors, folder structure from TDD §2, `analysis_options.yaml`, `l10n.yaml`, Montserrat bundled.
- AC: `flutter run --flavor dev` shows a placeholder screen; `dart analyze` clean; the folder tree matches TDD §2.

**KZ-002 Firebase wiring.** `flutterfire configure` for both projects; `bootstrap.dart` per TDD §3.2 (App Check, emulators, persistence, Crashlytics, Remote Config).
- AC: with `USE_EMULATORS=true` the app connects to the local emulators (verified by a debug log); Crashlytics test crash appears in `kazi-dev`.

**KZ-003 Functions scaffolding.** `functions/` TS project, `config.ts`, lint, build, vitest, emulator test script; `firebase.json` with emulators, rules, indexes and hosting targets.
- AC: `npm test` runs inside `firebase emulators:exec` and passes a sample test.

**KZ-004 Rules & indexes baseline.** Copy `docs/firebase/*` into place; write the full rules test suite from Test plan §2.3.
- AC: all listed allow/deny cases pass in CI.

**KZ-005 CI pipeline.** `ci.yml` per Ops §3.
- AC: a PR with a formatting error fails; a clean PR passes.

**KZ-006 Theme & tokens.** `KaziColors`, typography, spacing, radius, `ThemeData` per UI spec §2.
- AC: golden/widget test renders a sample of every text style and colour token.

**KZ-007 Design-system widgets (part 1).** `KaziButton`, `KaziChip`, `KaziTextField`, `KaziTextArea`, `KaziSearchBar`, `SectionHeader`, `EmptyState`, `ErrorView`, `OfflineBanner`, `SkeletonBox`, plus the `/dev/components` catalogue.
- AC: widget tests per variant; catalogue screen visible in dev only.

**KZ-008 Design-system widgets (part 2).** `ProviderCard`, `ProviderListItem`, `CategoryCircle`, `RatingStars`, `VerifiedBadge`, `KaziAvatar`, `KaziNetworkImage`, `StatTile`, `ContactBar`, `CurrencyToggle`, `StepperBar`, `PromoBanner`.
- AC: match Figma components visually (screenshot comparison in PR); widget tests.

**KZ-009 Core utils.** `text_normalize.dart` (TDD §8.1 + vectors), `phone.dart` (Test plan §2.2), `formatters.dart` (prices FR/EN, dates), `AppException` + `error_mapper`.
- AC: unit tests pass, including all vectors.

**KZ-010 Models.** All freezed models from TDD §9.2 with converters and `toCreateMap`/`toUpdateMap`.
- AC: JSON round-trip tests; server fields excluded from create/update maps.

**KZ-011 Router & shell.** `go_router` with `StatefulShellRoute` (5 tabs), `KaziBottomNav`, guards (stubbed session), route constants.
- AC: tabs keep state; `/p/abc` deep link opens a placeholder profile.

**KZ-012 Localisation baseline.** `app_fr.arb` (template) + `app_en.arb`; ARB parity check script in CI.
- AC: CI fails when a key is missing in one file.

## E1 — Auth & account

**KZ-020 Welcome & language.** S02 screens; locale persisted locally.
- AC: first launch shows the language picker; second launch skips it; changing language updates the UI immediately.

**KZ-021 Phone sign-in + OTP.** `AuthRepository`, `AuthController`, S03/S04 with country picker (default CD), terms checkbox, 60 s resend, error mapping.
- AC: emulator test number signs in; wrong code shows `error_otpInvalid`; resend disabled for 60 s; Android SMS auto-retrieval works on a real device.

**KZ-022 Profile setup.** S05; creates `users/{uid}` per rules; optional avatar upload.
- AC: user doc matches TDD §4.3; rules accept it; returning users skip this screen.

**KZ-023 Session controller & guards.** `SessionController` streams user + provider; guards redirect with `?from=`.
- AC: a guest tapping a protected action returns to the same screen after sign-in.

**KZ-024 Account screen (S20) & settings.** Edit name/photo/commune, language, legal pages (bundled Markdown), help, sign out.
- AC: edits persist; sign-out returns to home as a guest.

**KZ-025 Delete account (client).** S22 confirmation + call to `deleteAccount` (KZ-077).
- AC: after deletion the app is signed out and the user can't read their old data.

**KZ-026 Remote Config gates.** Force update + maintenance screens (S23).
- AC: setting `min_supported_build` above the current build shows the blocking screen.

**KZ-027 Connectivity.** `ConnectivityController` + `OfflineBanner` on all tab screens.
- AC: toggling airplane mode shows/hides the banner within 2 s.

## E2 — Catalog & discovery

**KZ-030 Seed scripts.** Categories + locations (TDD §4.10–4.11) + demo seed for dev.
- AC: scripts are idempotent; `seed-demo` refuses prod.

**KZ-031 CatalogRepository & controller.** Cached categories/locations with offline first-launch fallback.
- AC: works offline after one online launch.

**KZ-032 Home screen (S06).** Location chip (commune picker sheet), search bar, category row, promo banner, popular providers (providers query), recent listings.
- AC: matches Figma 01; skeletons while loading; pull to refresh; tapping a category opens results.

**KZ-033 SearchRepository.** Query planning per TDD §8.2 with pagination.
- AC: unit tests for each planner branch using `fake_cloud_firestore`; queries match indexes.

**KZ-034 Results screen (S08) + filters sheet (S09).** `SearchResultsController` with debounce, chips, sorting, infinite scroll.
- AC: matches Figma 02; filters reflected in the URL query; empty state with a suggestion.

**KZ-035 Explorer tab (S07).** Category grid, search field, local recent searches (max 10).
- AC: recent searches persist across launches.

**KZ-036 Listing detail (S11).** Photo carousel (thumb 800), price, description, communes, provider mini-card.
- AC: opens from search and deep link `/l/:id`.

## E3 — Provider profile & contact

**KZ-040 Provider profile (S10).** `ProviderProfileController`; cover, avatar, stats, bio, listings, portfolio, reviews preview.
- AC: matches Figma 03; pending providers show "not found" to others.

**KZ-041 Contact action.** `ContactController`, `LauncherService`, contact record, analytics, sticky `ContactBar`.
- AC: guest flow per J1; contact doc created/updated; WhatsApp message pre-filled in the user's language; fallback snackbar with copy number.

**KZ-042 Messages tab (S19).** Recent contacts list + "chat coming soon" banner.
- AC: shows contacts ordered by `lastAt`; quick re-contact buttons.

**KZ-043 Share provider.** `share_plus` with the profile link + message.
- AC: shared link opens the profile via App Links when the app is installed and the web landing page otherwise.

**KZ-044 Block user.** Block/unblock from a provider profile and review items; hide blocked users' content client-side.
- AC: blocked provider disappears from results for that user.

## E4 — Provider onboarding & listings

**KZ-050 Publier hub (S14).** Contextual states for guest / non-provider / pending / rejected / approved / suspended.
- AC: each state renders correctly with the seed data.

**KZ-051 Provider onboarding (S15).** 5-step form, validation, avatar/cover upload, public-number consent, creates `providers/{uid}` (pending).
- AC: rules accept; resuming after app kill restores the draft (local); rejected providers can edit and resubmit.

**KZ-052 MediaRepository & ImageService.** Pick, compress (TDD §7), upload with progress, thumb URL resolution, delete.
- AC: uploaded image ≤ 2 MB; thumbs resolve after the extension runs; fallback to the original meanwhile.

**KZ-053 Listing form (S16).** Create/edit, draft-first flow, up to 6 photos, price types, currency toggle, communes; publish/pause.
- AC: matches Figma 04; quote hides the amount; "Publication en cours…" until visible.

**KZ-054 My listings & provider dashboard (S17).** Status card, stats, listing actions (edit, pause/resume, delete with confirm).
- AC: real-time updates; delete removes the listing and its photos (via KZ-071).

**KZ-055 Portfolio management.** Add/remove up to 12 portfolio photos.
- AC: profile shows the portfolio grid.

## E5 — Reviews, favourites, reports

**KZ-060 Reviews list & summary.** Paged reviews on `/p/:id/reviews`.
- AC: shows average, count and the list with author snapshots.

**KZ-061 Write/edit/delete review (S12).** Only when contacted; one per provider.
- AC: the button is hidden or explains "Contactez d'abord ce prestataire" when not eligible; rating updates after the function runs.

**KZ-062 Favourites.** Toggle on cards/profile; favourites screen (S21).
- AC: works offline (queued); survives reinstall (server-side).

**KZ-063 Report sheet (S13).** For listing, provider and review.
- AC: second report on the same target by the same user shows "Déjà signalé".

**KZ-064 Provider review reply (P2).**
- AC: provider can reply once; reply shows under the review.

## E6 — Cloud Functions

**KZ-070 Normalise + keywords lib (TS)** with shared test vectors. *Depends on KZ-009.*
**KZ-071 `onListingWritten`** (denormalise, visibility, keywords, content checks, counters, Storage cleanup).
**KZ-072 `onProviderWritten`** (propagation, keywords, `isProvider`, loop safety).
**KZ-073 `onReviewWritten`** (rating deltas in a transaction).
**KZ-074 `onContactWritten`** (stats with cooldown).
**KZ-075 `onReportCreated`** (auto-hide threshold, logs).
**KZ-076 Notifications lib** (localised FCM, token cleanup).
**KZ-077 `deleteAccount` callable** (TDD §6.5).
**KZ-078 Scheduled cleanups** (verification files, stale drafts).
**KZ-079 Admin callables** (`admin_setProviderStatus`, `admin_resolveReport`, `admin_upsertCategory`, `admin_setRole`) + `adminLogs`.
- AC for all E6 stories: Test plan §2.4 cases pass in the emulator; functions are idempotent; no PII in logs.

## E7 — Admin panel (Flutter Web)

**KZ-080 Admin shell & auth.** `main_admin.dart`, login, claim check, navigation rail.
**KZ-081 Providers queue & detail.** Filter by status; approve/reject with reason; see listings.
**KZ-082 Reports queue.** Grouped by target; actions per TDD §6.3.
**KZ-083 Verification queue.** Signed-URL viewer; approve/deny (with KZ-091).
**KZ-084 Categories management.**
**KZ-085 Audit log view.**
**KZ-086 Dashboard counts** (P2).
**KZ-087 Hosting deploy target `admin`.**
- AC: no direct Firestore writes from the admin app (code search check); every action produces an `adminLogs` entry.

## E8 — Verification & notifications

**KZ-090 Verification flow (S18)** client upload + `submitVerification`.
**KZ-091 `submitVerification`, `admin_getVerificationFiles`, `admin_decideVerification`** callables.
**KZ-092 FCM client.** Permission prompt (Android 13+), token registration in `devices`, foreground display, tap → deep link.
**KZ-093 Notification triggers** wired to admin decisions (uses KZ-076).
**KZ-094 Verified badge everywhere** (cards, list items, profile, search filter).

## E9 — Launch readiness

**KZ-100 Analytics events** (PRD §9) + debug view verification.
**KZ-101 Legal pages** (Terms, Privacy FR/EN) on Hosting + in-app; `/delete-account` page.
**KZ-102 Share landing page `/p/:id`** + `assetlinks.json` for App Links.
**KZ-103 App icon, splash, store listing assets.**
**KZ-104 Performance pass** (Test plan §4) on a low-end device.
**KZ-105 Accessibility pass** (UI spec §8).
**KZ-106 App Check enforcement** switched from monitor to enforce in prod.
**KZ-107 Release pipeline** (`release.yml`, Play internal track).
**KZ-108 Closed beta** with seeded real providers; triage feedback.

---

## Sprint plan

| Sprint | Weeks | Goal | Stories |
|---|---|---|---|
| **S0** | 1–2 | Foundations ready | KZ-001 → KZ-012, KZ-030 |
| **S1** | 3–4 | Sign-in + browse | KZ-020 → KZ-024, KZ-027, KZ-031, KZ-032, KZ-070, KZ-071, KZ-072 |
| **S2** | 5–6 | Search + profiles + contact | KZ-033 → KZ-036, KZ-040 → KZ-043, KZ-074 |
| **S3** | 7–8 | Providers can publish | KZ-050 → KZ-055, KZ-080, KZ-081, KZ-079, KZ-076, KZ-093 |
| **S4** | 9–10 | Trust & safety | KZ-060 → KZ-063, KZ-073, KZ-075, KZ-082, KZ-044, KZ-025, KZ-077 |
| **S5** | 11–12 | Verification + launch prep → **closed beta** | KZ-090 → KZ-092, KZ-094, KZ-083, KZ-084, KZ-085, KZ-087, KZ-026, KZ-078, KZ-100 → KZ-107 |
| **S6** | 13–14 | Beta fixes → **public launch** | KZ-108, bug fixes, KZ-064, KZ-086 |

**Parallel non-dev work (owner):** legal entity and Play developer account (start in S0), domain, privacy policy review, recruiting 50–100 providers (S3–S5), moderator onboarding (S4).
