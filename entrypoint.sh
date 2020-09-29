#!/bin/bash
set -e

echo "Creating database if it's not present..."
bin/rails db:create

echo "Migrating database..."
bin/rails db:migrate:with_data

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails-app/tmp/pids/server.pid

exec "$@"