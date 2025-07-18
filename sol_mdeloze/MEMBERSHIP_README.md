# Countries Data with Membership Fields

This directory contains scripts to work with countries data that includes EU, EFTA, and EEA membership information.

## Files

- `data/countries.json` - Original countries data from [mledoze/countries](https://github.com/mledoze/countries)
- `data/countries_original.json` - Backup of the original file
- `data/countries_amended.json` - Countries data with added membership fields
- `add_membership_fields.py` - Script to add membership fields to countries data
- `generate_oracle_sql.py` - Script to generate Oracle SQL from countries data
- `SQLs/` - Directory containing generated SQL files

## Membership Fields Added

- `euMember` - Boolean indicating EU membership (27 countries)
- `eftaMember` - Boolean indicating EFTA membership (4 countries: Iceland, Liechtenstein, Norway, Switzerland)
- `eeaMember` - Boolean indicating EEA membership (30 countries: EU + EFTA except Switzerland)

## Usage

1. **Add membership fields to countries data:**
   ```bash
   python3 add_membership_fields.py
   ```
   This creates `countries_amended.json` while preserving the original file.

2. **Generate Oracle SQL:**
   ```bash
   python3 generate_oracle_sql.py
   ```
   This automatically uses `countries_amended.json` if available, otherwise falls back to `countries.json`.

3. **Use specific input file:**
   ```bash
   python3 generate_oracle_sql.py data/countries.json
   python3 generate_oracle_sql.py data/countries_amended.json
   ```

## Database Schema

The generated SQL includes tables for:
- `regions` - World regions/continents
- `subregions` - Subregions within continents
- `countries` - Countries with all fields including membership data

## Example Queries

The generated SQL includes example queries for:
- Listing all EU member countries
- Listing all EFTA member countries
- Listing all EEA member countries
- Finding countries with multiple memberships
- Finding European countries that are not EU members

## Membership Statistics

- **EU Members**: 27 countries
- **EFTA Members**: 4 countries (Iceland, Liechtenstein, Norway, Switzerland)
- **EEA Members**: 30 countries (EU + Iceland, Liechtenstein, Norway)

Note: Switzerland is an EFTA member but not an EEA member.
