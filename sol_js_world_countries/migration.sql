-- Migration script for countries database
-- This script helps you set up the countries database step by step

-- Step 1: Create the database (uncomment the appropriate line for your database)
-- CREATE DATABASE countries_db;  -- MySQL/PostgreSQL
-- USE countries_db;              -- MySQL

-- Step 2: Enable foreign key constraints (if using SQLite)
-- PRAGMA foreign_keys = ON;      -- SQLite only

-- Step 3: Create tables and insert data
-- Run the appropriate SQL file for your database:
-- - countries_data.sql (MySQL/MariaDB)
-- - countries_data_postgresql.sql (PostgreSQL)
-- - countries_data_sqlite.sql (SQLite)
-- - countries_data_sqlserver.sql (SQL Server)

-- Step 4: Verify the data
SELECT 'Regions' as table_name, COUNT(*) as record_count FROM regions
UNION ALL
SELECT 'Subregions' as table_name, COUNT(*) as record_count FROM subregions
UNION ALL
SELECT 'Countries' as table_name, COUNT(*) as record_count FROM countries;

-- Step 5: Test the relationships
SELECT 
    r.name as region_name,
    COUNT(DISTINCT s.id) as subregions_count,
    COUNT(c.id) as countries_count
FROM regions r
LEFT JOIN subregions s ON r.id = s.region_id
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name
ORDER BY countries_count DESC;

-- Step 6: Create indexes for better performance (optional)
CREATE INDEX idx_countries_region_id ON countries(region_id);
CREATE INDEX idx_countries_subregion_id ON countries(subregion_id);
CREATE INDEX idx_countries_cca2 ON countries(cca2);
CREATE INDEX idx_countries_cca3 ON countries(cca3);
CREATE INDEX idx_subregions_region_id ON subregions(region_id);
