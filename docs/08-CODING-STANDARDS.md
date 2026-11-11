# Kazi — Coding Standards & Conventions

| | |
|---|---|
| **Version** | v1.0 |
| **Applies to** | Humans and AI coding agents |

---

## 1. Dart / Flutter

### 1.1 Style
- `dart format` (80 cols default). CI fails on unformatted code.
- `analysis_options.yaml` includes `flutter_lints` plus: `always_declare_return_types`, `prefer_const_constructors`, `prefer_final_locals`, `avoid_print`, `unawaited_futures`, `require_trailing_commas`, `directives_ordering`, `sort_constructors_first`, `use_build_context_synchronously`. Zero analyzer warnings.
- Files: `snake_case.dart`; one public class per file (small private widgets allowed).
- Names: classes `PascalCase`; members `camelCase`; constants `camelCase` in a `abstract final class Limits { static const maxPhotos = 6; }`.

### 1.2 Architecture rules (enforced in review)
1. **Presentation → controllers → repository interfaces → data.** Never skip a layer.
2. Widgets and controllers **must not import** `cloud_firestore`, `firebase_storage`, `firebase_auth` or `cloud_functions`. Only `features/*/data/` and `bootstrap.dart` may.
3. Controllers extend `ChangeNotifier`, hold immutable state (`freezed`), and expose getters, never mutable fields.
4. No `BuildContext` in controllers. Navigation happens in widgets, in response to state or method results.
5. Use `context.read<T>()` in callbacks and `context.watch<T>()` / `context.select` in `build`. Never `watch` inside callbacks.
6. Screen-scoped controllers are created in the route builder with `ChangeNotifierProvider(create: …)`.
7. Firestore paths come only from `core/constants/firestore_paths.dart`; Storage paths only from `storage_paths.dart`.
8. Limits come only from `core/constants/limits.dart` (mirrors `functions/src/config.ts`).
9. **No hard-coded user-facing strings.** Use `AppLocalizations.of(context)`. Add keys to both `app_fr.arb` and `app_en.arb` in the same PR.
10. **No hard-coded colours, font sizes or radii in widgets.** Use `KaziColors`, `Theme.of(context).textTheme`, `KaziSpacing`, `KaziRadius`.
11. Images go through `KaziNetworkImage` (thumb handling + caching); picking/uploading goes through `ImageService` + `MediaRepository`.
12. External links go through `LauncherService`.

### 1.3 Models
- `@freezed` with `fromJson`/`toJson`; run `dart run build_runner build --delete-conflicting-outputs`.
- Generated files (`*.freezed.dart`, `*.g.dart`) **are committed**, so CI and agents don't depend on codegen ordering.
- Server fields have defaults and are excluded from `toCreateMap()` / `toUpdateMap()`.

### 1.4 Async and errors
- All repository methods throw only `AppException` (mapped in the data layer).
- `unawaited(...)` explicitly for fire-and-forget calls (e.g. `recordContact`).
- Streams: subscribe in the controller, cancel in `dispose`.

### 1.5 Widgets
- Prefer `StatelessWidget` + controller; `StatefulWidget` only for local UI state (animations, text controllers).
- Extract widgets over 80 lines or used twice.
- Every screen has a `Key`-free public constructor and a `routeName`/`path` constant in `routes.dart`.

## 2. TypeScript (Cloud Functions)

- `strict: true`, ESLint (`@typescript-eslint/recommended`), Prettier.
- One function per file; `index.ts` only re-exports.
- Callables: `onCall({ region, enforceAppCheck: true }, handler)`. Validate `request.data` with a `zod` schema at the top. Throw `HttpsError` with codes from TDD §11.
- Triggers must be **idempotent** and loop-safe (compare before/after, and only write when values change).
- Use `logger` from `firebase-functions`, structured (`logger.info('provider_approved', { providerId })`). No PII.
- Shared constants live in `src/config.ts` and must match `limits.dart`.

## 3. Git workflow

- Trunk-based: `main` is always releasable. Short-lived branches: `feat/KZ-123-provider-onboarding`, `fix/KZ-140-otp-resend`, `chore/…`, `docs/…`.
- **Conventional Commits**: `feat(search): add commune filter`, `fix(rules): deny verified write`, `test(functions): review delta cases`.
- PR template checklist: linked story, screenshots for UI, tests added, ARB keys in both languages, rules tests if data changed, docs updated if a contract changed.
- Squash merge; PR title = conventional commit.
- Version: `pubspec.yaml` `version: x.y.z+build`; build number increases monotonically for Play.

## 4. Definition of Done (per story)

- [ ] Acceptance criteria met (see [Backlog](07-BACKLOG-ROADMAP.md)).
- [ ] Unit/widget tests added; CI green; zero analyzer warnings.
- [ ] Loading / empty / error / offline states implemented.
- [ ] FR + EN strings; no overflow at 1.3× text scale.
- [ ] Analytics events added if listed in PRD §9.
- [ ] Rules + rules tests updated if data access changed.
- [ ] Docs updated if a contract (field, enum, limit, route) changed.
- [ ] Verified on a physical low-end Android device (or emulator with a low-RAM profile) for UI stories.
