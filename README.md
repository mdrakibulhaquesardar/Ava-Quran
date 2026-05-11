# Ava Quran Backend

NestJS API for **Ava Quran**: personalized Qur’an feed, reflections, collections, streaks, and integrations (see [docs/PRD.md](docs/PRD.md)).

## Stack

- NestJS 11, TypeScript  
- PostgreSQL + Prisma 6  
- Redis (ioredis)  
- Docker Compose for local full stack  

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Compose v2  
- Node.js 22+ (for local development without rebuilding the API container)  

## Quick start (Docker)

From this directory:

```bash
cp .env.example .env
docker compose up --build
```

Then open [http://localhost:3000/health](http://localhost:3000/health). You should see JSON with `status: "ok"` and `database` / `redis` checks when Postgres and Redis are healthy.

Default Compose URLs:

- API: `http://localhost:3000`  
- Postgres: `localhost:5432` (user `ava`, password `ava`, database `ava_quran`)  
- Redis: `localhost:6379`  

Stop the stack:

```bash
docker compose down
```

## Local development (API on host, DB in Docker)

Run only Postgres and Redis, then the Nest app with hot reload:

```bash
docker compose up -d postgres redis
cp .env.example .env
# Ensure .env DATABASE_URL and REDIS_URL match docker-compose ports (defaults work).
npm install
npx prisma migrate dev
npm run start:dev
```

## Scripts

| Command | Description |
|---------|-------------|
| `npm run start:dev` | Nest watch mode |
| `npm run build` | Production build |
| `npm run start:prod` | Run compiled `dist` (after `build`) |
| `npm run test` | Unit tests |
| `npm run test:e2e` | E2E tests (needs DB + Redis; use Compose first) |
| `npm run prisma:migrate` | Create/apply dev migrations |
| `npm run prisma:deploy` | Apply migrations (production / CI) |
| `npm run prisma:generate` | Regenerate Prisma Client |

## Environment variables

Copy [.env.example](.env.example) to `.env` and adjust. Secrets for Quran.Foundation and Gemini are placeholders until those modules are implemented.

## Production image

The [Dockerfile](Dockerfile) builds a non-root image, runs `prisma migrate deploy` on start via [docker-entrypoint.sh](docker-entrypoint.sh), then starts the Nest app.
