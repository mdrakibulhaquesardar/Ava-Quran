# Ava Quran Backend — API Endpoints

This document lists the **HTTP API surface** the Ava Quran mobile app (and future clients) need from **Ava Quran Backend**. It is derived from [PRD.md](PRD.md) (authoritative contract) and cross-checked with [AbstracPRD.md](AbstracPRD.md) (feature-level intent). **Canonical Qur’an content** for the running server should come from the **Quran Foundation Content API v4**; the **Cursor `quran` MCP** (`user-quran`) mirrors the same quran.com–lineage data for IDE/agents only (see §5).

**Conventions**

- Base path: no global prefix in v1 (paths are literal, e.g. `/feed`, `/health`).
- Unless noted, **protected** routes require a valid Ava Quran **JWT** (`Authorization: Bearer <access_token>`) after OAuth completes.
- **Public** routes: auth entry/callback, health.

---

## 1. Operations and health

| Method | Path        | Auth   | Purpose                                      |
|--------|-------------|--------|----------------------------------------------|
| `GET`  | `/health`   | Public | Liveness / readiness: DB + Redis (and shape for load balancers). |

*Already implemented in the codebase as infrastructure.*

---

## 2. Authentication (`/auth`)

Quran.Foundation OAuth2/OIDC plus Ava Quran–issued JWTs ([PRD.md](PRD.md) §6.1).

| Method | Path             | Auth   | Purpose |
|--------|------------------|--------|---------|
| `POST` | `/auth/login`    | Public | Start OAuth (return redirect URL or initiate flow per design). |
| `GET`  | `/auth/callback` | Public | OAuth callback: exchange code, create/update user, issue tokens. |
| `POST` | `/auth/refresh`  | Public* | Refresh access token (body: refresh token or cookie strategy). |
| `POST` | `/auth/logout`   | Protected | Invalidate refresh session / tokens server-side. |

\*Typically unauthenticated with a refresh credential; document the chosen pattern in implementation.

**Maps to Abstract PRD:** account/session for all personalized features.

---

## 3. Users (`/users`)

Profile, preferences, onboarding, mood defaults ([PRD.md](PRD.md) §6.2).

| Method  | Path                    | Auth      | Purpose |
|---------|-------------------------|-----------|---------|
| `GET`   | `/users/me`             | Protected | Current user profile + preferences + onboarding flags. |
| `PATCH` | `/users/preferences`    | Protected | Update language, reciter, notification flags (future), mood defaults. |
| `PATCH` | `/users/onboarding`     | Protected | Mark onboarding steps complete. |

**Maps to Abstract PRD:** mood-based experience defaults, audio/reciter preferences, onboarding.

---

## 4. Feed (`/feed`)

Personalized vertical feed: ayah, translation, audio, optional AI, tags ([PRD.md](PRD.md) §6.3; Abstract PRD: personalized feed, mood, audio-first cards).

| Method | Path                  | Auth      | Query / body (illustrative) | Purpose |
|--------|-----------------------|-----------|-----------------------------|---------|
| `GET`  | `/feed`               | Protected | `mood`, `page`, `limit` (or cursor later) | Paginated personalized feed. |
| `GET`  | `/feed/recommended`   | Protected | — | Cold start / editorial or fallback recommendations. |
| `POST` | `/feed/interactions`  | Protected | JSON: `ayahKey`, `interactionType` (`viewed`, `saved`, `reflected`, `shared`, `replayed`, …) | Engagement + ranking signals. |

**Maps to Abstract PRD:** personalized feed, mood-based verses, short daily moments, interaction tracking. Bookmarks may be represented here and/or via Quran.Foundation—finalize in implementation ([PRD.md](PRD.md) §5.4).

---

## 5. Qur’an data (`/quran`)

Ava Quran Backend **does not** host canonical Qur’an text. It **proxies or aggregates** upstream content with Redis caching ([PRD.md](PRD.md) §6.4, §5.5). This section names the **HTTP API the Nest service should call**, how it relates to the **Cursor Quran MCP server**, and the **routes our Flutter client** calls.

### 5.1 Upstream HTTP API — Quran Foundation Content API (v4)

Use the **Quran Foundation Content APIs** (v4) as the production-grade source for chapters, verses, translations, tafsir, audio, search, and related shapes. This is the current successor to the legacy unauthenticated `https://api.quran.com/api/v4/` host (same route shapes for covered endpoints; auth and base URL changed).

| Environment | Content API base | OAuth2 token URL |
|---------------|------------------|------------------|
| Production | `https://apis.quran.foundation` | `https://oauth2.quran.foundation` |
| Pre-production | `https://apis-prelive.quran.foundation` | `https://prelive-oauth2.quran.foundation` |

**Typical request pattern**

