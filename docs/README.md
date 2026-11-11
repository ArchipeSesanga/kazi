# Kazi — Project Documentation (v1)

Kazi is a free, Android-first marketplace where people in the DRC publish and find local services (plumbing, hairdressing, tailoring, tutoring…) and contact providers on WhatsApp or by phone. v1 launches in Kinshasa, in French and English.

**Stack:** Flutter · Firebase (Auth, Firestore, Storage, Functions, FCM, Remote Config, App Check, Analytics, Crashlytics, Hosting) · Provider · go_router
**Design:** [Figma — DRC Services App UI Design](https://www.figma.com/design/HsRApYAHwq03Tun0mQdh3C)

## Documents

| # | Document | What it answers | Main reader |
|---|---|---|---|
| 01 | [PRD — Product Requirements](01-PRD.md) | What we're building and why; scope, features, NFRs, metrics | Everyone |
| 02 | [ADD — Architecture Design](02-ADD.md) | How the system is structured; containers, data flows, ADRs | Tech lead, agents |
| 03 | [TDD — Technical Design](03-TDD.md) | Exact contracts: data model, rules, functions, app structure, routes | **Agents (authoritative)** |
| 04 | [UI/UX Specification](04-UI-UX-SPEC.md) | Design tokens, components, screens, states, accessibility | UI work |
| 05 | [Security, Privacy & Trust](05-SECURITY-PRIVACY.md) | Threat model, personal data, moderation processes | Owner, reviewers |
| 06 | [Test Plan](06-TEST-PLAN.md) | What must be tested and how; E2E journeys | Agents, QA |
| 07 | [Backlog & Sprint Plan](07-BACKLOG-ROADMAP.md) | Epics, stories (KZ-xxx) with acceptance criteria, sprints | Planning, agents |
| 08 | [Coding Standards](08-CODING-STANDARDS.md) | Conventions, architecture rules, Definition of Done | Agents |
| 09 | [DevOps & Release](09-DEVOPS-RELEASE.md) | Firebase setup, environments, CI/CD, Play release, monitoring | Owner |
| 10 | [AGENTS.md](10-AGENTS.md) | Operating rules for AI coding agents (copy to repo root) | Agents |
| — | [`firebase/`](firebase/) | Starter `firestore.rules`, `storage.rules`, `firestore.indexes.json` | Agents |

## How to use this pack

1. Create the repository and copy this folder to `docs/`.
2. Copy `docs/10-AGENTS.md` to `/AGENTS.md`, and create `/CLAUDE.md` containing `See AGENTS.md`.
3. Copy `docs/firebase/*` to the repo root once the Firebase project is initialised (story KZ-004).
4. Do the owner setup in [09-DEVOPS-RELEASE.md §1](09-DEVOPS-RELEASE.md#1-one-time-setup-checklist).
5. Give agents one story at a time from [07-BACKLOG-ROADMAP.md](07-BACKLOG-ROADMAP.md), starting with Sprint 0 (KZ-001 → KZ-012).

## Decisions captured so far

| Topic | Decision |
|---|---|
| Name | Kazi |
| Pricing | Free for everyone in v1 |
| Platform | Android first (Google Play); iOS-compatible code |
| Launch city | Kinshasa (24 communes seeded) |
| Languages | French (default) + English; Lingala/Swahili in v1.1 |
| Contact | WhatsApp deep link + phone call; in-app chat in v2 |
| Admin | Flutter Web admin panel in the same repo |
| State management | Provider (`ChangeNotifier`), no other state library |
| Region | Firebase `africa-south1` (Johannesburg) |
| Font / colours | Montserrat; `#F25912`, `#5C3E94`, `#412B6B`, `#211832` |

## Open items for the owner

- Legal entity and Google Play developer account (organisation vs personal).
- Domain for legal pages, share links and the Android application ID (`cd.kazi.app` is a placeholder and can't change after the first upload).
- Support WhatsApp number and support email.
- Moderators and their hours.
- Legal review of the Terms and Privacy Policy against the DRC Digital Code.
