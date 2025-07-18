#!/bin/bash

# Oracle SQL Generator for Countries Data
# Automated setup script

echo "Oracle SQL Generator for Countries Data"
echo "======================================"

# Check if countries.json exists
if [ ! -f "countries.json" ]; then
    echo "Downloading countries.json from GitHub..."
    curl -o countries.json https://raw.githubusercontent.com/mledoze/countries/master/countries.json
    
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

# Run the SQL generator
echo "Running SQL generator..."
python3 generate_oracle_sql.py

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SQL files generated successfully!"
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
