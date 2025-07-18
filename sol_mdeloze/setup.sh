#!/bin/bash

# Oracle SQL Generator for Countries Data with Membership Fields
# Automated setup script

echo "Oracle SQL Generator for Countries Data with Membership Fields"
echo "============================================================="

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
    echo "Creating data directory..."
    mkdir -p data
    echo "✓ data directory created"
fi

# Check if countries.json exists
if [ ! -f "data/countries.json" ]; then
    echo "Downloading countries.json from GitHub..."
    curl -o data/countries.json https://raw.githubusercontent.com/mledoze/countries/master/countries.json
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download countries.json"
        exit 1
    fi
    
    echo "✓ countries.json downloaded successfully"
else
    echo "✓ countries.json already exists"
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

# Add membership fields to countries data
echo "Adding EU, EFTA, and EEA membership fields..."
python3 add_membership_fields.py

if [ $? -ne 0 ]; then
    echo "✗ Error occurred while adding membership fields"
    exit 1
fi

echo "✓ Membership fields added successfully"

# Run the SQL generator
echo "Running SQL generator..."
python3 generate_oracle_sql.py

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SQL files generated successfully!"
    echo ""
    echo "Project structure:"
    echo "├── data/"
    echo "│   ├── countries.json (original)"
    echo "│   ├── countries_amended.json (with membership fields)"
    echo "│   └── countries_original.json (backup)"
    echo "└── SQLs/"
    echo "    ├── 00_master_script.sql"
    echo "    ├── 01_create_tables.sql"
    echo "    ├── 02_insert_regions.sql"
    echo "    ├── 03_insert_subregions.sql"
    echo "    ├── 04_insert_countries.sql"
    echo "    └── 05_example_queries.sql"
    echo ""
    echo "Database features:"
    echo "• EU membership data (27 countries)"
    echo "• EFTA membership data (4 countries)"
    echo "• EEA membership data (30 countries)"
    echo "• Example queries for membership filtering"
    echo ""
    echo "Next steps:"
    echo "1. Connect to your Oracle database"
    echo "2. Navigate to the SQLs directory"
    echo "3. Run: @00_master_script.sql"
    echo ""
    echo "Generated files:"
    ls -la SQLs/
else
    echo "✗ Error occurred during SQL generation"
    exit 1
fi
# --- generated commit ---
