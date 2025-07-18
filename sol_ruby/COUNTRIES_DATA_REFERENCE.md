# Countries Gem Data Reference

This document provides a comprehensive reference for all available data fields in the Ruby Countries gem (ISO3166).

## Overview

The Countries gem provides access to country data through two main interfaces:
1. **Direct methods** on the Country object
2. **Data hash** containing raw country information

## Direct Country Object Methods

### Basic Identifiers
- `alpha2` - ISO 3166-1 alpha-2 country code (e.g., "US", "DE")
- `alpha3` - ISO 3166-1 alpha-3 country code (e.g., "USA", "DEU")
- `number` - ISO 3166-1 numeric country code (e.g., "840", "276")
- `gec` - Government and Economics Committee code
- `ioc` - International Olympic Committee code

### Names
- `iso_short_name` - Official short name (e.g., "Germany")
- `iso_long_name` - Official long name (e.g., "The Federal Republic of Germany")
- `common_name` - Common name used in everyday language
- `local_name` - Local name in the country's language
- `local_names` - Array of local names
- `nationality` - Nationality adjective (e.g., "German", "American")
- `unofficial_names` - Array of unofficial/alternative names
- `translated_names` - Array of translated names
- `translation(locale)` - Get translation for specific locale

### Geographic Information
- `continent` - Continent name (e.g., "Europe", "North America")
- `region` - UN region (e.g., "Europe", "Americas")
- `subregion` - UN subregion (e.g., "Western Europe", "Northern America")
- `world_region` - World region code (e.g., "EMEA", "AMER")
- `latitude` - Country center latitude
- `longitude` - Country center longitude
- `min_latitude` - Minimum latitude (southern bound)
- `max_latitude` - Maximum latitude (northern bound)
- `min_longitude` - Minimum longitude (western bound)
- `max_longitude` - Maximum longitude (eastern bound)
- `bounds` - Geographic bounds object
- `geo` - Complete geographic information hash

### Political/Economic Membership
- `in_eu?` - European Union member (boolean method)
- `in_eea?` - European Economic Area member (boolean method)
- `in_esm?` - European Stability Mechanism member (boolean method)
- `in_eu_vat?` - EU VAT area member (boolean method)
- `in_g7?` - G7 member (boolean method)
- `in_g20?` - G20 member (boolean method)
- `gdpr_compliant?` - GDPR compliance (boolean method)

### Communication & Postal
- `country_code` - International dialing code
- `international_prefix` - International dialing prefix
- `national_prefix` - National dialing prefix
- `nanp_prefix` - North American Numbering Plan prefix
- `national_destination_code_lengths` - Array of valid area code lengths
- `national_number_lengths` - Array of valid phone number lengths
- `postal_code` - Postal code system exists (boolean)
- `postal_code?` - Postal code system exists (boolean method)
- `postal_code_format` - Regular expression for postal code format
- `zip` - Alias for postal_code
- `zip?` - Alias for postal_code?
- `zip_format` - Alias for postal_code_format
- `address_format` - Address format template

### Language & Culture
- `languages` - Array of all languages
- `languages_official` - Array of official languages
- `languages_spoken` - Array of spoken languages
- `start_of_week` - First day of week (e.g., "monday", "sunday")
- `distance_unit` - Distance measurement unit ("KM" or "MI")
- `currency_code` - ISO currency code (e.g., "EUR", "USD")

### Administrative Divisions
- `states` - Array of states/provinces
- `subdivisions` - Array of administrative subdivisions
- `subdivisions?` - Has subdivisions (boolean method)
- `subdivision_types` - Array of subdivision types
- `subdivision_names` - Array of subdivision names
- `subdivision_names_with_codes` - Hash of subdivision names with codes
- `subdivisions_of_types(types)` - Get subdivisions of specific types
- `find_subdivision_by_name(name)` - Find subdivision by name
- `subdivision_for_string?(string)` - Check if string matches subdivision
- `humanized_subdivision_types` - Human-readable subdivision types

### Other
- `emoji_flag` - Country flag emoji
- `timezones` - Array of timezone identifiers
- `un_locode` - UN Location Code
- `vat_rates` - VAT/Tax rates information

## Data Hash Fields

The `data` hash contains raw country information with the following keys:

