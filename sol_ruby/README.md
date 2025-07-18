# Ruby Countries SQL Generator

This Ruby project generates SQL insert statements for countries, regions, and subregions using the [Countries gem](https://github.com/countries/countries).

## Features

- **Complete database schema**: Creates tables for regions, subregions, and countries with proper foreign key relationships
- **Comprehensive country data**: Includes ISO codes, names, capitals, areas, populations, coordinates, and more
- **Ruby Countries gem**: Uses the official Countries gem for accurate and up-to-date country data
- **Clean SQL output**: Properly escaped strings and formatted SQL statements

## Installation

1. Install the Countries gem:
   ```bash
   gem install countries
   ```

2. Run the generator:
   ```bash
   # Generate single combined SQL file
   ruby generate_countries_sql.rb > countries_data_ruby.sql
   
   # OR generate separate files for each table
   ruby generate_countries_sql.rb --separate
   ```

## Generated Files

### Single File Mode
- **countries_data_ruby.sql** - Combined SQL with all tables and data

### Separate Files Mode (`--separate` flag)
- **SQLs/schema.sql** - Table definitions only
- **SQLs/regions.sql** - 5 regions data
- **SQLs/subregions.sql** - 22 subregions data  
- **SQLs/countries.sql** - 246 countries data

## Database Schema

### Regions Table
- `id` (Primary Key, Auto-increment)
- `name` (VARCHAR(100), UNIQUE)
- `created_at` (TIMESTAMP)

### Subregions Table
- `id` (Primary Key, Auto-increment)
- `name` (VARCHAR(100), UNIQUE)
- `region_id` (Foreign Key to regions.id)
- `created_at` (TIMESTAMP)

### Countries Table
- `id` (Primary Key, Auto-increment)
- `cca2` (VARCHAR(2), UNIQUE) - ISO 3166-1 alpha-2 code
- `cca3` (VARCHAR(3), UNIQUE) - ISO 3166-1 alpha-3 code
- `ccn3` (VARCHAR(3)) - ISO 3166-1 numeric code
- `name` (VARCHAR(100)) - Common name
- `official_name` (VARCHAR(200)) - Official name
- `region` (VARCHAR(50)) - Region name (denormalized)
- `subregion` (VARCHAR(100)) - Subregion name (denormalized)
- `region_id` (Foreign Key to regions.id)
- `subregion_id` (Foreign Key to subregions.id)
- `capital` (VARCHAR(100)) - Capital city
- `area` (DECIMAL(15,2)) - Area in square kilometers
- `population` (BIGINT) - Population count
- `independent` (BOOLEAN) - Independence status
- `un_member` (BOOLEAN) - UN membership status
- `flag` (VARCHAR(10)) - Flag emoji
- `latitude` (DECIMAL(10,8)) - Latitude coordinate
- `longitude` (DECIMAL(11,8)) - Longitude coordinate
- `created_at` (TIMESTAMP)

## Usage

### Single File Import
```bash
# Generate combined SQL file
ruby generate_countries_sql.rb > countries_data_ruby.sql

# Import into MySQL
mysql -u username -p database_name < countries_data_ruby.sql

# Import into PostgreSQL
psql -U username -d database_name -f countries_data_ruby.sql
```

### Separate Files Import
```bash
# Generate separate SQL files
ruby generate_countries_sql.rb --separate

# Manual import (maintain order for foreign keys)
mysql -u username -p database_name < SQLs/schema.sql
mysql -u username -p database_name < SQLs/regions.sql
mysql -u username -p database_name < SQLs/subregions.sql
mysql -u username -p database_name < SQLs/countries.sql

# OR use the automated import script
./import.sh database_name username
```

## Data Source

This project uses the [Countries gem](https://github.com/countries/countries) which provides:
- ISO 3166-1 country codes and names
- Geographic data (regions, subregions, coordinates)
- Administrative data (capitals, areas, populations)
- Political data (independence status, UN membership)
- Cultural data (flag emojis, languages)

## Output

The generated SQL file contains:
- Table creation statements
- Insert statements for regions (6 regions)
- Insert statements for subregions (22 subregions)
- Insert statements for countries (249 countries and territories)

## Example

```bash
# Generate SQL file
ruby generate_countries_sql.rb > countries_data_ruby.sql

# Import into MySQL
mysql -u username -p database_name < countries_data_ruby.sql

# Import into PostgreSQL
psql -U username -d database_name -f countries_data_ruby.sql
```
