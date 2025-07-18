-- Oracle Migration script for countries database
-- This script helps you set up the Oracle countries database step by step

-- Step 1: Create the database user (uncomment and modify as needed)
-- CREATE USER countries_user IDENTIFIED BY your_password;
-- GRANT CREATE SESSION, CREATE TABLE TO countries_user;
-- GRANT UNLIMITED TABLESPACE TO countries_user;

-- Step 2: Connect as the countries_user
-- CONNECT countries_user/your_password@your_database;

-- Step 3: Create tables and insert data
--
-- Option A: Run separate files in order (recommended for production)
-- @01_create_tables.sql    -- Create tables with constraints
-- @02_regions_data.sql     -- Insert 6 regions
-- @03_subregions_data.sql  -- Insert 24 subregions
-- @04_countries_data.sql   -- Insert 250 countries
--
-- Option B: Run complete file (good for development/testing)
-- @countries_data_oracle.sql
--
-- Note: Use @ symbol for SQL*Plus or substitute with your preferred method

-- Step 4: Verify the data
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

-- Step 5: Test the relationships
select r.name as region_name,
       count(distinct s.id) as subregions_count,
       count(c.id) as countries_count
  from regions r
  left join subregions s
on r.id = s.region_id
  left join countries c
on r.id = c.region_id
 group by r.id,
          r.name
 order by countries_count desc;

-- Step 6: Create indexes for better performance
create index idx_countries_region_id on
   countries (
      region_id
   );
create index idx_countries_subregion_id on
   countries (
      subregion_id
   );
create index idx_countries_cca2 on
   countries (
      cca2
   );
create index idx_countries_cca3 on
   countries (
      cca3
   );
create index idx_subregions_region_id on
   subregions (
      region_id
   );

-- Step 7: Oracle specific optimizations
-- Gather statistics for better query performance
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'REGIONS');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'SUBREGIONS');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'COUNTRIES');

-- Step 8: Create additional useful views (optional)
create or replace view v_country_details as
   select c.id,
          c.cca2,
          c.cca3,
          c.name,
          c.official_name,
          r.name as region_name,
          s.name as subregion_name,
          c.capital,
          c.area,
          c.population,
          case c.independent
             when 1 then
                'Yes'
             else
                'No'
          end as independent_status,
          case c.un_member
             when 1 then
                'Yes'
             else
                'No'
          end as un_member_status,
          c.flag,
          c.latitude,
          c.longitude
     from countries c
     left join regions r
   on c.region_id = r.id
     left join subregions s
   on c.subregion_id = s.id;