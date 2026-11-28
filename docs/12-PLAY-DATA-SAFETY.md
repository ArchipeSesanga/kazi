# Kazi — Google Play Data safety form (draft answers)

| | |
|---|---|
| **App** | Kazi (`com.arkepios.kazi`), consumer Android app. The React admin panel is not distributed on Play and is out of scope. |
| **Draft date** | 2026-11-21 (policy version 2026-11) |
| **Basis** | The code, rules and Cloud Functions in this repository, plus the merged Android manifest of the prod build. Not legal advice. |
| **Legend** | ✅ confident · ⚠️ unsure: decide or verify before submitting |

**Update this form before releasing any change that adds a data type** (reviews, favourites, FCM tokens, identity verification are all *not* in the app yet, see §6).

---

## 1. Overview questions

| Question | Draft answer | Notes |
|---|---|---|
| Does the app collect or share any of the required user data types? | **Yes** | See §3. |
| Is all user data encrypted in transit? | **Yes** ✅ | Firebase SDKs use TLS (HTTPS) for every call; the only other network use is opening WhatsApp / the dialer / the legal pages, which are outside Kazi. |
| Account creation method | **Other** ⚠️ | Phone number + SMS code (Firebase Auth). Play's list has "Username and password", "Username and other authentication", "OAuth", "Other": pick "Other" and describe it as phone-number sign-in. Email/password exists only in dev builds and for staff (not in prod consumer builds). |
| Can users request that their data be deleted? | **Yes** ✅ | In-app: Profile → Delete my account (typed word + fresh SMS code, callable `deleteAccount`). Web: `https://kazi-prod-d9c00.web.app/delete-account` (replace with the final domain). |
| Account-deletion URL (App content → Data safety) | `…/delete-account` | The page is FR + EN. |
| Data deletion: what is deleted / kept | See the privacy policy §4 and `/delete-account` (in the app immediately; on request by email or WhatsApp: reply within 7 days, deleted within 30 days, via the operator tool in the runbook §G) | Reviews anonymised and kept; reports kept with reporter "deleted"; moderation audit log kept. Declare that some data is kept "for security / fraud prevention / compliance" ⚠️ (Play asks whether you retain any data after deletion requests). |
| Committed to Google Play Families policy? | **No** | Audience 18+. |
| Independent security review? | **No** | |

## 2. What counts as "shared"

Play's definition of **sharing** excludes sending data to a **service provider that processes it on your behalf** (here: Google Firebase). Under that rule Kazi shares **nothing** with third parties, and the table below says "Not shared" everywhere. ⚠️ Two things to double-check with the current Play help text:
1. Data that users make **visible to other users inside the app** (provider profile, listings, public numbers, photos). My reading: this is user-to-user display, not transfer to a third party, so not "sharing". If you prefer to be conservative, mark Photos, Name (provider display name), Phone number (WhatsApp/call numbers) and User-generated content as shared with "other users".
2. When a user taps **WhatsApp**, the provider's number is handed to WhatsApp by the user's action. That is the user initiating the transfer (not declared as sharing).

## 3. Data types

"Required" = the user cannot use that part of the app without it; "Optional" = the user can skip it.

### Personal info
| Type | Collected | Shared | Required / optional | Purposes | Where in the code | Conf. |
|---|---|---|---|---|---|---|
| **Name** | Yes | No | Required (display name at profile setup) | App functionality; Account management | `users.displayName`; provider `displayName` (visible to signed-in users). The accepted terms version and date are stored with the profile (`termsVersion`, `termsAcceptedAt`) | ✅ |
| **Email address** | **No** for consumers | — | — | — | Not asked; `users.email` is optional and the profile form has no email field. Staff emails exist only in the admin app. | ✅ |
| **User IDs** | Yes | No | Required | App functionality; Account management; Fraud prevention, security and compliance | Firebase `uid` in every record, contact, report and block | ✅ |
| **Phone number** | Yes | No | Required | App functionality; Account management; Fraud prevention, security and compliance | Firebase Auth phone; `users.phone`; provider WhatsApp/call numbers (optional call number) | ✅ |
| **Address** | Not a street address. City and commune the user types (service area / home commune) | No | Required (city defaults to Kinshasa; communes chosen in the provider form) | App functionality | `users.city/commune`, `providers.baseCommune/communes`, `listings.communes` | ⚠️ unsure whether Play wants this under "Address". It is **not** device location. Recommended: declare "Address" (optional wording) to be safe |
| Race, political, religion, sexual orientation, other | No | — | — | — | | ✅ |

### Location
| Type | Collected | Notes | Conf. |
|---|---|---|---|
| Approximate location | **No** | No location permission, no GPS. Analytics derives country/region server-side from the IP (Google). ⚠️ Play says approximate location collected "through Analytics SDK" may need declaring; I read it as Google-side coarse geography, not collected by the app. Confirm in Play's help. | ⚠️ |
| Precise location | **No** | | ✅ |

### Financial info, Health and fitness, Messages, Audio, Calendar, Contacts
**Not collected.** Notes: no payments; Kazi has no chat (contact happens in WhatsApp / by phone, not stored); the app does not read SMS (Firebase Auth uses Google Play services for the code); the contact list is never read. ✅

### Photos and videos
| Type | Collected | Shared | Required / optional | Purposes | Code | Conf. |
|---|---|---|---|---|---|---|
| **Photos** | Yes | No | Optional (profile picture, provider picture and cover, listing photos) | App functionality | Storage `media/{uid}/…`. Gallery photos come through the system photo picker (no storage/media permission); only `CAMERA` is declared, for taking a photo | ✅ |
| Videos | No | | | | | ✅ |

