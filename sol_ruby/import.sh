#!/bin/bash

# Import script for Countries database
# This script imports all SQL files in the correct order

# Usage:
# ./import.sh [database_name] [username]
# Example: ./import.sh countries_db root

DATABASE=${1:-countries_db}
USERNAME=${2:-root}

echo "Importing Countries database..."
echo "Database: $DATABASE"
echo "Username: $USERNAME"
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo "Error: MySQL client not found. Please install MySQL client."
    exit 1
fi

# Check if SQL files exist
if [ ! -f "SQLs/schema.sql" ]; then
    echo "Error: SQLs/schema.sql not found. Please run 'ruby generate_countries_sql.rb --separate' first."
    exit 1
fi

echo "Step 1: Creating database schema..."
mysql -u "$USERNAME" -p "$DATABASE" < SQLs/schema.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to create schema"
    exit 1
fi

echo "Step 2: Importing regions..."
mysql -u "$USERNAME" -p "$DATABASE" < SQLs/regions.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to import regions"
    exit 1
fi

echo "Step 3: Importing subregions..."
mysql -u "$USERNAME" -p "$DATABASE" < SQLs/subregions.sql
if [ $? -ne 0 ]; then
    echo "Error: Failed to import subregions"
    exit 1
fi

echo "Step 4: Importing countries..."
mysql -u "$USERNAME" -p "$DATABASE" < SQLs/countries.sql
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
