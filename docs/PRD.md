# Ava Quran — Backend Product Requirements Document (PRD)

**Product:** Ava Quran  
**Component:** Backend API (NestJS)  
**Audience:** Engineers, architects, and stakeholders defining scope for the Ava Quran mobile experience.

This document describes what the **Ava Quran** backend does, how it fits into the product, which technologies it uses (including **Docker** for local development and deployment packaging), and what must ship for MVP versus later phases. 

---

## 1. Product vision and positioning

### 1.1 What is Ava Quran?

**Ava Quran** is a personalized, short-form Quran engagement experience for mobile users. The app surfaces ayahs, translations, audio, and gentle AI-assisted reflections in a feed-oriented flow so users can build a daily habit of connection with the Qur’an—aligned to mood, time, and their own saved reflections and collections.

### 1.2 What this backend is responsible for

The **Ava Quran Backend** is the authoritative server for:

- **Identity and sessions** — OAuth with Quran.Foundation, JWT issuance, refresh and logout.
- **Personalized feed** — Ranking, mood-aware suggestions, and caching so the feed stays fast.
- **AI-assisted content** — Micro-insights, emotional tags, and short summaries via Gemini, with caching where appropriate.
- **User-owned data** — Reflections, collections, streaks, and engagement history stored in our PostgreSQL database (distinct from or layered on top of Quran.Foundation APIs as designed).
- **Orchestration** — Calling Quran.Foundation for canonical Qur’an data (verses, translations, tafsir, audio) and combining it with our personalization and AI layers.

### 1.3 What this backend is not

- It is not the Flutter/mobile client (client handles UI, playback UX, and local state).
- It is not the source of truth for the Qur’anic text itself—that remains with **Quran.Foundation** APIs; we aggregate, personalize, and enrich.

### 1.4 Conceptual data flow

```text
┌─────────────────────┐
│  Ava Quran (Mobile) │
│  Flutter app        │
└──────────┬──────────┘
           │ HTTPS / JSON
           ▼
┌─────────────────────┐
│  Ava Quran Backend  │
│  NestJS + Prisma    │
└──────────┬──────────┘
           │
     ┌─────┴─────┬─────────────────┬──────────────────┐
     ▼           ▼                 ▼                  ▼
┌─────────┐ ┌──────────┐   ┌─────────────┐   ┌──────────────┐
│PostgreSQL│ │  Redis   │   │ Quran.      │   │ Google       │
│ (app data)│ │ (cache)  │   │ Foundation  │   │ Gemini API   │
└─────────┘ └──────────┘   │ OAuth + APIs│   └──────────────┘
                            └─────────────┘
```

**Plain-language summary:** The mobile app talks only to **Ava Quran Backend**. The backend reads/writes **PostgreSQL** for profiles, reflections, collections, streaks, and feed history; uses **Redis** for hot paths (feed, ayah payloads, AI snippets); calls **Quran.Foundation** for Qur’an content and OAuth; and calls **Gemini** for generative assists.

---

## 2. Goals and objectives

### 2.1 Primary objectives

| Objective | Description |
|-----------|-------------|
| Personalized feed APIs | Stable, paginated feed that respects mood, history, bookmarks, and streak context. |
| Quran.Foundation integration | Reliable use of OAuth2/OIDC and content APIs without duplicating canonical text storage. |
| Secure authentication | OAuth flow, JWT access, refresh rotation, and clear logout semantics. |
| AI-powered insights | Small, safe, cacheable insights and tags that enhance—not replace—scholarship and user reflection. |
| Engagement and habit | Streaks, interaction logging, and signals that improve ranking over time. |
| Reflections and collections | First-class user content with CRUD and linkage to ayah keys. |
| Performance | Redis-backed caching so repeat and similar requests stay within latency targets. |

### 2.2 Success criteria (recap)

- **Technical:** Predictable API latency, stable feed under load, correct OAuth/JWT behavior, observable errors, cache hit rate where designed.
- **Product:** Backend supports a calm, personalized daily loop: open app → meaningful ayah → optional reflection → save/share habit.

---

## 3. Technology stack

