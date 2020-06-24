-- ----------------------------------------------------------------
-- Create tables on GNRS political division names only, for quick filtering
-- ----------------------------------------------------------------

DROP TABLE IF EXISTS gnrs_poldivs;
CREATE TABLE gnrs_poldivs AS
SELECT DISTINCT 
gid_0 AS iso_3,
split_part(hasc_1,'.',1) as iso_2,
country, 
state_province, 
county,
COUNT(*) AS records
FROM gadm
GROUP BY gid_0, split_part(hasc_1,'.',1), country, state_province, county
ORDER BY country, state_province, county NULLS FIRST
;
CREATE INDEX ON gnrs_poldivs (country);
CREATE INDEX ON gnrs_poldivs (country, state_province);
CREATE INDEX ON gnrs_poldivs (country, state_province, county);

DROP TABLE IF EXISTS gnrs_county;
CREATE TABLE gnrs_county AS
SELECT DISTINCT country, state_province, county
FROM gadm
WHERE country IS NOT NULL
AND state_province IS NOT NULL
AND county IS NOT NULL
;
CREATE UNIQUE INDEX ON gnrs_county (country, state_province, county);

DROP TABLE IF EXISTS gnrs_state;
CREATE TABLE gnrs_state AS
SELECT DISTINCT country, state_province
FROM gadm
WHERE country IS NOT NULL
AND state_province IS NOT NULL
;
CREATE UNIQUE INDEX ON gnrs_state (country, state_province);

DROP TABLE IF EXISTS gnrs_country;
CREATE TABLE gnrs_country AS
SELECT DISTINCT country
FROM gadm
WHERE country IS NOT NULL
;
CREATE UNIQUE INDEX ON gnrs_country (country);
