# Product Requirements Document (PRD)
## Oracle SQL Generator for Countries Data

### Document Information
- **Product Name**: Oracle SQL Generator for Countries Data
- **Version**: 1.0
- **Date**: July 18, 2025
- **Author**: Development Team
- **Status**: Active Development

---

## 1. Executive Summary

The Oracle SQL Generator for Countries Data is a Python-based tool that transforms the comprehensive countries dataset from the mledoze/countries repository into a normalized Oracle database structure. This tool addresses the need for developers and analysts to have reliable, structured geographical data in Oracle databases for applications requiring country, region, and subregion information.

### 1.1 Problem Statement
- Developers need structured geographical data in Oracle databases
- Manual data entry for countries and regions is time-consuming and error-prone
- Existing data sources are often denormalized or not optimized for Oracle
- Need for automated, repeatable process to populate geographical reference data

### 1.2 Solution Overview
A Python script that automatically generates Oracle SQL files from the mledoze/countries JSON dataset, creating a normalized database structure with proper relationships, indexes, and example queries.

---

## 2. Product Goals and Objectives

### 2.1 Primary Goals
1. **Automation**: Eliminate manual data entry for geographical reference data
2. **Data Quality**: Ensure accurate, up-to-date country information
3. **Database Optimization**: Create properly normalized, indexed database structure
4. **Developer Experience**: Provide easy-to-use, well-documented solution

### 2.2 Success Metrics
- **Data Completeness**: 100% of countries from source dataset processed
- **Data Accuracy**: Zero data corruption during transformation
- **Performance**: Database setup completes in under 5 minutes
- **Usability**: Single command execution for complete setup

---

## 3. Target Users

### 3.1 Primary Users
- **Database Developers**: Setting up geographical reference data for applications
- **Data Analysts**: Requiring structured country data for reporting and analysis
- **Backend Developers**: Building applications with geographical features

### 3.2 Secondary Users
- **DevOps Engineers**: Automating database setup processes
- **QA Engineers**: Creating test data for geographical features
- **Business Intelligence Teams**: Building reports with geographical dimensions

---

## 4. Functional Requirements

### 4.1 Core Features

#### 4.1.1 Data Processing
- **FR-001**: Parse JSON data from mledoze/countries repository
- **FR-002**: Extract and normalize regions (6 world regions)
- **FR-003**: Extract and normalize subregions (24 subregions)
- **FR-004**: Process all country data (250+ countries/territories)
- **FR-005**: Handle special characters and Unicode properly

#### 4.1.2 SQL Generation
- **FR-006**: Generate Oracle-specific SQL syntax
- **FR-007**: Create separate SQL files for different data types
- **FR-008**: Generate DDL statements for table creation
- **FR-009**: Generate INSERT statements for data population
- **FR-010**: Create indexes for performance optimization

#### 4.1.3 Database Schema
- **FR-011**: Create regions table with proper constraints
- **FR-012**: Create subregions table with foreign key to regions
- **FR-013**: Create countries table with foreign keys to regions and subregions
- **FR-014**: Implement identity columns for primary keys
- **FR-015**: Add appropriate indexes on commonly queried columns

#### 4.1.4 File Management
- **FR-016**: Generate master script for sequential execution
- **FR-017**: Create example queries for common use cases
- **FR-018**: Organize files in logical directory structure
- **FR-019**: Include comprehensive documentation and comments

### 4.2 Data Schema Requirements

#### 4.2.1 Regions Table
- Primary key: `region_id`
- Unique constraint on `region_name`
- Created date tracking

#### 4.2.2 Subregions Table
- Primary key: `subregion_id`
- Foreign key to regions table
- Created date tracking

#### 4.2.3 Countries Table
- Primary key: `country_id`
- Foreign keys to regions and subregions
- Comprehensive country data including:
  - Names (common, official)
  - ISO codes (cca2, cca3, ccn3, cioc)
  - Status information (independent, UN member)
  - Geography (capital, coordinates, area, borders)
  - Additional metadata (currencies, languages, flag)

---

## 5. Non-Functional Requirements

### 5.1 Performance Requirements
- **NFR-001**: Process complete dataset in under 60 seconds
- **NFR-002**: Generated SQL files execute in under 5 minutes
- **NFR-003**: Database queries respond within 100ms for typical operations

### 5.2 Scalability Requirements
- **NFR-004**: Handle datasets up to 500 countries without performance degradation
- **NFR-005**: Support addition of new data fields without breaking existing structure

