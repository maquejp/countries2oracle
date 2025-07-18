# Countries to Oracle Database

A comprehensive collection of tools to generate Oracle SQL scripts for world countries data. This project provides multiple implementations in different programming languages to transform geographical data into normalized Oracle database structures.

## 🌍 Overview

This repository contains three different solutions for generating Oracle SQL scripts that populate databases with comprehensive world countries data, including regions, subregions, and detailed country information. Each solution uses different data sources and programming languages to achieve the same goal.

## 📊 Database Schema

All solutions generate a normalized Oracle database structure with three main tables:

### 🗺️ `regions` table
- World regions (continents): Africa, Americas, Antarctica, Asia, Europe, Oceania
- Primary key: `region_id`
- Unique region names

### 🌐 `subregions` table  
- Geographic subregions within each continent (20-24 subregions)
- Foreign key relationship to regions
- Primary key: `subregion_id`

### 🏛️ `countries` table
- Comprehensive data for 246-250 countries and territories
- Foreign key relationships to regions and subregions
- Includes: ISO codes, names, capitals, coordinates, area, population, currencies, languages, and more
- Primary key: `country_id`

## 🛠️ Solutions

### 1. Python Solution (`sol_mdeloze/`)
**Primary Solution** - Most comprehensive and feature-rich

- **Data Source**: [mledoze/countries](https://github.com/mledoze/countries) repository
- **Language**: Python 3
- **Features**:
  - Automated setup script with data download
  - Comprehensive country data including membership fields
  - Oracle-optimized SQL with proper indexing
  - Master script for sequential execution
  - Example queries for common use cases
  - 250 countries with extensive metadata

**Key Files**:
- `generate_oracle_sql.py` - Main generator script
- `setup.sh` - Automated setup and execution
- `add_membership_fields.py` - Enhanced version with membership data
- `requirements.txt` - Python dependencies

**Generated SQL Files**:
- `00_master_script.sql` - Master execution script
- `01_create_tables.sql` - DDL with tables, indexes, constraints
- `02_insert_regions.sql` - 6 world regions
- `03_insert_subregions.sql` - 24 subregions
- `04_insert_countries.sql` - 250 countries/territories
- `05_example_queries.sql` - Common queries and analysis

### 2. JavaScript/Node.js Solution (`sol_js_world_countries/`)
**Alternative Solution** - Clean and simple

- **Data Source**: [world-countries](https://github.com/mledoze/world-countries) npm package
- **Language**: Node.js/JavaScript
- **Features**:
  - NPM-based data source
  - Clean, readable code structure
  - Separate SQL files for each table
  - Oracle-specific data types and syntax
  - 246 countries with core data

**Key Files**:
- `index.js` - Main generator script
- `package.json` - Node.js dependencies
- `convert.js` - Data conversion utilities
- `test.js` - Test suite

**Generated SQL Files**:
- `01_create_tables.sql` - Table definitions
- `02_regions_data.sql` - 5 regions
- `03_subregions_data.sql` - 22 subregions
- `04_countries_data.sql` - 246 countries
- `run_all.sql` - Execution script

### 3. Ruby Solution (`sol_ruby/`)
**Ruby Implementation** - Using Countries gem

- **Data Source**: [Countries gem](https://github.com/countries/countries)
- **Language**: Ruby
- **Features**:
  - Official Countries gem integration
  - Oracle sequences and triggers
  - Single or separate file generation
  - Comprehensive country metadata
  - 246 countries with detailed information

**Key Files**:
- `generate_countries_sql.rb` - Main generator script
- `Gemfile` - Ruby dependencies
- `import.sh` - Import script

**Generated SQL Files**:
- `schema.sql` - Table definitions
- `regions.sql` - 5 regions
- `subregions.sql` - 22 subregions
- `countries.sql` - 246 countries

## 🚀 Quick Start

### Python Solution (Recommended)
```bash
cd sol_mdeloze
chmod +x setup.sh
./setup.sh
```

### JavaScript Solution
```bash
cd sol_js_world_countries
npm install
npm start
```

### Ruby Solution
```bash
cd sol_ruby
gem install countries
ruby generate_countries_sql.rb
```

## 📋 Prerequisites

### Python Solution
- Python 3.6+
- curl (for data download)
- Standard Python libraries only

### JavaScript Solution
- Node.js 12+
- npm

### Ruby Solution
- Ruby 2.5+
- Countries gem

## 🎯 Use Cases

- **Application Development**: Reference data for applications requiring geographical information
- **Data Analysis**: Geopolitical analysis and reporting
- **ETL Processes**: Data warehousing and business intelligence
- **Educational Projects**: Learning database design and normalization
- **API Development**: Backend data for geographical APIs

## 📈 Data Coverage

| Solution | Countries | Regions | Subregions | Data Source |
|----------|-----------|---------|------------|-------------|
| Python | 250 | 6 | 24 | mledoze/countries |
| JavaScript | 246 | 5 | 22 | world-countries npm |
| Ruby | 246 | 5 | 22 | Countries gem |

## 🔧 Advanced Features

### Python Solution Features
- **Membership Fields**: UN, EU, NATO, Commonwealth, and other organization memberships
- **Comprehensive Metadata**: Currencies, languages, timezones, calling codes
- **Performance Optimization**: Proper indexing and query optimization
- **Data Validation**: Automatic data cleaning and validation
- **Incremental Updates**: Support for data updates and migrations

### All Solutions Include
- **Oracle Compatibility**: Proper Oracle SQL syntax and data types
- **Foreign Key Relationships**: Normalized database design
- **Data Integrity**: Constraints and validations
- **Documentation**: Comprehensive comments and documentation
- **Example Queries**: Common use case examples

## 📝 SQL File Organization

Each solution generates organized SQL files:

1. **Schema/DDL Files**: Table creation with constraints and indexes
2. **Data Files**: INSERT statements for each table
3. **Master Scripts**: Sequential execution scripts
4. **Example Queries**: Common queries and analysis examples

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- Additional data sources and validation
- Performance optimizations
- New programming language implementations
- Enhanced documentation
- Bug fixes and improvements

## 📄 License

This project is open source. Data sources have their own licenses:
- [mledoze/countries](https://github.com/mledoze/countries) - Open Database License
- [world-countries](https://github.com/mledoze/world-countries) - Open Database License  
- [Countries gem](https://github.com/countries/countries) - MIT License

## 🙏 Acknowledgments

- **Data Sources**: 
  - [mledoze/countries](https://github.com/mledoze/countries) - Comprehensive countries data
  - [world-countries](https://github.com/mledoze/world-countries) - NPM package
  - [Countries gem](https://github.com/countries/countries) - Ruby gem
- **Contributors**: All developers who have contributed to this project
- **Community**: Open source geographical data community

## 📞 Support

For questions, issues, or contributions:
- Create an issue in the repository
- Review existing documentation
- Check the example queries for common use cases

---

**Choose the solution that best fits your technology stack and requirements. The Python solution is recommended for most use cases due to its comprehensive feature set and automated setup.**
