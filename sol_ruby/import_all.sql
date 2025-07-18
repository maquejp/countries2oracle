-- Master import script for Countries database
-- This script imports all tables in the correct order to maintain foreign key relationships

-- Usage:
-- For MySQL: mysql -u username -p database_name < import_all.sql
-- For PostgreSQL: psql -U username -d database_name -f import_all.sql

-- Or run each file individually:
-- 1. schema.sql     - Create tables
-- 2. regions.sql    - Insert regions
-- 3. subregions.sql - Insert subregions  
-- 4. countries.sql  - Insert countries

-- Note: This file contains the combined SQL from all separate files
-- Use the individual files if you need more control over the import process

-- 1. Create the database schema
-- Run: mysql -u username -p database_name < schema.sql

-- 2. Insert regions (no dependencies)
-- Run: mysql -u username -p database_name < regions.sql

-- 3. Insert subregions (depends on regions)
-- Run: mysql -u username -p database_name < subregions.sql

-- 4. Insert countries (depends on regions and subregions)
-- Run: mysql -u username -p database_name < countries.sql

-- Verification queries:
-- SELECT COUNT(*) FROM regions;     -- Should return 5
-- SELECT COUNT(*) FROM subregions;  -- Should return 22
-- SELECT COUNT(*) FROM countries;   -- Should return 246
