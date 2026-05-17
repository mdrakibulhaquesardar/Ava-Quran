# Production Deployment Guide (aaPanel)

This guide explains how to host the **Ava Quran Backend** on your server using aaPanel's Docker Controller.

## Prerequisites
1. **aaPanel** installed on your server.
2. **Docker Manager** (or Docker Controller) installed from the aaPanel App Store.

## Step 1: Prepare Files
Upload the following files from the `Backend` directory to a folder on your server (e.g., `/www/wwwroot/ava-quran-backend`):
- `Dockerfile`
- `docker-compose.prod.yml`
- `docker-entrypoint.sh`
- `.dockerignore`
- `package.json` & `package-lock.json`
- `prisma/` (entire directory)
- `src/` (entire directory)
- `tsconfig.json` & `tsconfig.build.json`
- `nest-cli.json`

## Step 2: Configure Environment Variables
Create a `.env` file in the same directory on the server or prepare the variables for aaPanel. At minimum, you should set:
- `JWT_SECRET` (Long random string)
- `POSTGRES_PASSWORD` (Secure password)
- `QURAN_CLIENT_ID` / `QURAN_CLIENT_SECRET` (From Quran Foundation)
- `GROQ_API_KEY` (For Gemini/AI features)

## Step 3: Deployment via aaPanel Docker Controller

1. Open **Docker** in aaPanel.
2. Go to **Compose** tab.
3. Click **Add Compose**.
4. **Compose Name**: `ava-quran`
5. **Compose File**: Select the `docker-compose.prod.yml` you uploaded.
6. Click **Add**.
7. aaPanel will pull the images (Postgres, Redis) and build your API image using the `runner` stage (optimized for production).

## Step 4: Setup Reverse Proxy (Optional but Recommended)

To access your API via a domain (e.g., `api.avaquran.com`):
1. Go to **Website** -> **Add Site**.
2. Add your domain.
3. Go to Site **Settings** -> **Reverse Proxy**.
4. **Add Reverse Proxy**:
   - **Name**: `Backend`
   - **Target URL**: `http://127.0.0.1:3000` (Change 3000 if you modified `API_PORT` in compose).
5. Setup **SSL** (Let's Encrypt) for your domain in aaPanel.

## Database Migrations
The `docker-entrypoint.sh` is configured to automatically run `npx prisma migrate deploy` whenever the container starts in production mode. This ensures your database schema is always up to date without losing data.

## Maintenance
- **Update Code**: Pull latest changes, and restart the Compose project in aaPanel. It will rebuild only the necessary layers.
- **Logs**: View logs directly in aaPanel Docker Manager to troubleshoot.
