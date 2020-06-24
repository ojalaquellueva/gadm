-- Compare number of gadm admin_1 poldivis indexed vs not
-- indexed to geonames
SELECT has_geonameid, COUNT(*) 
FROM (
SELECT 
CASE
WHEN geonameid IS NULL THEN 'No'
ELSE 'Yes'
END AS has_geonameid
FROM gadm_admin_1
) a
GROUP BY has_geonameid
;

-- List numbers of non-indexed admin_2 division by country
SELECT name_0, COUNT(*) AS unindexed_admin_1
FROM gadm_admin_1
WHERE geonameid IS NULL
GROUP BY name_0
ORDER BY name_0
;

--
-- Queries for specific admin_1
--

SELECT * FROM gadm_admin_1 WHERE name_0_ascii ILIKE '%Aland%' LIMIT 1;
SELECT * FROM geonames_state_province WHERE state_province_ascii ILIKE '%Aland%' LIMIT 1;
SELECT * FROM admin1_crosswalk WHERE admin ILIKE '%Aland%' LIMIT 1;

SELECT * FROM gadm_admin_1 WHERE geonameid IS NULL AND name_0='Chile' LIMIT 1;
SELECT * FROM geonames_state_province WHERE country='Chile' AND state_province_ascii ILIKE '%uble%' LIMIT 1;
SELECT * FROM admin1_crosswalk WHERE admin='Chile' AND name_ascii ILIKE '%uble%' LIMIT 1;

SELECT * FROM gadm_admin_1 WHERE name_0 ILIKE '%Puerto Rico%' AND geonameid IS NULL ORDER BY name_0, name_1;

SELECT * FROM gadm_admin_1 WHERE name_0 ILIKE '%Puerto Rico%' ORDER BY name_0, name_1;

SELECT country, country_iso, state_province_ascii, state_province_std, state_province_code_full as fips, state_province_code2_full as fips_alt, hasc, hasc_full 
FROM geonames_state_province 
WHERE country ILIKE '%Puerto Rico%'
order by country, state_province_ascii;


SELECT admin, adm0_a3, name, name_ascii, type, adm1_code, iso_3166_2, code_hasc, fips, fips_alt, postal, gn_id, gns_name, gns_adm1, gn_a1_code
FROM admin1_crosswalk WHERE admin ILIKE '%Puerto Rico%'
order by admin, name;

SELECT admin, adm0_a3, name, name_ascii, adm1_code, iso_3166_2, code_hasc, fips, fips_alt, postal, gn_id, gns_name, gns_adm1, gn_a1_code
FROM admin1_crosswalk WHERE admin ILIKE '%Puerto Rico%'
order by admin, name;


-- Query non-matched poldivs

-- gadm_admin_1
SELECT DISTINCT gid_0, name_0, hasc_1, name_1_ascii AS admin_2_ascii, type_1, engtype_1
FROM gadm_admin_1 
WHERE geonameid IS NULL 
ORDER BY name_0, name_1_ascii
;


SELECT country_iso_alpha3, country, state_province_code_full as fips, state_province_code2_full as fips_alt, hasc, hasc_full, state_province_ascii
FROM geonames_state_province
WHERE country_iso_alpha3 IN (
SELECT DISTINCT gid_0 FROM gadm_admin_1 WHERE geonameid IS NULL 
)
ORDER BY country, state_province_ascii
;



