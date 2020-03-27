-- ----------------------------------------------------------------
-- Create tables on political division names only, for quick filtering
-- ----------------------------------------------------------------

DROP TABLE IF EXISTS gadm_county;
CREATE TABLE gadm_county AS
SELECT DISTINCT country, state_province, county
FROM gadm
WHERE country IS NOT NULL
AND state_province IS NOT NULL
AND county IS NOT NULL
;
CREATE UNIQUE INDEX ON gadm_county (country, state_province, county);

DROP TABLE IF EXISTS gadm_state;
CREATE TABLE gadm_state AS
SELECT DISTINCT country, state_province
FROM gadm
WHERE country IS NOT NULL
AND state_province IS NOT NULL
;
CREATE UNIQUE INDEX ON gadm_state (country, state_province);

DROP TABLE IF EXISTS gadm_country;
CREATE TABLE gadm_country AS
SELECT DISTINCT country
FROM gadm
WHERE country IS NOT NULL
;
CREATE UNIQUE INDEX ON gadm_country (country);