- Obtain an access token with **OAuth2 client credentials** and `scope=content` (server-side only; never expose client secret to the mobile app).
- Call Content API paths under `{apiBase}/content/api/v4/...` (e.g. verify with `GET /content/api/v4/chapters`).
- Send headers **`x-auth-token`** (access token) and **`x-client-id`** on every request.

**Official docs (implement against these, not the MCP wire format)**

- Migration (from old api.quran.com): [https://api-docs.quran.foundation/docs/quickstart/migration/](https://api-docs.quran.foundation/docs/quickstart/migration/)
- Portal / category index: [https://api-docs.quran.foundation/](https://api-docs.quran.foundation/) and [https://api-docs.quran.com/](https://api-docs.quran.com/) (Quran.com–branded doc portal; same Content API family).

**Why this matches the product:** [PRD.md](PRD.md) already specifies **Quran.Foundation** OAuth and content orchestration. The Content API v4 is the supported REST surface for that ecosystem.

---

### 5.2 Cursor MCP server `quran` (identifier: `user-quran`)

In Cursor, the enabled **Quran MCP** (`serverName`: `quran`, folder `user-quran` under project MCP config) exposes **canonical text, translations, tafsir, search, morphology, mushaf layout**, etc. Its instructions state data is **verified and sourced from quran.com** — the same lineage as the public Quran.com / Quran Foundation content stack.

| Role | Use MCP | Use Content API v4 from Nest |
|------|---------|-------------------------------|
| **Flutter / mobile** | No — MCP is not an HTTP API for apps | Yes — backend calls Quran Foundation |
| **IDE / AI agents** | Yes — tools like `fetch_quran`, `search_quran`, `fetch_translation`, `fetch_tafsir`, `list_editions`, … | Optional — only if you build server-side agents |

**MCP tools → conceptual mapping for this project** (when designing `/quran/*` payloads and which upstream endpoints to call):

| MCP tool (quran server) | Capability | Maps to Ava Quran route / implementation note |
|-------------------------|------------|-----------------------------------------------|
| `list_editions` | Discover Quran / translation / tafsir edition IDs | Use upstream edition IDs in `GET /quran/ayah/:id` query params; optional internal `GET /quran/editions` if product wants discovery. |
| `fetch_quran` | Exact ayat by key (`2:255`, ranges) | `GET /quran/ayah/:id` (and batching strategy upstream). |
| `fetch_translation` | Translation text for known ayah + edition | Same route or merged ayah payload; call Content API verses + translation resources. |
| `fetch_tafsir` | Tafsir for known ayah + edition | Same route or `?include=tafsir`; upstream tafsir resources. |
| `search_quran` | Semantic search over Arabic + optional translations | `GET /quran/search` — wrap or mirror upstream search contract. |
| `search_translation` | Semantic search filtered by edition(s) | `GET /quran/search` with edition filters, or dedicated query flags. |
| `search_tafsir` | Semantic search over commentary | Optional `GET /quran/search/tafsir` or extend `/quran/search` if product needs thematic tafsir discovery. |
| `fetch_quran_metadata` | Surah / ayah / juz / page / hizb / ruku / manzil structure | `GET /quran/surah/:id` and/or dedicated metadata queries upstream (`chapters`, `juzs`, … per docs). |
| `fetch_word_morphology`, `fetch_word_concordance`, `fetch_word_paradigm` | Word-level linguistics | **Optional** v2 routes (e.g. `/quran/morphology`, `/quran/concordance`) if the app exposes advanced study features. |
| `fetch_mushaf`, `show_mushaf` | Page layout / mushaf UI | **Not required** for typical JSON mobile API; use if you add a web mushaf or server-driven layout. |
| `fetch_grounding_rules`, `fetch_skill_guide` | Citation / agent policy | **Agent-only**; not exposed as Ava Quran REST endpoints. |

---

### 5.3 Ava Quran HTTP surface (client contract)

These are the **routes the mobile app** calls; each handler uses **Quran Foundation Content API v4** (and cache) under the hood unless the team explicitly adds another provider.

| Method | Path               | Auth      | Purpose |
|--------|--------------------|-----------|---------|
| `GET`  | `/quran/ayah/:id`  | Protected | Single ayah + metadata (translations/audio refs as designed). |
| `GET`  | `/quran/surah/:id` | Protected | Surah-level payload. |
| `GET`  | `/quran/search`    | Protected | Keyword/topic search (query params aligned with Content API v4 search/verses). |
| `GET`  | `/quran/related`   | Protected | Related ayahs (query: current ayah or context; implement via upstream “related” or search + ranking). |

**Maps to Abstract PRD:** smart search and ayah discovery via `/quran/search` and related endpoints.

---

## 6. Reflections (`/reflections`)

Private journal tied to `ayah_key` ([PRD.md](PRD.md) §6.5; Abstract PRD: reflection journal).

| Method   | Path                 | Auth      | Purpose |
|----------|----------------------|-----------|---------|
| `POST`   | `/reflections`       | Protected | Create reflection (body: `ayahKey`, `content`, optional `mood`). |
| `GET`    | `/reflections`       | Protected | List timeline (filters: pagination, optional `ayahKey`). |
| `DELETE` | `/reflections/:id` | Protected | Delete owned reflection. |

---

## 7. Collections (`/collections`)

Themed lists of ayahs ([PRD.md](PRD.md) §6.6; Abstract PRD: save & organize by theme).

| Method   | Path                               | Auth      | Purpose |
|----------|------------------------------------|-----------|---------|
| `POST`   | `/collections`                     | Protected | Create collection (`title`, …). |
| `GET`    | `/collections`                     | Protected | List user’s collections. |
| `POST`   | `/collections/:id/ayahs`           | Protected | Add ayah to collection (`ayahKey` in body). |
| `DELETE` | `/collections/:id/ayahs/:ayahId`   | Protected | Remove ayah from collection (`ayahId` = stable ayah key or internal id—define in API spec). |

**Note:** [PRD.md](PRD.md) does not mandate `GET /collections/:id` or rename/delete collection; add in OpenAPI when product confirms.

---

## 8. Streaks (`/streaks`)

Daily habit / consistency ([PRD.md](PRD.md) §6.7; Abstract PRD: streaks).

| Method | Path              | Auth      | Purpose |
|--------|-------------------|-----------|---------|
| `GET`  | `/streaks/me`     | Protected | Current streak, longest streak, last active date. |
| `POST` | `/streaks/update` | Protected | Idempotent daily tick / activity update. |

---

## 9. AI (`/ai`)

Gemini-backed micro-insights and tags ([PRD.md](PRD.md) §6.8; Abstract PRD: AI-powered reflections on cards).

| Method | Path               | Auth      | Purpose |
|--------|--------------------|-----------|---------|
| `POST` | `/ai/insight`      | Protected | Body: `ayahKey`, context; returns short insight (cached per policy). |
| `POST` | `/ai/emotion-tag` | Protected | Body: ayah or text; returns emotional tags for mood matching. |

**NFR:** Rate limiting and graceful degradation (e.g. feed without AI) per [PRD.md](PRD.md) §7.

---

## 10. Summary checklist (MVP vs later)

### MVP (must ship per [PRD.md](PRD.md) §14)

- [ ] All **Auth** endpoints (§2)  
- [ ] All **Users** endpoints (§3)  
- [ ] All **Feed** endpoints (§4)  
- [ ] All **Quran** endpoints (§5)  
- [ ] All **Reflections** endpoints (§6)  
- [ ] All **Collections** endpoints (§7)  
- [ ] All **Streaks** endpoints (§8)  
- [ ] All **AI** endpoints (§9)  
- [x] **`GET /health`** (§1)  

### Optional / follow-up (not required for first PRD MVP)

- Push notifications, realtime, social feed, admin analytics ([PRD.md](PRD.md) §14 OPTIONAL).  
- Extra CRUD on collections (`GET/PATCH/DELETE /collections/:id`) if product needs them.  
- Dedicated “semantic mood search” beyond `/quran/search` if Abstract PRD’s “feeling / life situation” search exceeds plain keyword search.

---

## 11. Abstract PRD → endpoint mapping (quick reference)

| Abstract PRD feature        | Primary API areas                          |
|-----------------------------|--------------------------------------------|
| Personalized feed          | `GET /feed`, `GET /feed/recommended`       |
| Mood-based experience      | `GET /feed` (`mood`), `PATCH /users/preferences`, AI tags |
| Audio-first cards          | Payload from `/feed` + `/quran/ayah/:id`  |
| Short daily moments        | Feed pagination + interactions             |
| AI-powered reflections     | `POST /ai/insight`, optional in feed cards |
| Save & organize ayahs      | `POST /feed/interactions`, `/collections/*` |
| Reflection journal         | `/reflections`                            |
| Daily streaks              | `/streaks/*`                              |
| Smart search               | `GET /quran/search` (+ Content API v4 search) |

---

## 12. Document control

| Field        | Value |
|--------------|--------|
| Product      | Ava Quran |
| Source docs  | [PRD.md](PRD.md), [AbstracPRD.md](AbstracPRD.md) |
| Quran upstream | [Quran Foundation Content API v4](https://api-docs.quran.foundation/docs/quickstart/migration/) (production: `https://apis.quran.foundation`, paths under `/content/api/v4/`) |
| Cursor MCP   | `quran` (`user-quran`) — quran.com–sourced canonical tools for IDE/agents only |
| Last aligned | Backend functional requirements §6; MCP tool inventory from workspace `mcps/user-quran` |

When routes or payloads change, update this file and the implementation’s OpenAPI/Swagger (if added) together.
