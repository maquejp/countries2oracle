-- Master script to execute all SQL files
-- Generated on: 2025-07-18 17:26:50
-- Execute this script to create and populate the entire database

PROMPT Creating tables...
@@01_create_tables.sql

PROMPT Inserting regions...
@@02_insert_regions.sql

PROMPT Inserting subregions...
@@03_insert_subregions.sql

PROMPT Inserting countries...
@@04_insert_countries.sql

PROMPT Setup complete!
PROMPT
PROMPT To run example queries, execute:
PROMPT @@05_example_queries.sql
PROMPT
PROMPT Database statistics:
SELECT 
    (SELECT COUNT(*) FROM regions) as total_regions,
    (SELECT COUNT(*) FROM subregions) as total_subregions,
    (SELECT COUNT(*) FROM countries) as total_countries,
    (SELECT COUNT(*) FROM countries WHERE independent = 1) as independent_countries,
    (SELECT COUNT(*) FROM countries WHERE un_member = 1) as un_member_countries
FROM dual;
