-- Create tables for regions, subregions, and countries (Oracle compatible)

-- Drop tables in reverse order due to foreign key constraints
DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE subregions CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;

-- Create regions table
CREATE TABLE regions (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create subregions table
CREATE TABLE subregions (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) UNIQUE NOT NULL,
    region_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subregions_region FOREIGN KEY (region_id) REFERENCES regions(id)
);

-- Create countries table
CREATE TABLE countries (
    id NUMBER PRIMARY KEY,
    cca2 VARCHAR2(2) UNIQUE NOT NULL,
    cca3 VARCHAR2(3) UNIQUE NOT NULL,
    ccn3 VARCHAR2(3),
    name VARCHAR2(100) NOT NULL,
    official_name VARCHAR2(200),
    region VARCHAR2(50),
    subregion VARCHAR2(100),
    region_id NUMBER,
    subregion_id NUMBER,
    capital VARCHAR2(100),
    area NUMBER(15,2),
    population NUMBER(15),
    independent NUMBER(1) DEFAULT 0,
    un_member NUMBER(1) DEFAULT 0,
    eea_member NUMBER(1) DEFAULT 0,
    eu_member NUMBER(1) DEFAULT 0,
    flag VARCHAR2(10),
    latitude NUMBER(10,8),
    longitude NUMBER(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(id),
    CONSTRAINT fk_countries_subregion FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