| Layer | Choice | Role |
|-------|--------|------|
| Runtime / API | **NestJS** | Modular HTTP API, guards, interceptors, domain modules. |
| Language | **TypeScript** | Type-safe services and DTOs. |
| Database | **PostgreSQL** | Durable user data, reflections, collections, streaks, feed history. |
| ORM | **Prisma** | Schema migrations, queries, type-safe DB access. |
| Cache | **Redis** | Feed fragments, ayah bundles, AI insight keys, streak snapshots, trending keys. |
| AI | **Google Gemini API** | Summaries, tags, prompts; responses cached when idempotent. |
| Auth (external IdP) | **Quran.Foundation OAuth2 / OIDC** | User login and token exchange; app issues its own JWTs for API access. |
| **Containerization** | **Docker + Docker Compose** | **Standard way to run the stack locally and to package the API for deployment** (see §3.1). |
| Hosting (examples) | Railway / Render / Fly.io | Stateless API + managed Postgres/Redis or container platform. |

### 3.1 Docker and Docker Compose (explicit)

**Ava Quran** standardizes on **Docker** for:

1. **Local development** — One command brings up API + PostgreSQL + Redis with consistent versions across machines (no “works on my machine” drift for database and cache).
2. **Deployment artifact** — The NestJS API is built into a **container image** so staging and production run the same bits as CI builds.
3. **Compose topology** — **Docker Compose** defines the multi-service stack (typically `api`, `postgres`, `redis`) with shared networks, named volumes for Postgres data, and environment files for secrets in dev.

**Typical Compose-oriented workflow:**

- Developers copy `.env.example` → `.env`, run `docker compose up` (or equivalent) to start dependencies and the API.
- Migrations run against the Compose Postgres URL (`DATABASE_URL`).
- Redis URL (`REDIS_URL`) points at the Compose `redis` service.

> **Note:** If production uses a managed Postgres/Redis instead of containers for data stores, Docker still applies to the **API image**; only the backing services may be hosted as managed products.

---

## 4. System architecture (high level)

```text
Ava Quran (Flutter mobile app)
              │
              ▼
    Ava Quran Backend (NestJS)
              │
    ┌─────────┼─────────────┬────────────────┐
    ▼         ▼             ▼                ▼
PostgreSQL   Redis    Quran.Foundation   Gemini API
(app DB)    (cache)   (OAuth + Qur’an)   (AI)
```

### 4.1 Module-level responsibilities (conceptual)

- **Auth** — OAuth redirect/callback, session bootstrap, JWT + refresh.
- **Users** — Profile, preferences, onboarding flags, mood defaults.
- **Feed** — Assemble ranked list of “cards” (ayah + translation + audio ref + optional AI + tags).
- **Quran** — Proxy/aggregate Quran.Foundation reads (ayah, surah, search, related) with caching.
- **Reflections** — User journal entries tied to `ayah_key` and optional mood.
- **Collections** — User-defined lists of ayahs (themes, memorization sets, etc.).
- **Streaks** — Daily activity rules, longest streak, last active date.
- **AI** — Insight and tagging endpoints with rate limits and cache keys.

---

## 5. Core backend responsibilities (detailed)

### 5.1 Authentication

- Initiate and complete **Quran.Foundation OAuth** flow.
- Issue **JWT** access tokens for Ava Quran API routes.
- **Refresh token** handling (rotation preferred where applicable).
- **Logout** — Invalidate refresh/session server-side where stored.

### 5.2 Feed system

- **Personalized ayah recommendation** using ranking signals (§10).
- **Mood-based** filtering and boosting.
- **Feed ranking** that balances novelty, relevance, and engagement.
- **Feed caching** in Redis keyed by user + mood + page slice where safe.

### 5.3 AI processing

- **Micro insights** — Short, contextual lines tied to a specific ayah context.
- **Emotional categorization** — Tags for mood matching in the feed.
- **Simplified summaries** — Not a substitute for tafsir; clearly scoped.
- **AI response caching** — Dedupe by ayah key + prompt version to control cost and latency.

### 5.4 User engagement

- **Streaks** — Per-user daily continuity.
- **Interactions** — View, save, reflect, share, replay events for ranking and analytics.
- **Reflections** — Persistent user text linked to ayahs.
- **Bookmarks** — Coordinate with Quran.Foundation where bookmarks live there vs locally (product decision: document in implementation).

### 5.5 Qur’an data orchestration

- Fetch **verses**, **translations**, **tafsir**, **recitations**, **search** via Quran.Foundation.
- Normalize **ayah keys** across modules (feed, reflections, collections) so the same identifier is used everywhere.

---

## 6. Functional requirements

### 6.1 Authentication module

