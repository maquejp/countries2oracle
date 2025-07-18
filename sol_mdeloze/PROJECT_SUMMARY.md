# Project File Summary

## Overview
This project generates Oracle SQL files for creating and populating a countries database based on the [mledoze/countries](https://github.com/mledoze/countries) repository.

## Project Structure

### Main Files
- **`generate_oracle_sql.py`** - Main Python script that processes countries.json and generates SQL files
- **`setup.sh`** - Automated setup script that downloads data and runs the generator
- **`countries.json`** - Source data file (downloaded from GitHub)
- **`README.md`** - Comprehensive project documentation
- **`requirements.txt`** - Python dependencies (standard library only)

### Generated SQL Files (in SQLs/ directory)
- **`00_master_script.sql`** - Master script that executes all other SQL files in order
- **`01_create_tables.sql`** - DDL statements for creating tables, indexes, and constraints
- **`02_insert_regions.sql`** - INSERT statements for the 6 world regions
- **`03_insert_subregions.sql`** - INSERT statements for the 24 subregions
- **`04_insert_countries.sql`** - INSERT statements for all 250 countries/territories
- **`05_example_queries.sql`** - Common queries for data analysis and reporting

## Database Schema

The generated database has a normalized structure with three main tables:

### 1. regions
- Stores the 6 world regions (Africa, Americas, Antarctic, Asia, Europe, Oceania)
- Primary key: `region_id`

### 2. subregions
- Stores 24 subregions within each continent
- Foreign key relationship to regions table
- Primary key: `subregion_id`

### 3. countries
- Stores all 250 countries and territories
- Foreign key relationships to both regions and subregions tables
- Includes comprehensive data: names, codes, status, geography, currencies, languages, etc.
- Primary key: `country_id`

## Key Features

1. **Oracle-Specific**: Uses Oracle SQL syntax and features like identity columns
2. **Normalized Design**: Proper foreign key relationships prevent data duplication
3. **Comprehensive Data**: Includes all available data from the source
4. **Performance Optimized**: Includes indexes on commonly queried columns
5. **Well Documented**: Comments on tables and columns explain their purpose
6. **Example Queries**: Includes practical queries for common use cases

## Usage

### Quick Start
```bash
./setup.sh
```

### Manual Steps
1. Download data: `curl -o countries.json https://raw.githubusercontent.com/mledoze/countries/master/countries.json`
2. Generate SQL: `python3 generate_oracle_sql.py`
3. Execute in Oracle: `@00_master_script.sql`

## Data Statistics
- **Regions**: 6
- **Subregions**: 24
- **Countries/Territories**: 250
- **Independent Countries**: ~195
- **UN Member Countries**: ~193

## Technology Stack
- **Language**: Python 3.6+
- **Database**: Oracle 12c+ (for identity columns)
- **Dependencies**: Python standard library only

## Data Source
Based on the excellent [mledoze/countries](https://github.com/mledoze/countries) repository, which provides world countries data in JSON format following ISO 3166-1 standards.
