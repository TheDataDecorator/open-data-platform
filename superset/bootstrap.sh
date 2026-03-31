#!/bin/bash
set -e


echo "Forcing psycopg2-binary into the Superset venv..."

# 1. We use the system pip but point the 'target' to the venv's library folder
# This bypasses the 'No module named pip' error while putting the files where Superset needs them
pip install --no-cache-dir --target=/app/.venv/lib/python3.10/site-packages psycopg2-binary

echo "Bootstrapping for user: $SUPERSET_ADMIN"

# 2. Wait for Postgres (Internal port 5432)
sleep 10

# 3. Run migrations
superset db upgrade

# 4. Create or Update Admin
# We use the variable names from your .env
USER_EXISTS=$(superset fab list-users | grep "Username:$SUPERSET_ADMIN" || true)

if [ -n "$USER_EXISTS" ]; then
  echo "Admin already exists, resetting password..."
  superset fab reset-password \
    --username "$SUPERSET_ADMIN" \
    --password "$SUPERSET_PASSWORD"
else
  echo "Creating admin user..."
  superset fab create-admin \
    --username "$SUPERSET_ADMIN" \
    --password "$SUPERSET_PASSWORD" \
    --firstname Admin \
    --lastname User \
    --email "$SUPERSET_EMAIL"
fi

# 5. Initialize roles
superset init

echo "Starting Superset..."
# Use the standard server start command
/usr/bin/run-server.sh