# AGENTS.md — Instructions for AI coding agents working on Kazi

> This file lives at the **repository root**. `CLAUDE.md` contains one line, `See AGENTS.md`.

## 1. What you're building

Kazi is a free Android-first marketplace app for local services in the DRC (Kinshasa first). Clients find providers and contact them via WhatsApp or a phone call. Providers publish service listings. Admins moderate through a Flutter Web panel.

**Stack (non-negotiable):** Flutter (Dart 3) · Firebase (Auth phone OTP, Firestore, Storage, Functions 2nd gen in TypeScript, FCM, Remote Config, App Check, Analytics, Crashlytics, Hosting) · **Provider** for state management · go_router · freezed.

## 2. Read before coding (in this order)

1. `docs/03-TDD.md`: contracts (collections, fields, enums, limits, routes, repositories, controllers). **Authoritative.**
2. `docs/08-CODING-STANDARDS.md`: architecture rules and Definition of Done.
3. `docs/07-BACKLOG-ROADMAP.md`: find the story you were assigned (`KZ-xxx`) and its acceptance criteria.
4. `docs/04-UI-UX-SPEC.md`: tokens, components and screen inventory for any UI work. The Figma file is the visual reference.
5. `docs/06-TEST-PLAN.md`: required tests for your area.
6. `docs/09-DEVOPS-RELEASE.md`: environment setup, CI/CD workflows, deploy targets and release process.
7. `docs/01-PRD.md` and `docs/02-ADD.md`: product and architecture context when needed.

## 3. Hard rules

1. **State management = `provider` + `ChangeNotifier` only.** Do not add Riverpod, Bloc, GetX, MobX or Redux.
2. **Layering:** widgets → controllers → repository interfaces → Firebase implementations. Firebase packages are imported **only** in `lib/features/*/data/`, `lib/bootstrap.dart` and `lib/app/app_providers.dart`.
3. **Never let the client write server-only fields** (`visible`, `verified`, `status` transitions other than the allowed ones, `rating*`, `listingCount`, `searchKeywords`, `stats`, denormalised `provider*` fields, `moderation*`). See TDD §4.
4. **Do not invent** collection names, field names, enum values, limits or routes. If something is missing, update `docs/03-TDD.md` in the same PR and say so in the PR description.
5. **Any change to data shape or access** requires updating `firestore.rules` / `storage.rules` **and** the rules tests (allow + deny).
6. **No hard-coded strings, colours or text sizes** in widgets. Add ARB keys to both `app_fr.arb` and `app_en.arb`; use theme tokens.
7. **Do not add packages** that aren't in TDD §1.2 / §1.3 without updating that table and explaining why.
8. **Never commit secrets** (service account keys, keystores, `.env`). Never run seed-demo or destructive scripts against `kazi-prod`.
9. **Don't deploy to production.** Agents may run emulators and deploy to `kazi-dev` only when explicitly asked. Use `firebase use dev` / `--project dev`; the alias maps to `kazi-dev-8099c`.
10. Keep generated files (`*.freezed.dart`, `*.g.dart`) committed and up to date.

## 4. Commands

```bash
# Flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
dart analyze
flutter test
flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev --dart-define=USE_EMULATORS=true

# Admin web
flutter run -d chrome -t lib/main_admin.dart --dart-define=FLAVOR=dev --dart-define=USE_EMULATORS=true

# Functions + rules tests
cd functions && npm ci && npm run lint && npm run build
firebase emulators:exec --only firestore,storage,auth,functions "npm --prefix functions test"

# Local backend
firebase emulators:start --import=./.emulator-data --export-on-exit
npx ts-node scripts/seed-demo.ts --emulator
```

## 5. Workflow per story

1. Create branch `feat/KZ-xxx-short-name` (or `fix/…`).
2. Restate the story's acceptance criteria as a checklist in your working notes or PR description.
3. Implement in small commits using Conventional Commits (`feat(listings): …`).
4. Add or extend tests per the test plan. Run format, analyze, tests and (if touched) the functions/rules tests.
5. For UI: implement loading, empty, error and offline states, and check FR + EN at 1.3× text scale.
6. Open a PR with: story ID, summary, screenshots or GIF for UI, test evidence, and any doc changes.
7. Stop and ask the owner when: acceptance criteria conflict with the TDD, a new package or field seems necessary, a rule needs loosening, or a task needs production access.

## 6. Patterns to copy

**Screen-scoped controller**
```dart
GoRoute(
  path: Routes.search,
  builder: (context, state) => ChangeNotifierProvider(
    create: (c) => SearchResultsController(search: c.read(), analytics: c.read())
      ..init(SearchQuery.fromUri(state.uri)),
    child: const SearchScreen(),
  ),
);
```

**Controller skeleton**
```dart
class SearchResultsController extends ChangeNotifier {
  SearchResultsController({required SearchRepository search, required AnalyticsService analytics})
      : _search = search, _analytics = analytics;

  final SearchRepository _search;
  final AnalyticsService _analytics;

  PagedState<Listing> _state = const PagedState();
  PagedState<Listing> get state => _state;

  Future<void> loadFirstPage() async {
    _state = _state.copyWith(isLoadingFirst: true, error: null);
    notifyListeners();
    try {
      final page = await _search.search(_query);
      _state = PagedState(items: page.items, hasMore: page.hasMore, cursor: page.cursor);
    } on AppException catch (e) {
      _state = _state.copyWith(isLoadingFirst: false, error: e);
    }
    notifyListeners();
  }
}
```

**Widget consumption**
```dart
final isLoading = context.select<SearchResultsController, bool>((c) => c.state.isLoadingFirst);
```

## 7. Definition of Done

See `docs/08-CODING-STANDARDS.md` §4. A story isn't done if any analyzer warning, failing test, missing translation, missing state (loading/empty/error/offline) or missing rules test remains.
