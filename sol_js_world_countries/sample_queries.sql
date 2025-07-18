-- Oracle SQL sample queries for the countries database
-- These queries demonstrate how to use the generated countries, regions, and subregions tables
-- Compatible with Oracle Database

-- 1. Get all regions with country counts
SELECT 
    r.id,
    r.name as region_name,
    COUNT(c.id) as country_count
FROM regions r
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name
ORDER BY country_count DESC;

-- 2. Get all subregions with their parent regions and country counts
SELECT 
    r.name as region_name,
    s.name as subregion_name,
    COUNT(c.id) as country_count
FROM regions r
JOIN subregions s ON r.id = s.region_id
LEFT JOIN countries c ON s.id = c.subregion_id
GROUP BY r.id, r.name, s.id, s.name
ORDER BY r.name, s.name;

-- 3. Get all countries in Europe with their capitals
SELECT 
    c.name as country_name,
    c.capital,
    s.name as subregion_name,
    c.area,
    c.flag
FROM countries c
JOIN subregions s ON c.subregion_id = s.id
JOIN regions r ON s.region_id = r.id
WHERE r.name = 'Europe'
ORDER BY c.name;

-- 4. Get the largest countries by area in each region
SELECT 
    r.name as region_name,
    c.name as country_name,
    c.area,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE c.area = (
    SELECT MAX(c2.area) 
    FROM countries c2 
    WHERE c2.region_id = c.region_id
)
ORDER BY c.area DESC;

-- 5. Find all independent countries that are UN members
SELECT 
    c.name as country_name,
    c.capital,
    r.name as region_name,
    s.name as subregion_name,
    c.area,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
LEFT JOIN subregions s ON c.subregion_id = s.id
WHERE c.independent = TRUE 
    AND c.un_member = TRUE
ORDER BY c.name;

-- 6. Get all countries in the Caribbean
SELECT 
    c.name as country_name,
    c.capital,
    c.area,
    c.independent,
    c.flag
FROM countries c
JOIN subregions s ON c.subregion_id = s.id
WHERE s.name = 'Caribbean'
ORDER BY c.name;

-- 7. Find countries with no capital listed
SELECT 
    c.name as country_name,
    r.name as region_name,
    c.area,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE c.capital IS NULL
ORDER BY c.name;

-- 8. Get countries sorted by area (largest first)
SELECT 
    c.name as country_name,
    c.capital,
    r.name as region_name,
    c.area,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE c.area IS NOT NULL
ORDER BY c.area DESC
LIMIT 10;

-- 9. Find all countries with names containing specific words
SELECT 
    c.name as country_name,
    c.official_name,
    r.name as region_name,
    c.capital,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE c.name LIKE '%Island%' 
    OR c.name LIKE '%Republic%'
    OR c.name LIKE '%Kingdom%'
ORDER BY c.name;

-- 10. Get regional statistics
SELECT 
    r.name as region_name,
    COUNT(c.id) as total_countries,
    COUNT(CASE WHEN c.independent = TRUE THEN 1 END) as independent_countries,
    COUNT(CASE WHEN c.un_member = TRUE THEN 1 END) as un_member_countries,
    ROUND(AVG(c.area), 2) as avg_area,
    MAX(c.area) as largest_country_area,
    MIN(c.area) as smallest_country_area
FROM regions r
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name
ORDER BY total_countries DESC;

-- 11. Search for countries by coordinates (example: countries in northern hemisphere)
SELECT 
    c.name as country_name,
    c.capital,
    r.name as region_name,
    c.latitude,
    c.longitude,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE c.latitude > 0  -- Northern hemisphere
ORDER BY c.latitude DESC;

-- 12. Get all country codes and names for API integration
SELECT 
    c.cca2 as iso_alpha2,
    c.cca3 as iso_alpha3,
    c.ccn3 as iso_numeric,
    c.name as common_name,
    c.official_name,
    c.flag
FROM countries c
ORDER BY c.name;

-- 13. Find territorial dependencies (non-independent countries)
SELECT 
    c.name as territory_name,
    c.capital,
    r.name as region_name,
    s.name as subregion_name,
    c.area,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
LEFT JOIN subregions s ON c.subregion_id = s.id
WHERE c.independent = FALSE
ORDER BY r.name, c.name;

-- 14. Compare countries within the same subregion
SELECT 
    s.name as subregion_name,
    c.name as country_name,
    c.capital,
    c.area,
    c.independent,
    c.flag
FROM countries c
JOIN subregions s ON c.subregion_id = s.id
WHERE s.name = 'Western Europe'  -- Change this to any subregion
ORDER BY c.area DESC;

-- 15. Create a summary report
SELECT 
    'Total Countries' as metric,
    COUNT(*) as value
FROM countries
UNION ALL
SELECT 
    'Total Regions' as metric,
    COUNT(*) as value
FROM regions
UNION ALL
SELECT 
    'Total Subregions' as metric,
    COUNT(*) as value
FROM subregions
UNION ALL
SELECT 
    'Independent Countries' as metric,
    COUNT(*) as value
FROM countries 
WHERE independent = TRUE
UNION ALL
SELECT 
    'UN Member Countries' as metric,
    COUNT(*) as value
FROM countries 
WHERE un_member = TRUE;
