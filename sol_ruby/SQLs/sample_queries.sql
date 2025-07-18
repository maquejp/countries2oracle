-- Sample queries for the Countries database generated from Ruby Countries gem
-- These queries demonstrate how to use the regions, subregions, and countries tables

-- 1. Get all regions
SELECT * FROM regions ORDER BY name;

-- 2. Get all subregions with their regions
SELECT s.name as subregion, r.name as region
FROM subregions s
JOIN regions r ON s.region_id = r.id
ORDER BY r.name, s.name;

-- 3. Get all countries with their regions and subregions
SELECT c.name as country, c.cca2, c.cca3, r.name as region, s.name as subregion
FROM countries c
JOIN regions r ON c.region_id = r.id
JOIN subregions s ON c.subregion_id = s.id
ORDER BY r.name, s.name, c.name;

-- 4. Count countries by region
SELECT r.name as region, COUNT(c.id) as country_count
FROM regions r
LEFT JOIN countries c ON r.id = c.region_id
GROUP BY r.id, r.name
ORDER BY country_count DESC;

-- 5. Count countries by subregion
SELECT s.name as subregion, r.name as region, COUNT(c.id) as country_count
FROM subregions s
JOIN regions r ON s.region_id = r.id
LEFT JOIN countries c ON s.id = c.subregion_id
GROUP BY s.id, s.name, r.name
ORDER BY country_count DESC;

-- 6. Find countries in a specific region
SELECT c.name, c.cca2, c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
WHERE r.name = 'Europe'
ORDER BY c.name;

-- 7. Find countries in a specific subregion
SELECT c.name, c.cca2, c.flag
FROM countries c
JOIN subregions s ON c.subregion_id = s.id
WHERE s.name = 'Western Europe'
ORDER BY c.name;

-- 8. Get countries with their coordinates
SELECT c.name, c.cca2, c.latitude, c.longitude, c.flag
FROM countries c
WHERE c.latitude IS NOT NULL AND c.longitude IS NOT NULL
ORDER BY c.name;

-- 9. Find countries by ISO code
SELECT c.name, c.official_name, r.name as region, s.name as subregion
FROM countries c
JOIN regions r ON c.region_id = r.id
JOIN subregions s ON c.subregion_id = s.id
WHERE c.cca2 = 'US' OR c.cca3 = 'USA';

-- 10. Get all subregions in a specific region
SELECT s.name as subregion
FROM subregions s
JOIN regions r ON s.region_id = r.id
WHERE r.name = 'Americas'
ORDER BY s.name;

-- 11. Countries with flags (emoji)
SELECT c.name, c.cca2, c.flag
FROM countries c
WHERE c.flag IS NOT NULL
ORDER BY c.name
LIMIT 10;

-- 12. Full country details
SELECT 
    c.name,
    c.official_name,
    c.cca2,
    c.cca3,
    c.ccn3,
    r.name as region,
    s.name as subregion,
    c.latitude,
    c.longitude,
    c.flag
FROM countries c
JOIN regions r ON c.region_id = r.id
JOIN subregions s ON c.subregion_id = s.id
ORDER BY c.name;
