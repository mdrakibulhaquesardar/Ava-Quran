# Ava Quran — Mobile API Use Cases & Feature Dictionary

This document aligns backend endpoints with concrete **Mobile Interface (UI)** features. It acts as an instruction manual for the frontend Flutter development team regarding *why* and *where* to invoke each service.

---

## 🔐 1. Authentication (`/auth`)
Handles creation, protection, and bridging of user sessions.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `POST /auth/register` | **Sign Up Screen** | User enters Email + Password to create a standalone account. |
| `POST /auth/login` | **Sign In Screen** | User enters credentials to receive the local JWT access token for further restricted requests. |
| `GET /auth/quran/login` | **"Sign in with Quran Foundation" Button** | Redirects the built-in webview to the verified upstream provider login. Automatic cross-sync handler. |
| `GET /auth/quran/link` | **Settings -> "Link Profile"** | Merges an existing local Email user with their official Quran.Foundation cloud history/account. |
| `POST /auth/refresh` | **Silent Background Call** | Automatic routine when current access token expires. Fetches replacement crypto-tokens without user disruption. |
| `POST /auth/logout` | **Settings -> "Log Out"** | Securely invalidates sessions and terminates valid cache keys instantly on our backend. |

---

## 👤 2. Users & Settings (`/users`)
Manages personalization flags, onboarding states, and demographic settings.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `GET /users/me` | **Profile Screen Init** | Fills the user profile header with their avatar, name, current streak metadata, and preferences status. |
| `PATCH /users/preferences` | **Settings / Gear Icon** | Changing Language (`lang`), selecting primary Reciter (`reciterId`), or modifying system default Mood mode. |
| `PATCH /users/onboarding` | **Splash/Intro Exit** | Signals the backend to stop showing the intro tutorial screens on subsequent application boots. |

---

## 📱 3. The Vertical Feed (`/feed`)
The engine driving short-form content discovery, similar to vertical reels/TikTok but for spiritual content.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `GET /feed` | **Home Screen Main View** | Loads infinite-scroll cards. App passes `?mood=peaceful&lang=bn` to render correctly filtered decks with matching native audio + translation. |
| `GET /feed/recommended` | **Discover / Spotlight Tab** | Generates high-quality, curated highlight decks for cold-starts or daily featured moments. |
| `POST /feed/interactions` | **Card Interaction Tracker** | Automatically fired invisibly when user clicks `like`, finishes a full recitation play, or bookmarks a card. Calibrates the future recommendation weights. |

---

## 📖 4. Qur’an Core Proxy (`/quran`)
High-performance, authenticated gateway to canonical religious text and verified audio networks.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `GET /quran/chapters` | **Surah Index View** | Renders the full index of all 114 Surahs, providing jump-links to reading screens. |
| `GET /quran/ayah/:key` | **Direct Verse Navigation** | Deep linking to a specific verse (e.g., `2:255`). Returns the full payload: Text Uthmani, exact translation, and **live CDN MP3 link** for audio streaming. |
| `GET /quran/search` | **Global Search Bar** | Real-time, server-accelerated full-text search. Type "patience" or "صبر" to pull matching verse result lists. |

---

## 📓 5. Private Journaling (`/reflections`)
The spiritual sanctuary that logs deep thinking and personal connection with verses.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `POST /reflections` | **"Reflect" Floating Action Button** | User types a note about an Ayah. Saves their thought with timestamps and optional mood metadata to the cloud. |
| `GET /reflections` | **Profile -> "My Notes" Screen** | Fetches reverse-chronological log of all recorded realizations across time. Supports filtering by `?ayahKey` to see past thoughts on the current verse. |
| `DELETE` | `/reflections/:id` | **Swipe-to-Delete Entry** | Permanently wipes an unwanted or accidental note from their spiritual timeline. |

---

## 📁 6. Themed Collections (`/collections`)
Allows personalized bookmarking hierarchies (e.g. Creating separate folders for "Patience", "Night Prayers").

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `POST /collections` | **"New Collection" Prompt** | Creates a named container (e.g., "Ramadan Goal"). |
| `GET /collections` | **"My Saves" Main View** | Lists all user folders with counts like "Patience (5 verses)", "Calm (12 verses)". |
| `POST /collections/:id/ayahs` | **Ayah -> "Save to..." Dialog** | User taps specific folder to physically store the current verse inside that directory. |
| `DELETE /collections/:id/ayahs/:key` | **Remove Icon in List** | Pulls the verse out of that theme group without deleting other entries. |

---

## 🔥 7. Active Streaks (`/streaks`)
The primary gamification driver maintaining daily user retention and consistency.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `GET /streaks/me` | **App Header 🔥 Icon** | Displays current burn counter (e.g., "12 Days 🔥"). Also used to inform the user if they are on the verge of breaking a record. |
| `POST /streaks/update` | **Auto-triggered on Finish Reading** | Invisibly fired when the user performs their first interaction of the day, safely calculating and bumping the chain tally server-side. |

---
---

## 🤖 8. Smart AI Assist (`/ai`)
Generative micro-insights and spiritual context extraction powered by specialized LLM pipelines.

| Endpoint | Mobile Action | Mobile App Use-Case |
| :--- | :--- | :--- |
| `POST /ai/insight` | **Feed Card Reflection Slot** | Dynamically generates a 2-3 sentence modern, relatable summary for the given verse to enrich the reading experience. Automatically cached in backend for instant hot-reloads. |
| `POST /ai/emotion-tag` | **Mood-based Categorizer** | Analyzes an Ayah and maps it automatically to emotional triggers (e.g., `["hope", "patience"]`). Mobile team uses this to fill tag clouds or enable filtering by specific mental state feelings. |

---
