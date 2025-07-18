-- Example queries for the Countries database
-- Generated on: 2025-07-18 16:35:08

-- 1. Get all regions with count of countries
SELECT r.region_name, COUNT(c.country_id) as country_count
FROM regions r
LEFT JOIN countries c ON r.region_id = c.region_id
GROUP BY r.region_name
ORDER BY country_count DESC;

-- 2. Get all subregions with their regions and country counts
SELECT r.region_name, s.subregion_name, COUNT(c.country_id) as country_count
FROM regions r
JOIN subregions s ON r.region_id = s.region_id
LEFT JOIN countries c ON s.subregion_id = c.subregion_id
GROUP BY r.region_name, s.subregion_name
ORDER BY r.region_name, s.subregion_name;

-- 3. Get all independent countries in Europe
SELECT c.common_name, c.official_name, c.capital, c.area
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE r.region_name = 'Europe' AND c.independent = 1
ORDER BY c.common_name;

-- 4. Get largest countries by area
SELECT c.common_name, c.area, r.region_name, s.subregion_name
FROM countries c
JOIN regions r ON c.region_id = r.region_id
LEFT JOIN subregions s ON c.subregion_id = s.subregion_id
WHERE c.area > 0
ORDER BY c.area DESC
FETCH FIRST 10 ROWS ONLY;

-- 5. Get all UN member countries
SELECT c.common_name, c.official_name, r.region_name, c.un_regional_group
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE c.un_member = 1
ORDER BY r.region_name, c.common_name;

-- 6. Get landlocked countries
SELECT c.common_name, r.region_name, s.subregion_name, c.borders
FROM countries c
JOIN regions r ON c.region_id = r.region_id
LEFT JOIN subregions s ON c.subregion_id = s.subregion_id
WHERE c.landlocked = 1
ORDER BY r.region_name, c.common_name;

-- 7. Get countries with specific currency (Euro)
SELECT c.common_name, c.currencies
FROM countries c
WHERE c.currencies LIKE '%EUR%'
ORDER BY c.common_name;

-- 8. Get countries by language (English)
SELECT c.common_name, c.languages
FROM countries c
WHERE c.languages LIKE '%English%'
ORDER BY c.common_name;

-- 9. Get countries with multiple capitals
SELECT c.common_name, c.capital
FROM countries c
WHERE c.capital LIKE '%,%'
ORDER BY c.common_name;

-- 10. Get summary statistics
SELECT 
    (SELECT COUNT(*) FROM regions) as total_regions,
    (SELECT COUNT(*) FROM subregions) as total_subregions,
    (SELECT COUNT(*) FROM countries) as total_countries,
    (SELECT COUNT(*) FROM countries WHERE independent = 1) as independent_countries,
    (SELECT COUNT(*) FROM countries WHERE un_member = 1) as un_member_countries,
    (SELECT COUNT(*) FROM countries WHERE landlocked = 1) as landlocked_countries
FROM dual;
