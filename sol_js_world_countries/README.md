# Countries SQL Generator for Oracle

This project generates Oracle SQL insert statements for countries, regions, and subregions using data from the [`world-countries`](https://github.com/mledoze/world-countries) package.

## Features

- **Three separate tables**: `regions`, `subregions`, and `countries`
- **Foreign key relationships**: Subregions link to regions, countries link to both regions and subregions
- **Comprehensive data**: Includes country codes (ISO 3166-1 alpha-2, alpha-3, numeric), names, capitals, areas, flags, coordinates, and more
- **Oracle-optimized**: Uses Oracle-specific data types and syntax (without sequences/triggers)
- **Clean SQL output**: Properly escaped strings and formatted SQL
- **Organized structure**: All SQL files are generated in the `SQLs` folder

## Oracle Database Schema

### Regions Table
- `id` NUMBER(10) PRIMARY KEY
- `name` VARCHAR2(100) NOT NULL UNIQUE
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Subregions Table
- `id` NUMBER(10) PRIMARY KEY
- `name` VARCHAR2(100) NOT NULL UNIQUE
- `region_id` NUMBER(10) - Foreign Key to regions.id
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Countries Table
- `id` NUMBER(10) PRIMARY KEY
- `cca2` VARCHAR2(2) NOT NULL UNIQUE - ISO 3166-1 alpha-2 code
- `cca3` VARCHAR2(3) NOT NULL UNIQUE - ISO 3166-1 alpha-3 code
- `ccn3` VARCHAR2(3) - ISO 3166-1 numeric code
- `name` VARCHAR2(100) NOT NULL - Common name
- `official_name` VARCHAR2(200) - Official name
- `region` VARCHAR2(50) - Region name (denormalized)
- `subregion` VARCHAR2(100) - Subregion name (denormalized)
- `region_id` NUMBER(10) - Foreign Key to regions.id
- `subregion_id` NUMBER(10) - Foreign Key to subregions.id
- `capital` VARCHAR2(100) - Capital city
- `area` NUMBER(15,2) - Area in square kilometers
- `population` NUMBER(19) - Population count
- `independent` NUMBER(1) CHECK (independent IN (0, 1)) - Independence status
- `un_member` NUMBER(1) CHECK (un_member IN (0, 1)) - UN membership status
- `flag` VARCHAR2(10) - Flag emoji
- `latitude` NUMBER(10,8) - Latitude coordinate
- `longitude` NUMBER(11,8) - Longitude coordinate
- `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

## Data Overview

The generated SQL includes:

- **6 Regions**: Americas, Asia, Africa, Europe, Oceania, Antarctic
- **24 Subregions**: Caribbean, Southern Asia, Middle Africa, Northern Europe, etc.
- **250 Countries**: All countries and territories from the world-countries dataset

### Regions and Country Counts

- **Americas**: 56 countries
- **Asia**: 50 countries  
- **Africa**: 59 countries
- **Europe**: 53 countries
- **Oceania**: 27 countries
- **Antarctic**: 5 countries

## Installation

1. Clone or download this project
2. Install dependencies:
   ```bash
   npm install
   ```

## Usage

### Generate Oracle SQL Files

Run the generator:
```bash
npm start
```

This will create separate files in the `SQLs` folder:
- `01_create_tables.sql` - Oracle table creation statements
- `02_regions_data.sql` - INSERT statements for regions (6 records)
- `03_subregions_data.sql` - INSERT statements for subregions (24 records)
- `04_countries_data.sql` - INSERT statements for countries (250 records)
- `countries_data_oracle.sql` - Complete SQL file with all statements
- `countries_summary.json` - Summary of the data structure
- `migration.sql` - Oracle-specific migration script with setup instructions
- `run_all.sql` - SQL*Plus script to execute all files in order with progress messages

### Separate File Benefits

- **Modular execution**: Run only the parts you need
- **Easier debugging**: Isolate issues to specific data sets
- **Selective updates**: Update only countries without recreating tables
- **Better organization**: Clear separation of structure and data
- **Deployment flexibility**: Choose complete file or step-by-step execution

### Execution Options

**Option 1: Run separate files in order**
```sql
@01_create_tables.sql
@02_regions_data.sql
@03_subregions_data.sql
@04_countries_data.sql
```

**Option 2: Use the automated script**
```sql
@run_all.sql
```

**Option 3: Run complete file**
```sql
@countries_data_oracle.sql
```

### Oracle Features

- **No sequences or triggers**: Uses manual ID assignment for all tables
- **Named constraints**: Uses `CONSTRAINT fk_name FOREIGN KEY` syntax
- **Check constraints**: Boolean fields use `NUMBER(1)` with `CHECK (field IN (0, 1))`
- **Oracle data types**: Uses `NUMBER()`, `VARCHAR2()`, and `TIMESTAMP`
- **Proper escaping**: All string values are properly escaped for Oracle SQL

### Run Tests

Validate the generated SQL:
```bash
npm test
```

### Use the Generated SQL

1. **MySQL/MariaDB**: Run the SQL file directly
   ```sql
   SOURCE countries_data.sql;
   ```

2. **PostgreSQL**: You might need to adjust the AUTO_INCREMENT to SERIAL and BOOLEAN values

3. **SQLite**: Remove the FOREIGN KEY constraints or enable them with PRAGMA

## Example Queries

After importing the data, you can run queries like:

```sql
-- Get all countries in Europe
SELECT name, capital FROM countries WHERE region = 'Europe';

-- Get countries by subregion with region info
SELECT c.name, c.capital, s.name as subregion, r.name as region
FROM countries c
JOIN subregions s ON c.subregion_id = s.id
JOIN regions r ON s.region_id = r.id
WHERE r.name = 'Asia';

-- Count countries by region
SELECT r.name, COUNT(c.id) as country_count
FROM regions r
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name;
```

## Files Generated

- `countries_data.sql` - Main SQL file with all CREATE TABLE and INSERT statements (MySQL/MariaDB)
- `countries_data_postgresql.sql` - PostgreSQL-compatible version
- `countries_data_sqlite.sql` - SQLite-compatible version
- `countries_data_sqlserver.sql` - SQL Server-compatible version
- `countries_summary.json` - JSON summary with statistics and data structure overview
- `migration.sql` - Step-by-step migration guide
- `sample_queries.sql` - Example queries demonstrating database usage

## Dependencies

- `world-countries` (^5.1.0) - Source data for countries, regions, and subregions

## Data Source

This project uses the [`world-countries`](https://github.com/mledoze/world-countries) package, which provides:
- ISO 3166-1 country codes and names
- Regional classifications following UN geoscheme
- Country metadata including capitals, areas, coordinates
- Up-to-date and well-maintained country data

## License

MIT License - Feel free to use this for any purpose.