### Basic Information
- `alpha2` - ISO 3166-1 alpha-2 code
- `alpha3` - ISO 3166-1 alpha-3 code
- `number` - ISO 3166-1 numeric code
- `gec` - Government and Economics Committee code
- `ioc` - International Olympic Committee code
- `iso_short_name` - Official short name
- `iso_long_name` - Official long name
- `nationality` - Nationality adjective
- `unofficial_names` - Array of unofficial names
- `translated_names` - Array of translated names

### Geographic Data
- `continent` - Continent name
- `region` - UN region
- `subregion` - UN subregion
- `world_region` - World region code
- `geo` - Geographic information hash (see structure below)

### Political/Economic Membership
- `eea_member` - European Economic Area member (boolean)
- `esm_member` - European Stability Mechanism member (boolean)
- `eu_member` - European Union member (boolean)
- `euvat_member` - EU VAT area member (boolean)
- `g7_member` - G7 member (boolean)
- `g20_member` - G20 member (boolean)

### Communication & Postal
- `country_code` - International dialing code
- `international_prefix` - International dialing prefix
- `national_prefix` - National dialing prefix
- `nanp_prefix` - North American Numbering Plan prefix
- `national_destination_code_lengths` - Array of area code lengths
- `national_number_lengths` - Array of phone number lengths
- `postal_code` - Postal code system exists (boolean)
- `postal_code_format` - Postal code regex pattern
- `address_format` - Address format template

### Language & Culture
- `languages_official` - Array of official language codes
- `languages_spoken` - Array of spoken language codes
- `start_of_week` - First day of week
- `distance_unit` - Distance measurement unit
- `currency_code` - ISO currency code
- `alt_currency` - Alternative currency code (rare)

### Tax Information
- `vat_rates` - VAT/Tax rates hash (see structure below)

### Other
- `un_locode` - UN Location Code
- `translations` - Hash of translations by locale

## Complex Data Structures

### Geographic Information (`geo`)
```ruby
{
  "latitude": 51.165691,           # Country center latitude
  "longitude": 10.451526,          # Country center longitude
  "max_latitude": 55.0815,         # Northern boundary
  "max_longitude": 15.0418962,     # Eastern boundary
  "min_latitude": 47.2701115,      # Southern boundary
  "min_longitude": 5.8663425,      # Western boundary
  "bounds": {
    "northeast": {
      "lat": 55.0815,
      "lng": 15.0418962
    },
    "southwest": {
      "lat": 47.2701115,
      "lng": 5.8663425
    }
  }
}
```

### VAT Rates (`vat_rates`)
```ruby
{
  "standard": 19,                  # Standard VAT rate percentage
  "reduced": [7],                  # Array of reduced VAT rates
  "super_reduced": null,           # Super reduced rate (if exists)
  "parking": null                  # Parking rate (if exists)
}
```

### Translations (`translations`)
```ruby
{
  "en": "Germany",                 # English translation
  "de": "Deutschland",             # German translation
  "fr": "Allemagne"                # French translation
  # ... other language codes
}
```

## Usage Examples

```ruby
require 'countries'

# Get a country
country = ISO3166::Country.find_country_by_alpha2('DE')

# Basic information
puts country.iso_short_name         # "Germany"
puts country.alpha3                 # "DEU"
puts country.currency_code          # "EUR"

# Geographic data
puts country.latitude               # 51.165691
puts country.continent              # "Europe"
puts country.region                 # "Europe"
puts country.subregion              # "Western Europe"

# Membership information
puts country.in_eu?                 # true
puts country.in_eea?                # true
puts country.data['eu_member']      # true
puts country.data['eea_member']     # true

# Complex data
puts country.geo.keys              # ["latitude", "longitude", "max_latitude", ...]
puts country.vat_rates             # {"standard"=>19, "reduced"=>[7], ...}
puts country.languages_official    # ["de"]

# Subdivisions
puts country.states.first.name     # "Baden-Württemberg"
puts country.subdivision_types      # ["state"]
```

## Data Availability Notes

- **EU/EEA Membership**: Only available for European countries
- **VAT Rates**: Available for EU countries and some others
- **Subdivisions**: Available for most countries but structure varies
- **Geographic bounds**: Available for all countries
- **Phone number formats**: Available for most countries
- **Postal codes**: Not all countries have postal code systems
- **Alternative currencies**: Rare, only some countries have this field

## Related Resources

- [ISO3166 gem on GitHub](https://github.com/countries/countries)
- [ISO 3166-1 Standard](https://en.wikipedia.org/wiki/ISO_3166-1)
- [UN Region Codes](https://unstats.un.org/unsd/methodology/m49/)
