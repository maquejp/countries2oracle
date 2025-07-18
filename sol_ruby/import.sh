#!/bin/bash

# Import script for Countries database - Oracle version
# This script imports all SQL files in the correct order

# Usage:
# ./import.sh [username] [database]
# Example: ./import.sh scott localhost:1521/XE

USERNAME=${1:-scott}
DATABASE=${2:-localhost:1521/XE}

echo "Importing Countries database to Oracle..."
echo "Username: $USERNAME"
echo "Database: $DATABASE"
echo ""

# Check if SQL*Plus is available
if ! command -v sqlplus &> /dev/null; then
    echo "Error: SQL*Plus not found. Please install Oracle client."
    exit 1
fi

# Check if SQL files exist
if [ ! -f "SQLs/schema.sql" ]; then
    echo "Error: SQLs/schema.sql not found. Please run 'ruby generate_countries_sql.rb --separate' first."
    exit 1
fi

echo "Step 1: Creating database schema..."
sqlplus "$USERNAME/$PASSWORD@$DATABASE" @SQLs/schema.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to create schema"
    exit 1
fi

echo "Step 2: Importing regions..."
sqlplus "$USERNAME/$PASSWORD@$DATABASE" @SQLs/regions.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to import regions"
    exit 1
fi

echo "Step 3: Importing subregions..."
sqlplus "$USERNAME/$PASSWORD@$DATABASE" @SQLs/subregions.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to import subregions"
    exit 1
fi

echo "Step 4: Importing countries..."
sqlplus "$USERNAME/$PASSWORD@$DATABASE" @SQLs/countries.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to import countries"
    exit 1
fi

echo ""
echo "Import completed successfully!"
echo ""
echo "Verifying data..."
mysql -u "$USERNAME" -p "$DATABASE" -e "
SELECT 
    (SELECT COUNT(*) FROM regions) as regions_count,
    (SELECT COUNT(*) FROM subregions) as subregions_count,
    (SELECT COUNT(*) FROM countries) as countries_count;
"
