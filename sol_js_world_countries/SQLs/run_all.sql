-- Oracle SQL Script to run all files in order
-- Use this script to execute all SQL files in the correct sequence
-- Execute this file with: @run_all.sql

PROMPT ========================================
PROMPT Creating tables...
PROMPT ========================================
@@01_create_tables.sql

PROMPT ========================================
PROMPT Inserting regions data...
PROMPT ========================================
@@02_regions_data.sql

PROMPT ========================================
PROMPT Inserting subregions data...
PROMPT ========================================
@@03_subregions_data.sql

PROMPT ========================================
PROMPT Inserting countries data...
PROMPT ========================================
@@04_countries_data.sql

PROMPT ========================================
PROMPT Verifying data...
PROMPT ========================================
select 'Regions' as table_name,
       count(*) as record_count
  from regions
union all
select 'Subregions' as table_name,
       count(*) as record_count
  from subregions
union all
select 'Countries' as table_name,
       count(*) as record_count
  from countries;

PROMPT ========================================
PROMPT Data load complete!
PROMPT ========================================