**Features**

- Quran.Foundation OAuth login
- JWT authentication for API
- Access/refresh storage and rotation policy
- Logout

**Endpoints (illustrative)**

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/login` | Start OAuth (redirect URL or URL return). |
| GET | `/auth/callback` | OAuth callback; exchange code; issue tokens. |
| POST | `/auth/refresh` | Refresh JWT. |
| POST | `/auth/logout` | End session / revoke refresh. |

---

### 6.2 User module

**Features**

- Profile (name, avatar, email as allowed)
- Preferences (language, reciter, notifications flags if added later)
- Onboarding completion state
- Mood preferences for default feed

**Endpoints**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/users/me` | Current user profile + prefs. |
| PATCH | `/users/preferences` | Update preferences. |
| PATCH | `/users/onboarding` | Mark onboarding steps. |

---

### 6.3 Feed module

**Features**

- Personalized Qur’an feed
- Mood-based recommendations
- AI-enhanced cards where enabled
- Infinite-style pagination (`page` / `limit` or cursor—finalize in API design)

**Inputs (ranking context)**

- `mood`, user history, bookmarks, time of day, streak state, recent reflections

**Outputs (per item)**

- Ayah identifier and text (or reference), translation, audio URL, optional AI insight, emotional tags

**Endpoints**

| Method | Path | Query / body | Purpose |
|--------|------|----------------|---------|
| GET | `/feed` | `mood`, `page`, `limit` | Main feed page. |
| GET | `/feed/recommended` | — | Curated or cold-start path. |
| POST | `/feed/interactions` | interaction type + ayah ref | Track viewed, saved, reflected, shared, replayed. |

---

### 6.4 Qur’an module

**Features**

- Ayah / surah retrieval
- Translation and tafsir retrieval
- Audio retrieval
- Search and related ayahs

**Endpoints**

| Method | Path |
|--------|------|
| GET | `/quran/ayah/:id` |
| GET | `/quran/surah/:id` |
| GET | `/quran/search` |
| GET | `/quran/related` |

---

### 6.5 Reflection module

**Features**

- Create, list, delete reflections
- Optional tags / mood on reflection

**Endpoints**

| Method | Path |
|--------|------|
| POST | `/reflections` |
| GET | `/reflections` |
| DELETE | `/reflections/:id` |

---

### 6.6 Collections module

**Features**

- CRUD collections
- Add/remove ayahs in a collection

**Endpoints**

| Method | Path |
|--------|------|
| POST | `/collections` |
| GET | `/collections` |
| POST | `/collections/:id/ayahs` |
| DELETE | `/collections/:id/ayahs/:ayahId` |

---

### 6.7 Streak module

**Features**

- Current streak, longest streak
- Last active date and idempotent “daily tick” rules

**Endpoints**

| Method | Path |
|--------|------|
| GET | `/streaks/me` |
| POST | `/streaks/update` |

---

### 6.8 AI module

**Features**

- Insight generation, emotion tagging, optional tafsir-style **short** summary (product guardrails)

**Endpoints**

| Method | Path |
|--------|------|
| POST | `/ai/insight` |
| POST | `/ai/emotion-tag` |

---

## 7. Non-functional requirements

| Area | Requirement |
|------|----------------|
| **Performance** | Feed p95 target **under 500ms** without cache cold start; cached hot keys **under 100ms** where measured at edge of API + Redis. |
| **Scalability** | Stateless API instances behind a load balancer; horizontal scale; Redis as shared cache. |
| **Security** | HTTPS only; secrets in env; OAuth state parameter; JWT validation on all protected routes; rate limiting on auth and AI. |
| **Reliability** | Retries with backoff for Quran.Foundation and Gemini; graceful degradation (e.g. feed without AI if AI fails). |
| **Observability** | Structured logs, correlation IDs; optional Sentry/Grafana later. |

---

## 8. Redis caching strategy

| Key pattern | Purpose |
|-------------|---------|
| `feed:user:{userId}:{mood}` | Cached feed slices |
| `ayah:{ayahKey}` | Bundled ayah + translation metadata |
| `insight:{ayahKey}` | Cached AI insight (version prompt in key if needed) |
| `trending:topics` | Optional trending / editorial boosts |
| `streak:{userId}` | Fast read for streak badge |

Invalidation: document per-key TTL and events (e.g. user preference change invalidates feed keys for that user).

---

