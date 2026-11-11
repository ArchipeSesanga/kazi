# Kazi — UI/UX Specification

| | |
|---|---|
| **Version** | v1.0 |
| **Figma** | [DRC Services App — UI Design](https://www.figma.com/design/HsRApYAHwq03Tun0mQdh3C) (page "UI · v1") |
| **Related** | [PRD](01-PRD.md) · [TDD](03-TDD.md) §9 |

> Figma is the visual reference and this document is the build contract. Where Figma is missing a screen, build it from the components and tokens below; don't invent new colours, sizes or fonts.

---

## 1. Design principles

1. **WhatsApp-first:** the WhatsApp button is the primary action on every provider surface.
2. **Data-light:** thumbnails, skeletons instead of spinners, no autoplay media, no decorative images downloaded at runtime.
3. **Trust is visible:** verified badge, rating and review count always appear next to a provider's name.
4. **Thumb-friendly:** primary actions in the bottom 40% of the screen; 48 dp minimum touch targets.
5. **Plain French:** short sentences, no jargon; English mirrors French.

## 2. Design tokens

### 2.1 Colour (`lib/core/theme/kazi_colors.dart`)

| Token | Hex | Use |
|---|---|---|
| `accent` | `#F25912` | Key actions: "+ Publier", filter button, primary form submit ("Continuer", "Publier"), notification dot |
| `primary` | `#5C3E94` | Brand: logo, active chips, verified badge, outline buttons, selected states, links |
| `primaryDark` | `#412B6B` | Pressed states, "Voir tout" links, gradient ends |
| `ink` | `#211832` | Primary text, icons |
| `body` | `#3D3550` | Long-form body text |
| `muted` | `#6E6684` | Secondary text, placeholders, inactive nav |
| `primaryLight` | `#D9CFF0` | Category circle stroke, subtle borders on brand surfaces |
| `primarySurface` | `#F1ECFA` | Category circle fill, tags ("Vérifié"), add-photo tile |
| `surfaceAlt` | `#F5F3F8` | Chips (inactive), stats card, list separators |
| `border` | `#D9D9D9` | Input borders, dividers |
| `surface` | `#FFFFFF` | Backgrounds, cards |
| `whatsapp` | `#25D366` | WhatsApp button only |
| `star` | `#F5B700` | Rating stars only |
| `error` | `#D92D20` | Errors, destructive actions |
| `success` | `#12B76A` | Success snackbars |

Gradients (placeholders and banners): `primary → primaryDark`, `#5C3E94 → #211832` (promo banner).

Contrast: white on `accent` is ~3.4:1, which passes for **bold text ≥ 14 px or regular ≥ 18 px** (WCAG large text). Button labels on accent must be **≥ 15 px SemiBold/Bold**. Never use accent for small body text.

### 2.2 Typography (`kazi_typography.dart`)

Font: **Montserrat**, bundled in `assets/fonts/` (Regular 400, Medium 500, SemiBold 600, Bold 700).

| Style | Size / line height | Weight | Use |
|---|---|---|---|
| `displayLarge` | 28 / 34 | Bold | Onboarding titles |
| `headlineMedium` | 24 / 30 | Bold | Provider name on profile |
| `titleLarge` | 18 / 24 | Bold | Screen titles, section headers |
| `titleMedium` | 16 / 22 | Bold | List item names |
| `titleSmall` | 14 / 20 | Bold | Card names, prices |
| `bodyLarge` | 15 / 22 | Regular | Form inputs |
| `bodyMedium` | 14 / 21 | Regular | Body text |
| `bodySmall` | 12 / 17 | Regular | Meta (commune, distance) |
| `labelLarge` | 15 / 20 | Bold | Buttons |
| `labelMedium` | 12 / 16 | SemiBold | Chips, small buttons |
| `labelSmall` | 10–11 / 14 | Medium | Nav labels, tags |

Text must stay usable at 130% system scale. Avoid fixed-height containers around text.

### 2.3 Spacing, radius, elevation

- Spacing scale (dp): `4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32`. Screen horizontal padding **20**.
- Radius: chips **16** (pill), buttons/inputs **12**, cards **14**, banner **16**, sheets **22** (top), avatars full circle.
- Elevation: cards and search bar use one shadow, `0 2 8 rgba(18,24,32,0.12)`. The "+ Publier" button uses an accent shadow `0 4 10 rgba(242,89,18,0.40)`.

### 2.4 Icons

Lucide via `lucide_icons_flutter`; stroke 2; sizes 12 (inline meta), 16–18 (buttons), 20–22 (nav, app bar), 24 (category circles).

## 3. Navigation model

Bottom navigation with 5 items: **Accueil** (home), **Explorer** (search), **+ Publier** (raised accent circle, no label), **Messages**, **Profil**. The tab state is preserved per branch (`StatefulShellRoute`).

## 4. Screen inventory

Status: **F** = designed in Figma, **N** = new; build from components.

| # | Screen | Status | Key elements |
|---|---|---|---|
| S01 | Splash | N | Logo mark on `primary`, no network wait > 3 s |
| S02 | Welcome / language | N | FR / EN choice, 3 intro slides (find, contact on WhatsApp, offer your services), "Commencer" |
| S03 | Phone sign-in | N | Country code (+243), phone field, legal checkbox with Terms/Privacy links, "Recevoir le code" |
| S04 | OTP | N | 6-digit `pinput`, resend countdown 60 s, change number |
| S05 | Profile setup | N | Name, optional photo, commune picker |
| S06 | **Accueil** | F (01) | Logo + location chip, notifications bell, search bar + filter, category row (horizontal scroll), promo banner, "Prestataires populaires" grid (2 columns), "Ajoutés récemment" |
| S07 | Explorer | N | Search field focused, recent searches (local), category grid (all 20) |
| S08 | **Résultats** | F (02) | App bar with category/query, filter chips (Près de moi / commune, Vérifiés, Note 4+, Prix), result count, Provider List Items, infinite scroll |
| S09 | Filters sheet | N | Commune multi-select, verified toggle, min rating, price type, sort; "Appliquer" (accent) and "Réinitialiser" |
| S10 | **Profil prestataire** | F (03) | Cover, avatar, name + verified, rating, stats (expérience, travaux, contacts), bio, services list (listings with prices), portfolio, reviews preview, sticky bar: **Appeler** (outline) + **WhatsApp** (green) |
| S11 | Listing detail | N | Photo carousel, title, price, description, communes served, provider mini-card, same sticky contact bar |
| S12 | Reviews list / write review | N | Rating summary, list; form: 5 stars, text, "Publier l'avis" |
| S13 | Report sheet | N | Reasons (radio), details, "Signaler" |
| S14 | Publier hub | N | Contextual: sign-in CTA / "Devenir prestataire" pitch / pending status card / "Nouvelle annonce" |
| S15 | Provider onboarding (5 steps) | N | Stepper bar; identity & photo → categories → zone (communes) → contact numbers (WhatsApp prefilled) → review & submit |
| S16 | **Publier un service** | F (04) | Photos (up to 6), title, category, description, price + USD/CDF toggle + "Prix sur devis", service area, "Continuer" (accent) |
| S17 | Provider dashboard | N | Status card (pending/approved/rejected + reason), verification card, stats, my listings with status chips and actions (modifier, pause, supprimer) |
| S18 | Verification | N | Explain why, photo of ID, selfie, privacy note ("supprimés après vérification"), submit |
| S19 | Messages | N | Recent contacts list (provider avatar, name, last contact date, WhatsApp/call buttons) + banner "Messagerie intégrée bientôt" |
| S20 | Profil (account) | N | Header (avatar, name, phone), "Espace prestataire", favourites, language, help, terms, privacy, sign out, delete account |
| S21 | Favourites | N | Provider cards list |
| S22 | Delete account | N | Consequences list, type "SUPPRIMER" to confirm, destructive button |
| S23 | Update required / Maintenance | N | Illustration, message, "Mettre à jour" → Play Store |
| A01–A07 | Admin web | N | Login, providers queue/detail, verifications, reports, categories, audit log (Material data tables, same tokens) |

## 5. States

Every data screen implements these states:

| State | Treatment |
|---|---|
| Loading (first) | Skeleton placeholders matching the final layout (cards, list rows); no full-screen spinners |
| Loading more | Small progress row at the list end |
| Empty | Illustration + message + action (e.g. "Aucun plombier à Gombe pour l'instant." → "Voir toutes les communes") |
| Error | Message from `error_{code}` + "Réessayer" |
| Offline | `OfflineBanner` under the app bar ("Hors connexion — affichage des données enregistrées"); actions that need the network are disabled with a tooltip |
| Pending publish | Listing card shows a "Publication en cours…" chip until `visible == true` |

## 6. Component library (`lib/core/widgets/`)

| Widget | Figma reference | Notes |
|---|---|---|
| `KaziButton` | Button/* | Variants: `accent`, `primary`, `outline`, `whatsapp`, `text`; sizes `large` (48) and `small` (32); leading icon; loading state |
| `KaziChip` | Chip/* | Selected/unselected; optional leading/trailing icon |
| `KaziSearchBar` | Search | Pill, shadow, trailing accent filter button |
| `KaziTextField` | Input | Label above, 46 dp, 12 radius, 1.5 border; error text below; counter for limited fields |
| `KaziTextArea` | Textarea | 84 dp min height |
| `CurrencyToggle` | Currency toggle | USD / CDF segmented control |
| `CategoryCircle` | Category/* | 56 dp circle, icon, label below |
| `ProviderCard` | **Provider Card** component | Props: initials/photo, name, service, price, rating, verified, favourite toggle |
| `ProviderListItem` | **Provider List Item** component | Props: photo, name, verified tag, location, rating + reviews, price, actions visible |
| `RatingStars` / `RatingBadge` | Rating | Read-only and input variants |
| `VerifiedBadge` | icon/verified | Circle check in `primary`; semantic label "Prestataire vérifié" |
| `KaziAvatar` | Avatar | Photo or initials on gradient |
| `KaziNetworkImage` | Photo | Thumb size selection, fade-in, gradient + initials/icon fallback |
| `PromoBanner` | Promo banner | Remote Config-controlled |
| `StatTile` | Stat/* | Value + label |
| `ContactBar` | Contact bar | Sticky bottom bar, Appeler + WhatsApp |
| `KaziBottomNav` | Bottom nav | Raised accent publish button |
| `SectionHeader` | Section header | Title + "Voir tout" |
| `EmptyState`, `ErrorView`, `OfflineBanner`, `SkeletonBox` | — | States (§5) |
| `StepperBar` | Progress | Multi-step forms |

Build each widget once, with a **widgetbook-style catalogue screen** in dev builds (`/dev/components`) so agents and designers can check it visually.

## 7. Copy guidelines

- Use "vous" in French.
- Buttons are verbs: "Publier", "Contacter", "Appeler", "Envoyer le code".
- Prices: "dès 10 $", "15 000 FC", "Sur devis".
- Avoid blame in errors: "Impossible de charger les résultats. Vérifiez votre connexion." instead of "Erreur".

## 8. Accessibility checklist

- All icon-only buttons have `Semantics(label: …)` / `tooltip`.
- Contrast: body text `ink`/`body` on white; never `muted` for essential info below 12 px.
- Focus order follows visual order; the sticky contact bar is reachable.
- Respect `MediaQuery.textScaler`; test at 1.3×.
- Ratings are read as "4,9 sur 5, 86 avis".
