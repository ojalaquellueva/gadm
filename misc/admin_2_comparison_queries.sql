-- Compare number of gadm admin_1 poldivis indexed vs not
-- indexed to geonames
SELECT has_geonameid, COUNT(*) 
FROM (
SELECT 
CASE
WHEN geonameid IS NULL THEN 'No'
ELSE 'Yes'
END AS has_geonameid
FROM gadm_admin_2
) a
GROUP BY has_geonameid
;

-- List numbers of non-indexed admin_2 division by country
SELECT name_0, name_1, COUNT(*) AS unindexed_admin_2
FROM gadm_admin_2
WHERE geonameid IS NULL
GROUP BY name_0, name_1
ORDER BY name_0, name_1
;

-- Count unmatched admin_2 by country
SELECT name_0, COUNT(*) AS unindexed_admin_2
FROM gadm_admin_2
WHERE geonameid IS NULL
GROUP BY name_0
ORDER BY name_0
;

-- Compare by country
select name_0, admin_0_geonameid, name_1, admin_1_geonameid, name_2_ascii, type_2_ascii, geonameid from gadm_admin_2  where name_0='Canada' order by name_1, name_2 ;

select country, state_province, left(county_parish_ascii, 50) as county_parish_ascii, left(county_parish_std, 50) as county_parish_std, county_parish_code_full, county_parish_code2_full from geonames_county_parish where country='Canada' order by state_province, county_parish;

-- Compare by state
select name_0, admin_0_geonameid, name_1, admin_1_geonameid, name_2_ascii, type_2_ascii, geonameid from gadm_admin_2  where name_0='Mexico' and name_1='Oaxaca' order by name_1, name_2 ;

select country, state_province, left(county_parish_ascii, 50) as county_parish_ascii, left(county_parish_std, 50) as county_parish_std, county_parish_code_full, county_parish_code2_full from geonames_county_parish where country='Mexico' and state_province like '%Oaxaca%' order by state_province, county_parish ;



select distinct state_province_ascii, state_province_std from geonames_state_province order by state_province_ascii, state_province_std;

select distinct county_parish_ascii, county_parish_std from geonames_county_parish order by county_parish_ascii, county_parish_std;