-- Oracle SQL sample queries for the countries database
-- These queries demonstrate how to use the generated countries, regions, and subregions tables
-- Compatible with Oracle Database

-- 1. Get all regions with country counts
select r.id,
       r.name as region_name,
       count(c.id) as country_count
  from regions r
  left join countries c
on r.id = c.region_id
 group by r.id,
          r.name
 order by country_count desc;

-- 2. Get all subregions with their parent regions and country counts
select r.name as region_name,
       s.name as subregion_name,
       count(c.id) as country_count
  from regions r
  join subregions s
on r.id = s.region_id
  left join countries c
on s.id = c.subregion_id
 group by r.id,
          r.name,
          s.id,
          s.name
 order by r.name,
          s.name;

-- 3. Get all countries in Europe with their capitals
select c.name as country_name,
       c.capital,
       s.name as subregion_name,
       c.area,
       c.flag
  from countries c
  join subregions s
on c.subregion_id = s.id
  join regions r
on s.region_id = r.id
 where r.name = 'Europe'
 order by c.name;

-- 4. Get the largest countries by area in each region
select r.name as region_name,
       c.name as country_name,
       c.area,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where c.area = (
   select max(c2.area)
     from countries c2
    where c2.region_id = c.region_id
)
 order by c.area desc;

-- 5. Find all independent countries that are UN members
select c.name as country_name,
       c.capital,
       r.name as region_name,
       s.name as subregion_name,
       c.area,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
  left join subregions s
on c.subregion_id = s.id
 where c.independent = true
   and c.un_member = true
 order by c.name;

-- 6. Get all countries in the Caribbean
select c.name as country_name,
       c.capital,
       c.area,
       c.independent,
       c.flag
  from countries c
  join subregions s
on c.subregion_id = s.id
 where s.name = 'Caribbean'
 order by c.name;

-- 7. Find countries with no capital listed
select c.name as country_name,
       r.name as region_name,
       c.area,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where c.capital is null
 order by c.name;

-- 8. Get countries sorted by area (largest first)
select c.name as country_name,
       c.capital,
       r.name as region_name,
       c.area,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where c.area is not null
 order by c.area desc
 fetch first 10 rows only;

-- 9. Find all countries with names containing specific words
select c.name as country_name,
       c.official_name,
       r.name as region_name,
       c.capital,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where c.name like '%Island%'
    or c.name like '%Republic%'
    or c.name like '%Kingdom%'
 order by c.name;

-- 10. Get regional statistics
select r.name as region_name,
       count(c.id) as total_countries,
       count(
          case
             when c.independent = true then
                1
          end
       ) as independent_countries,
       count(
          case
             when c.un_member = true then
                1
          end
       ) as un_member_countries,
       round(
          avg(c.area),
          2
       ) as avg_area,
       max(c.area) as largest_country_area,
       min(c.area) as smallest_country_area
  from regions r
  left join countries c
on r.id = c.region_id
 group by r.id,
          r.name
 order by total_countries desc;

-- 11. Search for countries by coordinates (example: countries in northern hemisphere)
select c.name as country_name,
       c.capital,
       r.name as region_name,
       c.latitude,
       c.longitude,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
 where c.latitude > 0  -- Northern hemisphere
 order by c.latitude desc;

-- 12. Get all country codes and names for API integration
select c.cca2 as iso_alpha2,
       c.cca3 as iso_alpha3,
       c.ccn3 as iso_numeric,
       c.name as common_name,
       c.official_name,
       c.flag
  from countries c
 order by c.name;

-- 13. Find territorial dependencies (non-independent countries)
select c.name as territory_name,
       c.capital,
       r.name as region_name,
       s.name as subregion_name,
       c.area,
       c.flag
  from countries c
  join regions r
on c.region_id = r.id
  left join subregions s
on c.subregion_id = s.id
 where c.independent = false
 order by r.name,
          c.name;

-- 14. Compare countries within the same subregion
select s.name as subregion_name,
       c.name as country_name,
       c.capital,
       c.area,
       c.independent,
       c.flag
  from countries c
  join subregions s
on c.subregion_id = s.id
 where s.name = 'Western Europe'  -- Change this to any subregion
 order by c.area desc;

-- 15. Create a summary report
select 'Total Countries' as metric,
       count(*) as value
  from countries
union all
select 'Total Regions' as metric,
       count(*) as value
  from regions
union all
select 'Total Subregions' as metric,
       count(*) as value
  from subregions
union all
select 'Independent Countries' as metric,
       count(*) as value
  from countries
 where independent = true
union all
select 'UN Member Countries' as metric,
       count(*) as value
  from countries
 where un_member = true;