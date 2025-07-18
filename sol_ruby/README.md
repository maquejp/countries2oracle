# Ruby Countries SQL Generator - Oracle Edition

This Ruby project generates **Oracle-compatible** SQL insert statements for countries, regions, and subregions using the [Countries gem](https://github.com/countries/countries).

## Features

- **Complete Oracle database schema**: Creates tables for regions, subregions, and countries with proper foreign key relationships
- **Oracle-specific syntax**: Uses NUMBER, VARCHAR2, sequences, and triggers for auto-increment functionality
- **Comprehensive country data**: Includes ISO codes, names, capitals, areas, populations, coordinates, and more
- **Ruby Countries gem**: Uses the official Countries gem for accurate and up-to-date country data
- **Oracle-compatible SQL**: Properly formatted for Oracle Database with COMMIT statements

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
- `id` (NUMBER, Primary Key with sequence)
- `name` (VARCHAR2(100), UNIQUE)
- `created_at` (TIMESTAMP)

### Subregions Table
- `id` (NUMBER, Primary Key with sequence)
- `name` (VARCHAR2(100), UNIQUE)
- `region_id` (NUMBER, Foreign Key to regions.id)
- `created_at` (TIMESTAMP)

### Countries Table
- `id` (NUMBER, Primary Key with sequence)
- `cca2` (VARCHAR2(2), UNIQUE) - ISO 3166-1 alpha-2 code
- `cca3` (VARCHAR2(3), UNIQUE) - ISO 3166-1 alpha-3 code
- `ccn3` (VARCHAR2(3)) - ISO 3166-1 numeric code
- `name` (VARCHAR2(100)) - Common name
- `official_name` (VARCHAR2(200)) - Official name
- `region` (VARCHAR2(50)) - Region name (denormalized)
- `subregion` (VARCHAR2(100)) - Subregion name (denormalized)
- `region_id` (NUMBER, Foreign Key to regions.id)
- `subregion_id` (NUMBER, Foreign Key to subregions.id)
- `capital` (VARCHAR2(100)) - Capital city
- `area` (NUMBER(15,2)) - Area in square kilometers
- `population` (NUMBER(15)) - Population count
- `independent` (NUMBER(1)) - Independence status (1=true, 0=false)
- `un_member` (NUMBER(1)) - UN membership status (1=true, 0=false)
- `flag` (VARCHAR2(10)) - Flag emoji
- `latitude` (NUMBER(10,8)) - Latitude coordinate
- `longitude` (NUMBER(11,8)) - Longitude coordinate
- `created_at` (TIMESTAMP)

### Oracle-Specific Features
- **Sequences**: Auto-increment functionality using Oracle sequences
- **Triggers**: Automatic ID assignment on INSERT
- **Constraints**: Named foreign key constraints for better management

## Usage

### Single File Import
```bash
# Generate combined SQL file
ruby generate_countries_sql.rb > countries_data_ruby.sql

# Import into Oracle
sqlplus username/password@database @countries_data_ruby.sql
```

### Separate Files Import
```bash
# Generate separate SQL files
ruby generate_countries_sql.rb --separate

# Manual import (maintain order for foreign keys)
sqlplus username/password@database @SQLs/schema.sql
sqlplus username/password@database @SQLs/regions.sql
sqlplus username/password@database @SQLs/subregions.sql
sqlplus username/password@database @SQLs/countries.sql

# OR use the automated import script
export PASSWORD=your_password
./import.sh username database_connection_string
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
