#!/bin/sh
set -e

echo "Synchronizing database schema with Prisma schema..."
npx prisma db push --accept-data-loss

exec node dist/main.js
