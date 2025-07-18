# Countries SQL Generator

This project generates SQL insert statements for countries, regions, and subregions using data from the [`world-countries`](https://github.com/mledoze/world-countries) package.

## Features

- **Three separate tables**: `regions`, `subregions`, and `countries`
- **Foreign key relationships**: Subregions link to regions, countries link to both regions and subregions
- **Comprehensive data**: Includes country codes (ISO 3166-1 alpha-2, alpha-3, numeric), names, capitals, areas, flags, coordinates, and more
- **Clean SQL output**: Properly escaped strings and formatted SQL

## Database Schema

### Regions Table
- `id` (Primary Key)
- `name` (VARCHAR(100), UNIQUE)
- `created_at` (TIMESTAMP)

### Subregions Table
- `id` (Primary Key)
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

### Generate SQL Files

Run the generator:
```bash
npm start
```

This will create two files:
- `countries_data.sql` - Complete SQL with CREATE TABLE and INSERT statements (MySQL/MariaDB format)
- `countries_summary.json` - Summary of the data structure

### Generate Database-Specific Files

To generate SQL files for different database systems:
```bash
npm run convert
```

This will create:
- `countries_data_postgresql.sql` - PostgreSQL format
- `countries_data_sqlite.sql` - SQLite format  
- `countries_data_sqlserver.sql` - SQL Server format
- `migration.sql` - Migration script with setup instructions

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
