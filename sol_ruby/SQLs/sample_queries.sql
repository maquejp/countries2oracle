-- Sample queries for the Countries database generated from Ruby Countries gem (Oracle version)
-- These queries demonstrate how to use the regions, subregions, and countries tables

-- 1. Get all regions
select *
  from regions
 order by name;

-- 2. Get all subregions with their regions
select s.name as subregion,
       r.name as region
  from subregions s
  join regions r
on s.region_id = r.id
 order by r.name,
          s.name;

-- 3. Get all countries with their regions and subregions
select c.name as country,
       c.cca2,
       c.cca3,
       r.name as region,
       s.name as subregion
  from countries c
  join regions r
on c.region_id = r.id
  join subregions s
on c.subregion_id = s.id
 order by r.name,
          s.name,
          c.name;

-- 4. Count countries by region
select r.name as region,
       count(c.id) as country_count
  from regions r
  left join countries c
on r.id = c.region_id
 group by r.id,
          r.name
 order by country_count desc;

-- 5. Count countries by subregion
select s.name as subregion,
       r.name as region,
       count(c.id) as country_count
  from subregions s
  join regions r
on s.region_id = r.id
  left join countries c
on s.id = c.subregion_id
 group by s.id,
          s.name,
          r.name
 order by country_count desc;

-- 6. Find countries in a specific region
select c.name,
       c.cca2,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where r.name = 'Europe'
 order by c.name;

-- 7. Find countries in a specific subregion
select c.name,
       c.cca2,
       c.flag
  from countries c
  join subregions s
on c.subregion_id = s.id
 where s.name = 'Western Europe'
 order by c.name;

-- 8. Get countries with their coordinates
select c.name,
       c.cca2,
       c.latitude,
       c.longitude,
       c.flag
  from countries c
 where c.latitude is not null
   and c.longitude is not null
 order by c.name;

-- 9. Find countries by ISO code
select c.name,
       c.official_name,
       r.name as region,
       s.name as subregion
  from countries c
  join regions r
on c.region_id = r.id
  join subregions s
on c.subregion_id = s.id
 where c.cca2 = 'US'
    or c.cca3 = 'USA';

-- 10. Get all subregions in a specific region
select s.name as subregion
  from subregions s
  join regions r
on s.region_id = r.id
 where r.name = 'Americas'
 order by s.name;

-- 11. Countries with flags (emoji) - limited to 10 rows
select c.name,
       c.cca2,
       c.flag
  from countries c
 where c.flag is not null
 order by c.name
 fetch first 10 rows only;

-- 12. Full country details with boolean values as 1/0
select c.name,
       c.official_name,
       c.cca2,
       c.cca3,
       c.ccn3,
       r.name as region,
       s.name as subregion,
       c.latitude,
       c.longitude,
       c.flag,
       case
          when c.independent = 1 then
             'Yes'
          else
             'No'
       end as independent,
       case
          when c.un_member = 1 then
             'Yes'
          else
             'No'
       end as un_member
  from countries c
  join regions r
on c.region_id = r.id
  join subregions s
on c.subregion_id = s.id
 order by c.name;