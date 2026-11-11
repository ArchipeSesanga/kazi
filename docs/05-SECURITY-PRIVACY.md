# Kazi — Security, Privacy & Trust Design

| | |
|---|---|
| **Version** | v1.0 |
| **Related** | [ADD](02-ADD.md) §7 · [TDD](03-TDD.md) §5–6 · [`firebase/`](firebase/) |

> Not legal advice. Have the privacy policy and terms reviewed against the DRC Digital Code (Ordonnance-loi n° 23/010 du 13 mars 2023 portant Code du numérique) and any other applicable rules by a qualified lawyer before launch.

---

## 1. Threat model (STRIDE summary)

| Threat | Example | Mitigation |
|---|---|---|
| **Spoofing** | Bot sign-ups; SMS pumping fraud on Phone Auth | App Check (Play Integrity), SMS region policy (allow `CD` + selected), Firebase Auth abuse protection, budget alerts on SMS |
| **Spoofing** | Fake provider impersonating a real business | Admin approval, optional ID verification, reporting |
| **Tampering** | Client sets own `verified = true` or `ratingAvg = 5` | Server-only fields; rules `changedOnly` whitelists; rules tests |
| **Tampering** | Fake reviews | One review per client per provider; requires recorded contact; moderators can delete; anomaly review in admin |
| **Repudiation** | Admin abuses powers | All admin actions via callables writing `adminLogs` |
| **Information disclosure** | Scraping users' phone numbers | `users` docs private; only provider-chosen public numbers exposed; App Check; no "list all providers" without filters + pagination |
| **Information disclosure** | ID documents leaked | Private Storage path, no client read, signed URLs (10 min), deleted after decision or after 30 days |
| **Denial of service / cost** | Read amplification, upload spam | Pagination, listing/photo caps, file size limits, App Check, budget alerts |
| **Elevation of privilege** | User grants self admin | Custom claims only via `admin_setRole` (superAdmin) or a local script with a service account |

## 2. Personal data inventory

| Data | Where | Visibility | Purpose | Retention |
|---|---|---|---|---|
| Phone number (login) | Auth, `users.phone` | Owner, moderators | Authentication, support | Until account deletion |
| Display name, photo | `users`, review snapshots | Name/photo public on reviews | Identity | Until deletion |
| Provider public numbers (WhatsApp / call) | `providers` | Public (provider consents in onboarding) | Contact | Until deletion |
| City / commune | `users`, `providers`, `listings` | Provider area public | Matching | Until deletion |
| Contact records | `contacts` | Client + provider of the pair | Review gating, stats | Until deletion of either account |
| ID document + selfie | Private Storage | Admins (signed URL) | Verification | Deleted on decision, max 30 days |
| Reports | `reports` | Moderators | Safety | 12 months; reporter anonymised on deletion |
| Device tokens | `users/{uid}/devices` | Owner | Push notifications | Removed when invalid or on deletion |
| Analytics / crash data | Google Analytics / Crashlytics | Team | Product improvement | Per Firebase retention settings (set Analytics retention to 14 months) |

**Not collected in v1:** email (users), precise GPS location stored server-side, contacts list, payment data, date of birth, gender.

## 3. Consent and transparency

- Sign-up shows a checkbox linking to the **Terms** and **Privacy Policy** (hosted on Firebase Hosting, FR + EN). The accepted `termsVersion` is stored.
- Provider onboarding asks for explicit consent: "Mon numéro WhatsApp sera visible publiquement sur mon profil."
- Location permission (v1.1 "near me") is requested only when the user taps the near-me chip.
- Notification permission (Android 13+) is requested after provider onboarding submission, with an explanation.
- Google Play **Data safety** form must match §2.

## 4. User rights

- **Access/rectification:** users edit their profile in the app.
- **Deletion:** in-app deletion (`deleteAccount`) plus a public web page `/delete-account` with instructions (Google Play requirement).
- **Contact:** support WhatsApp number from Remote Config and a support email on the privacy policy.

## 5. Trust and safety operations

| Process | SLA target | Tooling |
|---|---|---|
| Provider approval | < 24 h | Admin providers queue |
| Verification decision | < 48 h | Verification queue |
| Report triage | < 24 h (scam reports < 6 h) | Reports queue, auto-hide at 3 reports |
| Repeat offenders | — | Suspend provider (all listings hidden), suspend user (`users.status = suspended` blocks writes) |

**Approval checklist for moderators**
1. Name looks like a real person or business (no phone numbers or links in the name).
2. Categories match the bio and photos.
3. Photos are real work, with no stolen stock images (reverse image search for suspicious ones), no nudity and no violence.
4. WhatsApp number format is valid. Optionally do a quick test message for verification requests.
5. Prices plausible; no requests for upfront payment in the description.

## 6. Security engineering checklist (definition of done for security-relevant PRs)

- [ ] New/changed Firestore paths have rules **and** rules tests (allow + deny).
- [ ] No server-only field writable by clients.
- [ ] Callables validate input with `zod`, check auth and claims, and enforce App Check.
- [ ] No secrets in the Flutter app or repository; Functions secrets via `defineSecret`.
- [ ] No PII in analytics params or logs (`logger` redacts phone numbers).
- [ ] Storage paths and size/type limits respected.
- [ ] Admin actions write `adminLogs`.