### 5.3 Reliability Requirements
- **NFR-006**: 100% data integrity during transformation process
- **NFR-007**: Zero data loss during processing
- **NFR-008**: Graceful error handling with informative messages

### 5.4 Usability Requirements
- **NFR-009**: Single command execution for complete setup
- **NFR-010**: Clear, comprehensive documentation
- **NFR-011**: Intuitive file organization and naming

### 5.5 Compatibility Requirements
- **NFR-012**: Support Python 3.7+ (using only standard library)
- **NFR-013**: Compatible with Oracle Database 11g+
- **NFR-014**: Cross-platform compatibility (Linux, Windows, macOS)

---

## 6. Technical Specifications

### 6.1 Architecture
- **Language**: Python 3.7+
- **Dependencies**: Standard library only (json, os, re, collections, datetime)
- **Database**: Oracle Database 11g or higher
- **File Format**: UTF-8 encoded SQL files

### 6.2 File Structure
```
project_root/
├── generate_oracle_sql.py    # Main generator script
├── setup.sh                  # Automated setup script
├── countries.json            # Source data file
├── requirements.txt          # Python dependencies
└── SQLs/                     # Generated SQL files
    ├── 00_master_script.sql
    ├── 01_create_tables.sql
    ├── 02_insert_regions.sql
    ├── 03_insert_subregions.sql
    ├── 04_insert_countries.sql
    └── 05_example_queries.sql
```

### 6.3 Data Sources
- **Primary**: mledoze/countries GitHub repository
- **Format**: JSON
- **Update Frequency**: As needed (repository updates)

---

## 7. User Stories

### 7.1 Database Developer
> "As a database developer, I need to quickly set up geographical reference data in my Oracle database so that I can build location-aware applications without manual data entry."

### 7.2 Data Analyst
> "As a data analyst, I need structured country and region data with proper relationships so that I can create accurate geographical reports and analysis."

### 7.3 DevOps Engineer
> "As a DevOps engineer, I need an automated way to populate geographical data in our databases so that I can include it in our deployment pipeline."

---

## 8. Acceptance Criteria

### 8.1 Data Processing
- [ ] Successfully processes all countries from source JSON
- [ ] Correctly identifies and normalizes 6 world regions
- [ ] Properly extracts 24 subregions with correct regional associations
- [ ] Handles Unicode characters and special symbols correctly

### 8.2 SQL Generation
- [ ] Generates valid Oracle SQL syntax
- [ ] Creates separate files for different data types
- [ ] Includes proper foreign key relationships
- [ ] Adds appropriate indexes for performance

### 8.3 Database Creation
- [ ] Master script executes without errors
- [ ] All tables created with correct structure
- [ ] Data inserted without corruption
- [ ] Indexes created and functioning properly

### 8.4 Documentation
- [ ] Comprehensive README with setup instructions
- [ ] Example queries demonstrate common use cases
- [ ] Code comments explain complex logic
- [ ] Database schema clearly documented

---

## 9. Risks and Mitigation

### 9.1 Technical Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Source data format changes | High | Medium | Regular monitoring, flexible parsing |
| Oracle syntax compatibility | Medium | Low | Thorough testing across versions |
| Character encoding issues | Medium | Low | Proper UTF-8 handling |

### 9.2 Data Quality Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Incomplete country data | Medium | Low | Data validation checks |
| Incorrect regional associations | High | Low | Cross-reference validation |
| Missing required fields | High | Low | Comprehensive field mapping |

---

## 10. Dependencies and Assumptions

### 10.1 External Dependencies
- mledoze/countries GitHub repository availability
- Oracle Database access for testing
- Python 3.7+ runtime environment

### 10.2 Assumptions
- Source data format remains consistent
- Oracle Database version supports used features
- Users have appropriate database permissions
- Network access available for data download

---

## 11. Future Enhancements

### 11.1 Planned Features
- Support for additional database systems (PostgreSQL, MySQL)
- Incremental update capability
- Data validation and quality checks
- Web interface for configuration

### 11.2 Potential Improvements
- Performance optimization for large datasets
- Support for historical data tracking
- Integration with CI/CD pipelines
- Automated testing framework

---

## 12. Appendices

### 12.1 Glossary
- **DDL**: Data Definition Language
- **DML**: Data Manipulation Language
- **FK**: Foreign Key
- **PK**: Primary Key
- **CCA2/CCA3**: ISO country codes
- **UN**: United Nations

### 12.2 References
- [mledoze/countries GitHub Repository](https://github.com/mledoze/countries)
- Oracle Database Documentation
- ISO 3166 Country Codes Standard
