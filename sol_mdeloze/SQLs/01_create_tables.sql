-- Oracle SQL Table Creation Script
-- Generated on: 2025-07-18 17:14:59
-- Based on: https://github.com/mledoze/countries

-- Drop tables if they exist (in correct order due to foreign keys)
DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE subregions CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;

-- Create REGIONS table
CREATE TABLE regions (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(100) NOT NULL UNIQUE,
    created_date DATE DEFAULT SYSDATE
);

-- Create SUBREGIONS table
CREATE TABLE subregions (
    subregion_id NUMBER PRIMARY KEY,
    subregion_name VARCHAR2(100) NOT NULL,
    region_id NUMBER,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_subregion_region FOREIGN KEY (region_id) REFERENCES regions(region_id),
    CONSTRAINT uk_subregion_name UNIQUE (subregion_name, region_id)
);

-- Create COUNTRIES table
CREATE TABLE countries (
    country_id NUMBER PRIMARY KEY,
    -- Basic country information
    common_name VARCHAR2(100) NOT NULL,
    official_name VARCHAR2(200),
    cca2 CHAR(2) UNIQUE,
    cca3 CHAR(3) UNIQUE,
    ccn3 CHAR(3),
    cioc CHAR(3),
    
    -- Status information
    independent NUMBER(1) DEFAULT 0,
    status VARCHAR2(50),
    un_member NUMBER(1) DEFAULT 0,
    un_regional_group VARCHAR2(100),
    eu_member NUMBER(1) DEFAULT 0,
    efta_member NUMBER(1) DEFAULT 0,
    eea_member NUMBER(1) DEFAULT 0,
    
    -- Geographic information
    region_id NUMBER,
    subregion_id NUMBER,
    capital VARCHAR2(500), -- Can be multiple capitals
    latlng VARCHAR2(50), -- Stored as "lat,lng"
    landlocked NUMBER(1) DEFAULT 0,
    borders VARCHAR2(1000), -- Comma-separated country codes
    area NUMBER,
    
    -- Additional information
    tld VARCHAR2(200), -- Top-level domains
    currencies VARCHAR2(1000), -- JSON string of currencies
    languages VARCHAR2(1000), -- JSON string of languages
    alt_spellings VARCHAR2(1000), -- Comma-separated alternative spellings
    flag_emoji VARCHAR2(10),
    
    -- Metadata
    created_date DATE DEFAULT SYSDATE,
    
    -- Foreign key constraints
    CONSTRAINT fk_country_region FOREIGN KEY (region_id) REFERENCES regions(region_id),
    CONSTRAINT fk_country_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(subregion_id)
);

-- Create indexes for better performance
CREATE INDEX idx_countries_region ON countries(region_id);
CREATE INDEX idx_countries_subregion ON countries(subregion_id);
CREATE INDEX idx_countries_cca2 ON countries(cca2);
CREATE INDEX idx_countries_cca3 ON countries(cca3);
CREATE INDEX idx_countries_independent ON countries(independent);
CREATE INDEX idx_countries_un_member ON countries(un_member);
CREATE INDEX idx_countries_eu_member ON countries(eu_member);
CREATE INDEX idx_countries_efta_member ON countries(efta_member);
CREATE INDEX idx_countries_eea_member ON countries(eea_member);

-- Add comments to tables
COMMENT ON TABLE regions IS 'World regions (continents)';
COMMENT ON TABLE subregions IS 'World subregions within continents';
COMMENT ON TABLE countries IS 'World countries and territories based on ISO 3166-1';

-- Add comments to columns
COMMENT ON COLUMN countries.common_name IS 'Common name in English';
COMMENT ON COLUMN countries.official_name IS 'Official name in English';
COMMENT ON COLUMN countries.cca2 IS 'ISO 3166-1 alpha-2 code';
COMMENT ON COLUMN countries.cca3 IS 'ISO 3166-1 alpha-3 code';
COMMENT ON COLUMN countries.ccn3 IS 'ISO 3166-1 numeric code';
COMMENT ON COLUMN countries.cioc IS 'International Olympic Committee code';
COMMENT ON COLUMN countries.independent IS '1 if independent sovereign state, 0 otherwise';
COMMENT ON COLUMN countries.un_member IS '1 if UN member, 0 otherwise';
COMMENT ON COLUMN countries.landlocked IS '1 if landlocked, 0 otherwise';
COMMENT ON COLUMN countries.area IS 'Area in square kilometers';
COMMENT ON COLUMN countries.flag_emoji IS 'Unicode flag emoji';

COMMIT;
