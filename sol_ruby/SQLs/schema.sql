-- Create tables for regions, subregions, and countries

DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS subregions;
DROP TABLE IF EXISTS regions;

CREATE TABLE regions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subregions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    region_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id)
);

CREATE TABLE countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cca2 VARCHAR(2) UNIQUE NOT NULL,
    cca3 VARCHAR(3) UNIQUE NOT NULL,
    ccn3 VARCHAR(3),
    name VARCHAR(100) NOT NULL,
    official_name VARCHAR(200),
    region VARCHAR(50),
    subregion VARCHAR(100),
    region_id INT,
    subregion_id INT,
    capital VARCHAR(100),
    area DECIMAL(15,2),
    population BIGINT,
    independent BOOLEAN,
    un_member BOOLEAN,
    flag VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id),
    FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