## 9. Database schema (high level)

Conceptual tables (exact Prisma models to match implementation):

**users** — `id`, `email`, `name`, `avatar`, `preferred_language`, `favorite_reciter`, `created_at`, …

**reflections** — `id`, `user_id`, `ayah_key`, `mood`, `content`, `created_at`

**collections** — `id`, `user_id`, `title`, `created_at`

**collection_ayahs** — `id`, `collection_id`, `ayah_key`, `created_at`

**feed_history** — `id`, `user_id`, `ayah_key`, `interaction_type`, `created_at`

**streaks** — `id`, `user_id`, `current_streak`, `longest_streak`, `last_active_date`

---

## 10. Feed recommendation logic (concept)

Ranking combines:

1. **Mood matching** — User mood ↔ emotional tags on ayahs or AI-assigned tags.
2. **Behavioral matching** — Saved ayahs, listening patterns, reflections.
3. **Session timing** — Morning/night/Ramadan/returning-user treatments.
4. **Engagement optimization** — Slightly favor shorter ayahs, calming recitations, historically high-save content (ethical bounds: no manipulative dark patterns).

Weights and exact model are implementation details; this PRD locks the **signal types** and **user-facing goals**.

---

## 11. External integrations

### 11.1 Quran.Foundation

- **Content:** verses, translations, tafsir, recitations, search  
- **User (where applicable):** bookmarks, collections, streaks, preferences—align with what Ava Quran stores locally vs delegates  
- **OAuth:** login and token exchange

### 11.2 Gemini

- Ayah-aligned summaries, emotional tags, contextual insights, reflection prompts  
- **Caching and moderation** are mandatory engineering concerns (cost, latency, safety).

---

## 12. DevOps: Docker Compose and environment

### 12.1 Compose services (target layout)

```yaml
# Illustrative — align filenames with repo (e.g. docker-compose.yml)
services:
  api:        # Ava Quran Backend (NestJS) container
  postgres:   # PostgreSQL for app data
  redis:      # Redis for cache
```

Volumes: persistent volume for Postgres. Networks: internal bridge between `api`, `postgres`, and `redis`.

### 12.2 Environment variables (illustrative)

```env
DATABASE_URL=
REDIS_URL=

JWT_SECRET=

QURAN_CLIENT_ID=
QURAN_CLIENT_SECRET=
# Quran.Foundation OAuth redirect URIs configured at IdP

GEMINI_API_KEY=
```

### 12.3 CI/CD

Optional for MVP; recommended path is build Docker image in CI, run tests, push image to registry, deploy to chosen host.

---

## 13. Logging and monitoring

- **Logging:** NestJS logger, request IDs, structured error fields for Quran.Foundation and Gemini failures.  
- **Monitoring (optional):** Sentry for exceptions; Grafana/metrics later for latency and cache hit rate.

---

## 14. MVP scope (hackathon / first release)

**Must build**

- Authentication (OAuth + JWT)  
- Feed system + interactions  
- Ayah/Qur’an proxy APIs  
- AI micro insights (with fallbacks)  
- Reflections and collections  
- Streak tracking  
- Redis caching  
- **Docker Compose** for local full stack  

**Optional (post-MVP)**

- Push notifications  
- Realtime (WebSockets)  
- Social feed  
- Advanced analytics dashboard  
- Admin dashboard  

---

## 15. Future scalability

- Stronger **ML** recommendation layer  
- **AI voice** reflections (policy-heavy)  
- **Multilingual** AI summaries  
- Social sharing of reflections (moderation)  
- Push personalization  
- Wearables / offline sync strategies  

---

## 16. Glossary

| Term | Meaning |
|------|---------|
| **Ava Quran** | The product: mobile-first Qur’an engagement app. |
| **Ava Quran Backend** | This NestJS service. |
| **Ayah key** | Stable identifier for a verse used across feed, DB, and cache. |
| **Quran.Foundation** | External platform for Qur’anic content and OAuth. |
| **Feed card** | One scroll unit: ayah + metadata + optional AI. |

---

## Document control

| Field | Value |
|-------|--------|
| Product name | **Ava Quran** |
| Component | Backend PRD |
| Stack highlights | NestJS, TypeScript, PostgreSQL, Prisma, Redis, Gemini, Quran.Foundation OAuth, **Docker / Docker Compose** |

Update this document when major API boundaries, auth model, or hosting strategy change.
