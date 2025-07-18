-- Generated Oracle SQL for Countries Database
-- Generated on: 2025-07-18T14:01:11.458Z
-- Total countries: 250
-- Total regions: 6
-- Total subregions: 24
-- Database: Oracle (without sequences/triggers)

-- Create tables for countries, regions, and subregions (Oracle format)
    
CREATE TABLE regions (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subregions (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL UNIQUE,
    region_id NUMBER(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subregions_region FOREIGN KEY (region_id) REFERENCES regions(id)
);

CREATE TABLE countries (
    id NUMBER(10) PRIMARY KEY,
    cca2 VARCHAR2(2) NOT NULL UNIQUE,
    cca3 VARCHAR2(3) NOT NULL UNIQUE,
    ccn3 VARCHAR2(3),
    name VARCHAR2(100) NOT NULL,
    official_name VARCHAR2(200),
    region VARCHAR2(50),
    subregion VARCHAR2(100),
    region_id NUMBER(10),
    subregion_id NUMBER(10),
    capital VARCHAR2(100),
    area NUMBER(15,2),
    population NUMBER(19),
    independent NUMBER(1) CHECK (independent IN (0, 1)),
    un_member NUMBER(1) CHECK (un_member IN (0, 1)),
    flag VARCHAR2(10),
    latitude NUMBER(10,8),
    longitude NUMBER(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(id),
    CONSTRAINT fk_countries_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

