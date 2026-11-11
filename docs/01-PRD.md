# Kazi — Product Requirements Document (PRD)

| | |
|---|---|
| **Product** | Kazi — local services marketplace |
| **Version** | v1.0 (MVP) |
| **Status** | Draft for build |
| **Owner** | Archipe Sesanga |
| **Last updated** | 2026-11-01 |
| **Design** | [Figma — DRC Services App UI Design](https://www.figma.com/design/HsRApYAHwq03Tun0mQdh3C) |
| **Related docs** | [ADD](02-ADD.md) · [TDD](03-TDD.md) · [UI/UX Spec](04-UI-UX-SPEC.md) · [Backlog](07-BACKLOG-ROADMAP.md) |

---

## 1. Summary

Kazi ("work" in Swahili) is a free Android-first mobile app where people in the Democratic Republic of the Congo can **publish the services they offer** (plumbing, hairdressing, tailoring, tutoring, repairs…) and where clients can **find, compare and contact** trusted local providers. Contact happens through **WhatsApp or a phone call**, which is how people in the DRC already do business.

v1 launches in **Kinshasa**, in **French and English**, and is **free for everyone**. The architecture must make it straightforward to add more cities, Lingala and Swahili, in-app chat, and monetisation later.

## 2. Problem

- Finding a reliable plumber, electrician, hairdresser or tutor in Kinshasa depends on word of mouth. Clients have no easy way to compare providers, see their past work or check their reputation.
- Skilled informal workers have no simple, low-cost way to advertise beyond their immediate neighbourhood. Classified sites aren't built for services, aren't trusted and aren't mobile-first.
- Trust is low: clients fear scams and poor workmanship, and providers fear time-wasters.

## 3. Goals and non-goals

### 3.1 Goals (v1)

1. Let a provider create a profile and publish a service in **under 5 minutes** on a low-end Android phone.
2. Let a client find a relevant provider in their commune and contact them in **under 60 seconds** from opening the app.
3. Build trust through **admin-approved providers**, an optional **ID-verified badge**, **reviews gated by real contact**, and **reporting**.
4. Run cheaply on Firebase. The app is free, so infrastructure cost per active user must stay minimal.
5. Lay foundations (i18n, multi-city data model, currency per listing) for growth beyond Kinshasa.

### 3.2 Non-goals (v1)

- In-app chat (v2). Contact is WhatsApp or phone only.
- Bookings, calendars or appointment scheduling (v2).
- Payments, escrow or any money handling (v3).
- Paid boosts, subscriptions or ads. v1 is free, though the data model must not block them later.
- iOS App Store release. The code stays cross-platform, but v1 ships to Google Play only; iOS follows once Android is validated.
- Lingala and Swahili UI (planned for v1.1).
- Cities other than Kinshasa (data model supports them; seed data covers Kinshasa only).

## 4. Target users and personas

| Persona | Description | Needs | Pain points |
|---|---|---|---|
| **Client — "Nadine", 29, Gombe** | Office worker, budget Android phone, prepaid data | Find a trustworthy plumber nearby quickly; see prices up front | Unreliable referrals, fear of scams, expensive data |
| **Provider — "Jean", 38, plumber** | Self-employed, 8 years' experience, uses WhatsApp for everything | More clients beyond his street; look professional | No online presence, no portfolio, competes on price only |
| **Provider — "Grâce", 24, hairdresser** | Works from home, active on WhatsApp Status | Show her work (photos); get bookings via WhatsApp | Hard to reach clients outside her social circle |
| **Admin — Kazi team** | Archipe and future moderators | Approve providers, verify IDs, act on reports quickly | No tooling; fraud and spam risk |

## 5. Context and constraints

| Constraint | Product implication |
|---|---|
| Budget Android phones (2–3 GB RAM, Android 8+) | Lightweight UI, small app bundle, no heavy animations |
| Expensive, unreliable mobile data | Thumbnails in lists, pagination, offline cache, compressed uploads, bundled fonts (no runtime font download) |
| WhatsApp is the main communication tool | WhatsApp deep-link as the primary CTA |
| Informal addresses | Location = city → commune (+ optional quartier text), not street addresses |
| Two currencies in daily use (USD and CDF) | Price stored with explicit currency per listing |
| Low trust | Approval, verified badge, contact-gated reviews, reporting, blocking |
| French is the lingua franca | French default; English second; Lingala/Swahili next |

## 6. Scope — v1 feature list

Priority: **P0** = launch blocker, **P1** = should ship in v1, **P2** = nice to have, can slip to v1.1.

### 6.1 Onboarding and accounts

| ID | Feature | Priority |
|---|---|---|
| F-01 | Splash, language picker (FR/EN) on first launch, 3-slide intro | P1 |
| F-02 | **Browse without an account** (home, search, profiles visible to guests) | P0 |
| F-03 | Sign in with **phone number + SMS OTP** (Firebase Phone Auth), DRC (+243) by default, other country codes allowed | P0 |
| F-04 | Basic profile: display name, optional photo, preferred language, home city/commune | P0 |
| F-05 | Sign out, **delete account** (in app; required by Google Play) | P0 |
| F-06 | Accept Terms of Service and Privacy Policy at sign-up (versioned) | P0 |

### 6.2 Discovery (client)

| ID | Feature | Priority |
|---|---|---|
| F-10 | Home: location chip (city/commune), search bar, category row, promo banner ("Devenir prestataire"), popular providers, recently added | P0 |
| F-11 | Category browsing (seeded list: see §11) | P0 |
| F-12 | Keyword search across listing titles, categories and provider names (accent- and case-insensitive, prefix match) | P0 |
| F-13 | Filters: commune, verified only, minimum rating (4+), price type; sort by rating / newest | P0 |
| F-14 | Results list with provider photo, name, verified badge, commune, rating, price, WhatsApp button | P0 |
| F-15 | Listing detail / provider profile: cover, avatar, bio, stats, services with prices, portfolio photos, reviews, **Call** and **WhatsApp** buttons | P0 |
| F-16 | Favourites (save providers) | P1 |
| F-17 | Share a provider profile (link with a pre-filled WhatsApp share message) | P1 |
| F-18 | "Near me" distance sorting using device location (opt-in) | P2 |

### 6.3 Contact

| ID | Feature | Priority |
|---|---|---|
| F-20 | WhatsApp deep link with a pre-filled message ("Bonjour, je vous ai trouvé sur Kazi pour …") | P0 |
| F-21 | Phone call via `tel:` link | P0 |
| F-22 | Each contact tap is recorded (client, provider, listing, channel). It unlocks reviewing and feeds metrics | P0 |
| F-23 | Guests must sign in before contacting (needed for anti-spam and review gating) | P0 |

### 6.4 Provider

| ID | Feature | Priority |
|---|---|---|
| F-30 | "Become a provider" flow: business/display name, categories (1–3), bio, commune(s) served, WhatsApp number (defaults to login number), years of experience, profile photo, cover photo | P0 |
| F-31 | Provider status: **pending → approved / rejected**, then **suspended** if needed. Only approved providers' listings are public | P0 |
| F-32 | Create, edit, pause and delete **service listings**: title, category, description, up to **6 photos**, price type (fixed / from / on quote), amount, currency (USD/CDF), service area | P0 |
| F-33 | Up to **10 active listings** per provider (anti-spam) | P0 |
| F-34 | Portfolio photos on the profile (up to 12) | P1 |
| F-35 | Provider dashboard: listings, status, simple stats (contact taps this month and in total, rating, review count). Profile views are tracked in Analytics only in v1 | P1 |
| F-36 | **ID verification request**: upload an ID photo and a selfie. An admin reviews it, the verified badge is granted, and the documents are deleted after review | P1 |
| F-37 | Push notification when the provider is approved/rejected or verification is decided | P1 |

### 6.5 Trust and safety

| ID | Feature | Priority |
|---|---|---|
| F-40 | Reviews: 1–5 stars + optional text (≤ 500 chars). **One review per client per provider**, only after a recorded contact, editable by its author | P0 |
| F-41 | Provider can reply once to each review | P2 |
| F-42 | Report a listing, provider or review (reasons: scam, inappropriate, fake, wrong category, other) | P0 |
| F-43 | Auto-hide a listing after **3 distinct open reports**, pending admin review | P1 |
| F-44 | Block a user (hides their content from you) | P1 |
| F-45 | Basic content rules: no phone numbers in titles, profanity filter (FR/EN word list), image count/size limits | P1 |

### 6.6 Admin web panel (Flutter Web)

| ID | Feature | Priority |
|---|---|---|
| F-50 | Admin sign-in (email/password, restricted to accounts with an admin claim) | P0 |
| F-51 | Provider approval queue: view profile and listings, approve/reject with reason | P0 |
| F-52 | Verification queue: view ID documents, grant/deny badge. Documents are deleted on decision | P1 |
| F-53 | Reports queue: view target, dismiss / hide content / suspend provider | P0 |
| F-54 | Category management (names FR/EN, icon, order, active flag) | P1 |
| F-55 | Simple dashboard: counts of users, providers (by status), listings, contacts, reports | P2 |
| F-56 | Audit log of admin actions | P1 |

### 6.7 Platform

| ID | Feature | Priority |
|---|---|---|
| F-60 | French + English localisation for all UI strings, with locale-aware number/date formats | P0 |
| F-61 | Offline: previously loaded screens readable offline; clear offline banner; writes queued by Firestore where safe | P0 |
| F-62 | Analytics events (see §9) and crash reporting | P0 |
| F-63 | Force-update / maintenance mode via Remote Config | P1 |
| F-64 | In-app links to Terms, Privacy Policy, Help / FAQ, Contact support (WhatsApp) | P0 |

## 7. User stories (key flows)

Detailed acceptance criteria per story live in the [Backlog](07-BACKLOG-ROADMAP.md).

**Client**
- As a client, I can browse categories and providers without signing up, so I can see whether Kazi is useful before committing.
- As a client, I can search "plombier" and filter to my commune, so I only see providers who can reach me.
- As a client, I can open a provider's profile and see their prices, photos of their work and reviews, so I can judge whether to trust them.
- As a client, I can tap WhatsApp and get a ready-to-send message, so contacting a provider takes one tap.
- As a client who has contacted a provider, I can leave a rating and review, so others benefit from my experience.
- As a client, I can report a suspicious listing, so the team can remove scams.

**Provider**
- As a provider, I can sign up with my phone number and create my profile in a few minutes.
- As a provider, I can publish a service with photos and a price in USD or CDF.
- As a provider, I get notified when my profile is approved, so I know clients can find me.
- As a provider, I can request ID verification to get a "Vérifié" badge that makes clients trust me more.
- As a provider, I can pause a listing when I'm unavailable.

**Admin**
- As an admin, I can approve or reject new providers from a queue.
- As an admin, I can review reports and hide content or suspend accounts.

## 8. Non-functional requirements

| Area | Requirement |
|---|---|
| **Devices** | Android 6.0+ (minSdk 23). Target device: 2 GB RAM, 720p screen. iOS-compatible code, not released in v1 |
| **Performance** | Cold start < 3 s on target device; home screen first content < 2 s on 3G with warm cache; list scroll at 60 fps on target device |
| **Size** | Android App Bundle; per-device download ≤ 25 MB |
| **Data usage** | List screens load thumbnails only (≤ 30 KB each); uploads compressed client-side to ≤ 1280 px longest side, ~75% JPEG quality; pages of 20 items |
| **Offline** | Firestore offline persistence enabled; last-viewed home, results and profiles available offline |
| **Availability** | Relies on Firebase SLA; no self-hosted servers |
| **Security** | All access enforced by Firestore/Storage security rules (deny by default); App Check enforced on Firestore, Storage, Functions; admin actions via callable Functions only |
| **Privacy** | Collect the minimum: phone number, name, optional photo, optional location (commune). ID documents deleted after review (max 30 days). Account deletion removes personal data within 30 days |
| **Accessibility** | Text scales to 130% without breaking layouts; touch targets ≥ 48 dp; WCAG AA contrast for text; semantic labels on icon buttons |
| **Localisation** | No hard-coded user-facing strings; ARB files for `fr` and `en`; French fallback |
| **Cost** | Target < US$50/month Firebase cost up to 10,000 monthly active users; budget alerts at $25 / $50 / $100 |
| **Observability** | Crashlytics crash-free users ≥ 99.5%; Analytics funnels for key flows |

## 9. Success metrics

**North-star metric:** number of **contact taps** (WhatsApp + call) per week.

| Metric | Target 3 months after launch |
|---|---|
| Approved providers (Kinshasa) | 300 |
| Published listings | 600 |
| Monthly active users (MAU) | 5,000 |
| Weekly contact taps | 1,500 |
| % of contacts followed by a review within 14 days | ≥ 10% |
| Provider onboarding completion (start → submitted) | ≥ 60% |
| Median approval time | < 24 h |
| Crash-free users | ≥ 99.5% |
| D30 retention (clients) | ≥ 15% |

**Core analytics events:** `app_open`, `onboarding_complete`, `sign_up`, `search` (query, category, commune), `view_listing`, `view_provider`, `contact_tap` (channel, provider_id), `favorite_add`, `review_submit`, `report_submit`, `provider_onboarding_start`, `provider_onboarding_submit`, `listing_publish`, `verification_request`.

## 10. Launch plan

1. **Supply first:** recruit 50–100 providers in 3–4 communes (Gombe, Lingwala, Kintambo, Bandalungwa, Limete) in person before the public launch, with the admin team assisting onboarding.
2. **Closed beta** (Google Play internal/closed testing): ~30 providers + ~100 clients, 2–3 weeks.
3. **Public launch** on Google Play, Kinshasa only, promoted through WhatsApp groups, the Jeunesse Éveillée channel and local partners.
4. Weekly review of metrics and reports; ship v1.1 after 4–6 weeks.

## 11. Seed categories (v1)

Plomberie · Électricité · Coiffure & beauté · Couture · Menuiserie · Maçonnerie & construction · Peinture · Mécanique auto · Réparation téléphones & électronique · Informatique · Cours particuliers · Ménage & nettoyage · Cuisine & traiteur · Transport & déménagement · Événementiel (DJ, déco, photo) · Climatisation & froid · Soudure · Jardinage · Garde d'enfants · Autres services

(English names are in the TDD seed data.)

## 12. Future roadmap (post-v1, for context)

| Version | Themes |
|---|---|
| v1.1 | Lingala and Swahili, provider review replies, near-me sorting, more cities (Lubumbashi, Goma) |
| v2 | In-app chat (Firestore), booking requests, richer notifications, iOS release, search provider (Typesense/Algolia) |
| v3 | Monetisation: boosts, provider subscription, verified badge fee, mobile money via an aggregator; escrow evaluation; web version for SEO; other countries |

## 13. Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Empty marketplace at launch | High | High | Recruit supply in person first; launch commune by commune |
| Scams / fake providers | Medium | High | Admin approval, verified badge, contact-gated reviews, report auto-hide |
| SMS OTP cost and delivery problems on +243 numbers | Medium | Medium | App Check + Play Integrity to block abuse, SMS region policy, rate limits, monitoring; consider WhatsApp OTP in v1.1 |
| Firebase cost spikes | Low | Medium | Pagination, denormalised reads, budget alerts, caching |
| Low provider literacy with apps | Medium | Medium | Minimal-step onboarding, icons, assisted onboarding by team |
| Legal/data protection non-compliance | Medium | High | Privacy policy, minimal data, ID deletion, review against DRC Digital Code (Ordonnance-loi n° 23/010) with local counsel |

## 14. Open questions

1. Company or legal entity that will publish the app on Google Play and own the data (needed for privacy policy and Play Console).
2. Support channel: dedicated WhatsApp Business number?
3. Who besides Archipe will moderate, and in which hours (to meet the < 24 h approval target)?
4. Domain name for Terms/Privacy pages and share links (e.g. `kazi.cd` / `kaziapp.com`).