### Files and docs
**Not collected** today. When identity verification ships (ID document and selfie), declare Photos (and Files and docs if applicable) as collected, optional, purpose "Fraud prevention, security and compliance", and update the policy first. ✅

### App activity
| Type | Collected | Shared | Required / optional | Purposes | Code | Conf. |
|---|---|---|---|---|---|---|
| **App interactions** | Yes | No | Required (no in-app opt-out) | Analytics; App functionality | Firebase Analytics automatic events plus `contact_provider` (provider id, listing id, channel); contact records (`contacts/*`) written when the user taps WhatsApp/Call | ⚠️ "Required" because there is no switch to turn Analytics off. If you add one, change to optional |
| In-app search history | **No** | | | | Recent searches are kept in `SharedPreferences` on the device only; the search query is not stored or logged server-side (`logSearch` exists but is not called). | ✅ |
| **Other user-generated content** | Yes | No | Optional | App functionality | Provider bio, listing title and description, report details | ✅ |
| Other actions | Yes (blocks, reports, contact taps) | No | Optional | App functionality; Fraud prevention, security and compliance | `users/*/blocks`, `reports`, `contacts` | ✅ |
| Installed apps, web browsing | No | | | | | ✅ |

### App info and performance
| Type | Collected | Shared | Required / optional | Purposes | Code | Conf. |
|---|---|---|---|---|---|---|
| **Crash logs** | Yes | No | Required | Analytics (app stability) | Firebase Crashlytics, enabled in prod builds (`bootstrap.dart`) | ✅ |
| **Diagnostics** | Yes | No | Required | Analytics | Crashlytics diagnostics (device model, OS, app state) | ⚠️ |
| Other app performance data | No | | | | Firebase Performance is not used | ✅ |

### Device or other IDs
| Type | Collected | Shared | Required / optional | Purposes | Code | Conf. |
|---|---|---|---|---|---|---|
| **Device or other IDs** | Yes (Firebase installation id / app instance id) | No | Required | Analytics; Fraud prevention, security and compliance (App Check / Play Integrity) | Analytics, Crashlytics, Remote Config, App Check | ✅ |
| **Advertising ID** | **No** | | | | The prod manifest removes `AD_ID` and the ad-services permissions and disables ad-ID collection (`AndroidManifest.xml`). On the **App content → Advertising ID** page answer "No". | ✅ verified with `aapt` on the prod APK |

## 4. Security practices summary (as shown to users)
- Data is encrypted in transit.
- You can request that data be deleted (in the app and on the web).
- The app does **not** claim to follow the Families policy and has **no** independent security review.

## 5. Other Play Console declarations tied to the code
| Item | Draft answer | Notes |
|---|---|---|
| Ads | No ads | No ad SDK. |
| Advertising ID | Not used | See above. |
| Target audience and content | 18+ | Terms and policy require 18+; there is no age check in the app. |
| User-generated content | Yes: listings, profile text, photos | Moderation exists: reporting, auto-hide at 3 reports, moderator tools, blocking. Describe these in the content-rating questionnaire. |
| Financial features | None | |
| Permissions (merged prod manifest) | `CAMERA`, `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `POST_NOTIFICATIONS`, `RECEIVE` (c2dm), `BIND_GET_INSTALL_REFERRER_SERVICE`, `READ_GSERVICES` | ✅ `READ_MEDIA_IMAGES` and `READ_EXTERNAL_STORAGE` were **removed**: the gallery uses the system photo picker (Android 13+) / document picker (older), so the Play photo and video permissions policy does not apply. ⚠️ Verify the gallery and camera on a real Android 13+ device **and** an Android 12 or older device before release (see §7). `POST_NOTIFICATIONS`/`RECEIVE` come from the Firebase Messaging dependency; no notifications are sent yet and FCM auto-init is disabled in the manifest. The install-referrer permission comes from Analytics (a Google Play service), no extra declaration. |
| App access (login required) | Provide the reviewer test number | See `docs/11-PROD-RUNBOOK.md` §D. The only test number allowed in prod; remove it after review. |
| Privacy policy URL | `…/fr/privacy` (and `/en/privacy`) | Publish after the placeholders and the lawyer review are final. |

## 6. Not in the app yet (do not declare, but update before they ship)
| Feature | Status | Effect on this form |
|---|---|---|
| Reviews | Screens exist; no data layer. The deletion code anonymises them already. | User-generated content (text, rating), name shown with a review |
| Favourites | Screen only; schema, rules and deletion exist | App activity (other actions) |
| Push notifications / FCM token | Not implemented (KZ-092); auto-init disabled | Device or other IDs (token) |
| Identity verification | Not implemented (KZ-090/091) | Photos / files; sensitive: ID document |
| Staff admin app | Separate website, not on Play | None |

## 7. Open points to settle before submitting
1. ⚠️ Where to declare the **city/commune** (Address vs nothing).
2. ⚠️ Whether Play counts Analytics' **IP-derived country/region** as approximate location.
3. ⚠️ Whether to mark user-visible data (provider profile, listings, numbers) as **shared** (conservative) or not (my reading, §2).
4. ⚠️ **Analytics "required"** (no opt-out). Consider an opt-out switch or a consent step if you want "optional".
5. ⚠️ Retention after deletion: moderation audit log, reports (reporter "deleted"; report ids still contain the old uid), anonymised reviews, Google's own backups. The "do you retain data" answer must say yes. A purge is planned as **KZ-109** (before public launch). Analytics/Crashlytics retention equals the console setting (owner to confirm 14 months).
6. Replace the base URL with the final domain; submit only after the lawyer review.
7. ⚠️ **Device test of the photo picker** on Android 13+ and on Android 12 or older (not yet exercised on devices by the developer tooling).
8. ⚠️ Storage bucket region: not yet named on the Privacy page (`{{STORAGE_REGION}}`).
