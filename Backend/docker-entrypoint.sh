#!/bin/sh
set -e

# Run migrations if in production, otherwise push (or as needed)
if [ "$NODE_ENV" = "production" ]; then
  echo "Running production migrations..."
  npx prisma migrate deploy
else
  echo "Running development db push..."
  npx prisma db push --accept-data-loss
fi

exec node dist/main.js
