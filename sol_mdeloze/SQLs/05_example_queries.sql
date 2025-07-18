-- Example queries for the Countries database
-- Generated on: 2025-07-18 17:55:29

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
    (SELECT COUNT(*) FROM countries WHERE landlocked = 1) as landlocked_countries,
    (SELECT COUNT(*) FROM countries WHERE eu_member = 1) as eu_member_countries,
    (SELECT COUNT(*) FROM countries WHERE efta_member = 1) as efta_member_countries,
    (SELECT COUNT(*) FROM countries WHERE eea_member = 1) as eea_member_countries
FROM dual;

-- 11. Get all EU member countries
SELECT c.common_name, c.official_name, r.region_name, c.capital
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE c.eu_member = 1
ORDER BY c.common_name;

-- 12. Get all EFTA member countries
SELECT c.common_name, c.official_name, r.region_name, c.capital
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE c.efta_member = 1
ORDER BY c.common_name;

-- 13. Get all EEA member countries
SELECT c.common_name, c.official_name, r.region_name, c.capital
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE c.eea_member = 1
ORDER BY c.common_name;

-- 14. Get countries with multiple memberships
SELECT c.common_name, c.official_name, 
       CASE WHEN c.eu_member = 1 THEN 'EU' ELSE '' END ||
       CASE WHEN c.efta_member = 1 THEN CASE WHEN c.eu_member = 1 THEN ', EFTA' ELSE 'EFTA' END ELSE '' END ||
       CASE WHEN c.eea_member = 1 THEN CASE WHEN c.eu_member = 1 OR c.efta_member = 1 THEN ', EEA' ELSE 'EEA' END ELSE '' END as memberships
FROM countries c
WHERE c.eu_member = 1 OR c.efta_member = 1 OR c.eea_member = 1
ORDER BY c.common_name;

-- 15. Get countries in Europe that are not EU members
SELECT c.common_name, c.official_name, c.capital,
       CASE WHEN c.efta_member = 1 THEN 'EFTA' ELSE 'No EU/EFTA' END as status
FROM countries c
JOIN regions r ON c.region_id = r.region_id
WHERE r.region_name = 'Europe' AND c.eu_member = 0 AND c.independent = 1
ORDER BY c.common_name;
