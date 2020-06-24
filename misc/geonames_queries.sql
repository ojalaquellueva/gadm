\x

SELECT *
FROM gadm_nospatial
LIMIT 1
;

\x

SELECT DISTINCT 
gid_0, name_0, gid_1, hasc_1, name_1, engtype_1, country, state_province
FROM gadm
ORDER BY name_0, name_1
LIMIT 12;

SELECT DISTINCT 
gid_0, name_0, gid_1, hasc_1, name_1, engtype_1, country, state_province
FROM gadm
WHERE country='Canada'
ORDER BY name_0, name_1
LIMIT 12;

SELECT DISTINCT misc
gid_0, name_0, gid_1, hasc_1, name_1, engtype_1, country, state_province
FROM gadm
WHERE country='Mexico'
ORDER BY name_0, name_1
LIMIT 12;

SELECT DISTINCT 
gid_0, name_0, gid_1, hasc_1, name_1, engtype_1, country, state_province
FROM gadm
WHERE country='United States'
ORDER BY name_0, name_1
LIMIT 12;

\c geonames

SELECT DISTINCT a.geonameid,  
a.country AS countrycode_iso2,  ctry.name AS country, a.cc2,  
b.name, b.nameascii, a.name as fullname,  a.asciiname as fullnameascii,  a.admin1, c.admin1code as admin1code, c.admin1code_full, b.code AS admin1code_full_numeric 
FROM geoname a LEFT JOIN  ( SELECT DISTINCT country, name FROM geoname WHERE  fclass='A' AND fcode='PCLI' ) ctry 
ON a.country=ctry.country 
LEFT JOIN admin1codesascii b 
ON a.geonameid=b.geonameid 
LEFT JOIN postalcodes c 
ON b.name=c.admin1name where a.fclass='A' AND a.fcode='ADM1' 
ORDER BY a.country, b.nameascii





