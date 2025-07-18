#!/usr/bin/env python3
"""
Oracle SQL Generator for Countries Data
Based on https://github.com/mledoze/countries

This script generates SQL files to insert country data into an Oracle database.
The data is split into regions, subregions, and countries tables.
"""

import json
import os
import re
from collections import defaultdict
from datetime import datetime
from typing import Dict, List, Set, Any


class OracleSQLGenerator:
    def __init__(self, json_file: str, output_dir: str = "SQLs"):
        self.json_file = json_file
        self.output_dir = output_dir
        self.regions = set()
        self.subregions = set()
        self.countries = []
        
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
    def load_data(self):
        """Load and parse the countries JSON data"""
        print("Loading countries data...")
        with open(self.json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for country in data:
            # Extract region and subregion
            region = country.get('region', '')
            subregion = country.get('subregion', '')
            
            if region:
                self.regions.add(region)
            if subregion:
                self.subregions.add(subregion)
            
            self.countries.append(country)
        
        print(f"Loaded {len(self.countries)} countries")
        print(f"Found {len(self.regions)} regions")
        print(f"Found {len(self.subregions)} subregions")
    
    def escape_sql_string(self, value: str) -> str:
        """Escape single quotes in SQL strings"""
        if value is None:
            return 'NULL'
        return "'" + str(value).replace("'", "''") + "'"
    
    def format_array_to_string(self, arr: List[Any]) -> str:
        """Convert array to comma-separated string"""
        if not arr:
            return ''
        return ', '.join(str(item) for item in arr)
    
    def generate_table_creation_scripts(self):
        """Generate table creation scripts"""
        print("Generating table creation scripts...")
        
        # Create table creation script
        create_tables_sql = f"""-- Oracle SQL Table Creation Script
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
-- Based on: https://github.com/mledoze/countries

-- Drop tables if they exist (in correct order due to foreign keys)
DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE subregions CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;

-- Create REGIONS table
CREATE TABLE regions (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(100) NOT NULL UNIQUE,
    created_date DATE DEFAULT SYSDATE
);

-- Create SUBREGIONS table
CREATE TABLE subregions (
    subregion_id NUMBER PRIMARY KEY,
    subregion_name VARCHAR2(100) NOT NULL,
    region_id NUMBER,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_subregion_region FOREIGN KEY (region_id) REFERENCES regions(region_id),
    CONSTRAINT uk_subregion_name UNIQUE (subregion_name, region_id)
);

-- Create COUNTRIES table
CREATE TABLE countries (
    country_id NUMBER PRIMARY KEY,
    -- Basic country information
    common_name VARCHAR2(100) NOT NULL,
    official_name VARCHAR2(200),
    cca2 CHAR(2) UNIQUE,
    cca3 CHAR(3) UNIQUE,
    ccn3 CHAR(3),
    cioc CHAR(3),
    
    -- Status information
    independent NUMBER(1) DEFAULT 0,
    status VARCHAR2(50),
    un_member NUMBER(1) DEFAULT 0,
    un_regional_group VARCHAR2(100),
    
    -- Geographic information
    region_id NUMBER,
    subregion_id NUMBER,
    capital VARCHAR2(500), -- Can be multiple capitals
    latlng VARCHAR2(50), -- Stored as "lat,lng"
    landlocked NUMBER(1) DEFAULT 0,
    borders VARCHAR2(1000), -- Comma-separated country codes
    area NUMBER,
    
    -- Additional information
    tld VARCHAR2(200), -- Top-level domains
    currencies VARCHAR2(1000), -- JSON string of currencies
    languages VARCHAR2(1000), -- JSON string of languages
    alt_spellings VARCHAR2(1000), -- Comma-separated alternative spellings
    flag_emoji VARCHAR2(10),
    
    -- Metadata
    created_date DATE DEFAULT SYSDATE,
    
    -- Foreign key constraints
    CONSTRAINT fk_country_region FOREIGN KEY (region_id) REFERENCES regions(region_id),
    CONSTRAINT fk_country_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(subregion_id)
);

-- Create indexes for better performance
CREATE INDEX idx_countries_region ON countries(region_id);
CREATE INDEX idx_countries_subregion ON countries(subregion_id);
CREATE INDEX idx_countries_cca2 ON countries(cca2);
CREATE INDEX idx_countries_cca3 ON countries(cca3);
CREATE INDEX idx_countries_independent ON countries(independent);
CREATE INDEX idx_countries_un_member ON countries(un_member);

-- Add comments to tables
COMMENT ON TABLE regions IS 'World regions (continents)';
COMMENT ON TABLE subregions IS 'World subregions within continents';
COMMENT ON TABLE countries IS 'World countries and territories based on ISO 3166-1';

-- Add comments to columns
COMMENT ON COLUMN countries.common_name IS 'Common name in English';
COMMENT ON COLUMN countries.official_name IS 'Official name in English';
COMMENT ON COLUMN countries.cca2 IS 'ISO 3166-1 alpha-2 code';
COMMENT ON COLUMN countries.cca3 IS 'ISO 3166-1 alpha-3 code';
COMMENT ON COLUMN countries.ccn3 IS 'ISO 3166-1 numeric code';
COMMENT ON COLUMN countries.cioc IS 'International Olympic Committee code';
COMMENT ON COLUMN countries.independent IS '1 if independent sovereign state, 0 otherwise';
COMMENT ON COLUMN countries.un_member IS '1 if UN member, 0 otherwise';
COMMENT ON COLUMN countries.landlocked IS '1 if landlocked, 0 otherwise';
COMMENT ON COLUMN countries.area IS 'Area in square kilometers';
COMMENT ON COLUMN countries.flag_emoji IS 'Unicode flag emoji';

COMMIT;
"""
        
        # Write to file
        with open(os.path.join(self.output_dir, '01_create_tables.sql'), 'w', encoding='utf-8') as f:
            f.write(create_tables_sql)
        
        print("Table creation script generated: 01_create_tables.sql")
    
    def generate_regions_insert(self):
        """Generate INSERT statements for regions"""
        print("Generating regions INSERT statements...")
        
        sql_content = f"""-- Insert statements for REGIONS table
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

"""
        
        # Sort regions for consistent output
        sorted_regions = sorted(self.regions)
        
        for idx, region in enumerate(sorted_regions, 1):
            if region:  # Skip empty regions
                sql_content += f"INSERT INTO regions (region_id, region_name) VALUES ({idx}, {self.escape_sql_string(region)});\n"
        
        sql_content += "\nCOMMIT;\n"
        
        # Write to file
        with open(os.path.join(self.output_dir, '02_insert_regions.sql'), 'w', encoding='utf-8') as f:
            f.write(sql_content)
        
        print(f"Regions INSERT script generated: 02_insert_regions.sql ({len(sorted_regions)} regions)")
    
    def generate_subregions_insert(self):
        """Generate INSERT statements for subregions"""
        print("Generating subregions INSERT statements...")
        
        # Map subregions to their regions
        subregion_to_region = {}
        for country in self.countries:
            region = country.get('region', '')
            subregion = country.get('subregion', '')
            if region and subregion:
                subregion_to_region[subregion] = region
        
        # Create region name to ID mapping
        sorted_regions = sorted(self.regions)
        region_to_id = {region: idx for idx, region in enumerate(sorted_regions, 1)}
        
        sql_content = f"""-- Insert statements for SUBREGIONS table
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

"""
        
        # Sort subregions for consistent output
        sorted_subregions = sorted(subregion_to_region.keys())
        
        for idx, subregion in enumerate(sorted_subregions, 1):
            region = subregion_to_region[subregion]
            region_id = region_to_id[region]
            sql_content += f"INSERT INTO subregions (subregion_id, subregion_name, region_id) VALUES ({idx}, {self.escape_sql_string(subregion)}, {region_id});\n"
        
        sql_content += "\nCOMMIT;\n"
        
        # Write to file
        with open(os.path.join(self.output_dir, '03_insert_subregions.sql'), 'w', encoding='utf-8') as f:
            f.write(sql_content)
        
        print(f"Subregions INSERT script generated: 03_insert_subregions.sql ({len(sorted_subregions)} subregions)")
    
    def generate_countries_insert(self):
        """Generate INSERT statements for countries"""
        print("Generating countries INSERT statements...")
        
        # Create mappings for region and subregion IDs
        sorted_regions = sorted(self.regions)
        region_to_id = {region: idx for idx, region in enumerate(sorted_regions, 1)}
        
        # Map subregions to their regions and create subregion ID mapping
        subregion_to_region = {}
        for country in self.countries:
            region = country.get('region', '')
            subregion = country.get('subregion', '')
            if region and subregion:
                subregion_to_region[subregion] = region
        
        sorted_subregions = sorted(subregion_to_region.keys())
        subregion_to_id = {subregion: idx for idx, subregion in enumerate(sorted_subregions, 1)}
        
        sql_content = f"""-- Insert statements for COUNTRIES table
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

"""
        
        # Sort countries by common name for consistent output
        sorted_countries = sorted(self.countries, key=lambda x: x.get('name', {}).get('common', ''))
        
        for idx, country in enumerate(sorted_countries, 1):
            name = country.get('name', {})
            common_name = name.get('common', '')
            official_name = name.get('official', '')
            
            # Basic codes
            cca2 = country.get('cca2', '')
            cca3 = country.get('cca3', '')
            ccn3 = country.get('ccn3', '')
            cioc = country.get('cioc', '')
            
            # Status
            independent = 1 if country.get('independent', False) else 0
            status = country.get('status', '')
            un_member = 1 if country.get('unMember', False) else 0
            un_regional_group = country.get('unRegionalGroup', '')
            
            # Geographic
            region = country.get('region', '')
            subregion = country.get('subregion', '')
            capital = self.format_array_to_string(country.get('capital', []))
            latlng = self.format_array_to_string(country.get('latlng', []))
            landlocked = 1 if country.get('landlocked', False) else 0
            borders = self.format_array_to_string(country.get('borders', []))
            area = country.get('area', 0) or 0
            
            # Get region and subregion IDs
            region_id = region_to_id.get(region) if region else None
            subregion_id = subregion_to_id.get(subregion) if subregion else None
            
            # Additional info
            tld = self.format_array_to_string(country.get('tld', []))
            currencies = json.dumps(country.get('currencies', {}), ensure_ascii=False)
            languages = json.dumps(country.get('languages', {}), ensure_ascii=False)
            alt_spellings = self.format_array_to_string(country.get('altSpellings', []))
            flag_emoji = country.get('flag', '')
            
            # Build INSERT statement
            sql_content += f"""INSERT INTO countries (
    country_id, common_name, official_name, cca2, cca3, ccn3, cioc,
    independent, status, un_member, un_regional_group,
    region_id, subregion_id, capital, latlng, landlocked, borders, area,
    tld, currencies, languages, alt_spellings, flag_emoji
) VALUES (
    {idx},
    {self.escape_sql_string(common_name)},
    {self.escape_sql_string(official_name)},
    {self.escape_sql_string(cca2) if cca2 else 'NULL'},
    {self.escape_sql_string(cca3) if cca3 else 'NULL'},
    {self.escape_sql_string(ccn3) if ccn3 else 'NULL'},
    {self.escape_sql_string(cioc) if cioc else 'NULL'},
    {independent},
    {self.escape_sql_string(status)},
    {un_member},
    {self.escape_sql_string(un_regional_group)},
    {region_id if region_id else 'NULL'},
    {subregion_id if subregion_id else 'NULL'},
    {self.escape_sql_string(capital) if capital else 'NULL'},
    {self.escape_sql_string(latlng) if latlng else 'NULL'},
    {landlocked},
    {self.escape_sql_string(borders) if borders else 'NULL'},
    {area},
    {self.escape_sql_string(tld) if tld else 'NULL'},
    {self.escape_sql_string(currencies) if currencies != '{}' else 'NULL'},
    {self.escape_sql_string(languages) if languages != '{}' else 'NULL'},
    {self.escape_sql_string(alt_spellings) if alt_spellings else 'NULL'},
    {self.escape_sql_string(flag_emoji) if flag_emoji else 'NULL'}
);

"""
        
        sql_content += "COMMIT;\n"
        
        # Write to file
        with open(os.path.join(self.output_dir, '04_insert_countries.sql'), 'w', encoding='utf-8') as f:
            f.write(sql_content)
        
        print(f"Countries INSERT script generated: 04_insert_countries.sql ({len(sorted_countries)} countries)")
    
    def generate_queries_examples(self):
        """Generate example queries for the database"""
        print("Generating example queries...")
        
        queries_sql = f"""-- Example queries for the Countries database
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

-- 1. Get all regions with count of countries
SELECT r.region_name, COUNT(c.country_id) as country_count
FROM regions r
LEFT JOIN countries c ON r.region_id = c.region_id
GROUP BY r.region_name
ORDER BY country_count DESC;

-- 2. Get all subregions with their regions and country counts
SELECT r.region_name, s.subregion_name, COUNT(c.country_id) as country_count
FROM regions r
JOIN subregions s ON r.region_id = s.region_id
LEFT JOIN countries c ON s.subregion_id = c.subregion_id
GROUP BY r.region_name, s.subregion_name
ORDER BY r.region_name, s.subregion_name;

-- 3. Get all independent countries in Europe
SELECT c.common_name, c.official_name, c.capital, c.area
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE r.region_name = 'Europe' AND c.independent = 1
ORDER BY c.common_name;

-- 4. Get largest countries by area
SELECT c.common_name, c.area, r.region_name, s.subregion_name
FROM countries c
JOIN regions r ON c.region_id = r.region_id
LEFT JOIN subregions s ON c.subregion_id = s.subregion_id
WHERE c.area > 0
ORDER BY c.area DESC
FETCH FIRST 10 ROWS ONLY;

-- 5. Get all UN member countries
SELECT c.common_name, c.official_name, r.region_name, c.un_regional_group
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE c.un_member = 1
ORDER BY r.region_name, c.common_name;

-- 6. Get landlocked countries
SELECT c.common_name, r.region_name, s.subregion_name, c.borders
FROM countries c
JOIN regions r ON c.region_id = r.region_id
LEFT JOIN subregions s ON c.subregion_id = s.subregion_id
WHERE c.landlocked = 1
ORDER BY r.region_name, c.common_name;

-- 7. Get countries with specific currency (Euro)
SELECT c.common_name, c.currencies
FROM countries c
WHERE c.currencies LIKE '%EUR%'
ORDER BY c.common_name;

-- 8. Get countries by language (English)
SELECT c.common_name, c.languages
FROM countries c
WHERE c.languages LIKE '%English%'
ORDER BY c.common_name;

-- 9. Get countries with multiple capitals
SELECT c.common_name, c.capital
FROM countries c
WHERE c.capital LIKE '%,%'
ORDER BY c.common_name;

-- 10. Get summary statistics
SELECT 
    (SELECT COUNT(*) FROM regions) as total_regions,
    (SELECT COUNT(*) FROM subregions) as total_subregions,
    (SELECT COUNT(*) FROM countries) as total_countries,
    (SELECT COUNT(*) FROM countries WHERE independent = 1) as independent_countries,
    (SELECT COUNT(*) FROM countries WHERE un_member = 1) as un_member_countries,
    (SELECT COUNT(*) FROM countries WHERE landlocked = 1) as landlocked_countries
FROM dual;
"""
        
        # Write to file
        with open(os.path.join(self.output_dir, '05_example_queries.sql'), 'w', encoding='utf-8') as f:
            f.write(queries_sql)
        
        print("Example queries generated: 05_example_queries.sql")
    
    def generate_master_script(self):
        """Generate a master script that runs all other scripts"""
        print("Generating master script...")
        
        master_sql = f"""-- Master script to execute all SQL files
-- Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
-- Execute this script to create and populate the entire database

PROMPT Creating tables...
@@01_create_tables.sql

PROMPT Inserting regions...
@@02_insert_regions.sql

PROMPT Inserting subregions...
@@03_insert_subregions.sql

PROMPT Inserting countries...
@@04_insert_countries.sql

PROMPT Setup complete!
PROMPT
PROMPT To run example queries, execute:
PROMPT @@05_example_queries.sql
PROMPT
PROMPT Database statistics:
SELECT 
    (SELECT COUNT(*) FROM regions) as total_regions,
    (SELECT COUNT(*) FROM subregions) as total_subregions,
    (SELECT COUNT(*) FROM countries) as total_countries,
    (SELECT COUNT(*) FROM countries WHERE independent = 1) as independent_countries,
    (SELECT COUNT(*) FROM countries WHERE un_member = 1) as un_member_countries
FROM dual;
"""
        
        # Write to file
        with open(os.path.join(self.output_dir, '00_master_script.sql'), 'w', encoding='utf-8') as f:
            f.write(master_sql)
        
        print("Master script generated: 00_master_script.sql")
    
    def generate_all(self):
        """Generate all SQL files"""
        print("Starting Oracle SQL generation...")
        print("=" * 50)
        
        # Load the data
        self.load_data()
        
        # Generate all SQL files
        self.generate_table_creation_scripts()
        self.generate_regions_insert()
        self.generate_subregions_insert()
        self.generate_countries_insert()
        self.generate_queries_examples()
        self.generate_master_script()
        
        print("=" * 50)
        print("Oracle SQL generation completed!")
        print(f"Generated files in '{self.output_dir}' directory:")
        print("  00_master_script.sql     - Master script to run all others")
        print("  01_create_tables.sql     - Table creation DDL")
        print("  02_insert_regions.sql    - Regions data")
        print("  03_insert_subregions.sql - Subregions data")
        print("  04_insert_countries.sql  - Countries data")
        print("  05_example_queries.sql   - Example queries")
        print("\nTo execute:")
        print("  1. Connect to Oracle database")
        print("  2. Run: @00_master_script.sql")


def main():
    """Main function"""
    import sys
    
    # Default values
    json_file = "countries.json"
    output_dir = "SQLs"
    
    # Check if JSON file exists
    if not os.path.exists(json_file):
        print(f"Error: {json_file} not found!")
        print("Please download the countries.json file from:")
        print("https://raw.githubusercontent.com/mledoze/countries/master/countries.json")
        sys.exit(1)
    
    # Create generator and run
    generator = OracleSQLGenerator(json_file, output_dir)
    generator.generate_all()


if __name__ == "__main__":
    main()
