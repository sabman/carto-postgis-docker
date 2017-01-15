#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_carto' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_carto;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_carto';
EOSQL
createdb $CARTO_DB_NAME\_$CARTO_ENV
# Load Carto into both template_database and $POSTGRES_DB
for DB in template_carto $CARTO_DB_NAME\_$CARTO_ENV; do
	echo "Loading Carto extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
    CREATE EXTENSION IF NOT EXISTS pgrouting;
    CREATE EXTENSION IF NOT EXISTS cartodb CASCADE;
EOSQL
done
