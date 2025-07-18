# Oracle SQL Generator for Countries Data

This project generates Oracle SQL files for inserting world countries data into an Oracle database, based on the [mledoze/countries](https://github.com/mledoze/countries) repository.

## Overview

The script processes the `countries.json` file and creates a normalized database structure with three main tables:
- **regions** - World regions (continents)
- **subregions** - Subregions within each continent
- **countries** - Individual countries and territories

## Features

- **Normalized Database Design**: Proper foreign key relationships between regions, subregions, and countries
- **Comprehensive Data**: Includes all data from the mledoze/countries dataset
- **Oracle-Specific**: Uses Oracle SQL syntax and features
- **Multiple Files**: Data is split into separate SQL files for better organization
- **Example Queries**: Includes common queries for data analysis

## Files Generated

The script creates the following SQL files in the `SQLs` directory:

1. **`00_master_script.sql`** - Master script that executes all other scripts
2. **`01_create_tables.sql`** - DDL statements to create tables, indexes, and constraints
3. **`02_insert_regions.sql`** - INSERT statements for regions (6 regions)
4. **`03_insert_subregions.sql`** - INSERT statements for subregions (24 subregions)
5. **`04_insert_countries.sql`** - INSERT statements for countries (250 countries)
6. **`05_example_queries.sql`** - Example queries for data analysis

## Database Schema

### regions table
- `region_id` (NUMBER, Primary Key)
- `region_name` (VARCHAR2(100), UNIQUE)
- `created_date` (DATE)

### subregions table
- `subregion_id` (NUMBER, Primary Key)
- `subregion_name` (VARCHAR2(100))
- `region_id` (NUMBER, Foreign Key to regions)
- `created_date` (DATE)

### countries table
- `country_id` (NUMBER, Primary Key)
- Basic information: `common_name`, `official_name`, `cca2`, `cca3`, `ccn3`, `cioc`
- Status: `independent`, `status`, `un_member`, `un_regional_group`
- Geography: `region_id`, `subregion_id`, `capital`, `latlng`, `landlocked`, `borders`, `area`
- Additional: `tld`, `currencies`, `languages`, `alt_spellings`, `flag_emoji`
- Metadata: `created_date`

## Usage

### Prerequisites
- Python 3.6+
- Oracle Database (any version supporting basic SQL features)

### Steps

1. **Download the countries data:**
   ```bash
   curl -o countries.json https://raw.githubusercontent.com/mledoze/countries/master/countries.json
   ```

2. **Run the generator:**
   ```bash
   python generate_oracle_sql.py
   ```

3. **Execute in Oracle:**
   ```sql
   @00_master_script.sql
   ```

## Example Queries

The generated `05_example_queries.sql` file includes queries for:
- Counting countries by region
- Finding independent countries
- Listing largest countries by area
- Finding UN member countries
- Identifying landlocked countries
- Searching by currency or language
- Database statistics

## Data Sources

- **Primary Data**: [mledoze/countries](https://github.com/mledoze/countries)
- **Standards**: Based on ISO 3166-1 for country codes
- **Regions**: Follows UN regional classifications

## Notes

- The script handles Unicode characters properly (country names, currencies, etc.)
- SQL strings are properly escaped to prevent injection
- Uses explicit ID values for all primary keys (no sequences or identity columns)
- Foreign key relationships ensure data integrity
- Indexes are created for optimal query performance
- All data is committed as transactions

## License

This project is based on the [mledoze/countries](https://github.com/mledoze/countries) dataset, which is licensed under the Open Database License (ODbL).

## Output Statistics

- **Regions**: 6 (Africa, Americas, Antarctic, Asia, Europe, Oceania)
- **Subregions**: 24 (e.g., Western Europe, Eastern Africa, Southeast Asia)
- **Countries**: 250 (includes sovereign states and territories)
- **Independent Countries**: ~195 sovereign states
- **UN Members**: ~193 countries
