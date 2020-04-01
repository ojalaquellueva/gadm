-- ----------------------------------------------------------------
-- Create tables of verbatim GADM political division names
-- ----------------------------------------------------------------

DROP TABLE IF EXISTS gadm_country;
CREATE TABLE gadm_country AS
SELECT DISTINCT 
gid_0 AS iso_3,
name_0 as country
FROM gadm
WHERE name_0 IS NOT NULL
ORDER BY name_0
;
CREATE UNIQUE INDEX ON gadm_country (iso_3);
CREATE UNIQUE INDEX ON gadm_country (country);

DROP TABLE IF EXISTS gadm_state;
CREATE TABLE gadm_state AS
SELECT DISTINCT 
gid_0 AS iso_3,
name_0 as country, 
gid_1,
hasc_1,
name_1 as state_province
FROM gadm
WHERE name_0 IS NOT NULL
AND name_1 IS NOT NULL
ORDER BY name_0, name_1 NULLS FIRST
;
CREATE INDEX ON gadm_state (iso_3);
CREATE INDEX ON gadm_state (country);
CREATE UNIQUE INDEX ON gadm_state (country, state_province);
CREATE UNIQUE INDEX ON gadm_state (gid_1);
CREATE INDEX ON gadm_state (hasc_1); -- Not unique

DROP TABLE IF EXISTS gadm_county;
CREATE TABLE gadm_county AS
SELECT DISTINCT 
gid_0 AS iso_3,
name_0 as country, 
gid_1,
hasc_1,
name_1 as state_province,
gid_2,
hasc_2,
name_2 as county
FROM gadm
WHERE name_0 IS NOT NULL
AND name_1 IS NOT NULL
AND name_2 IS NOT NULL
ORDER BY name_0, name_1, name_2 NULLS FIRST
;
CREATE INDEX ON gadm_county (iso_3);
CREATE INDEX ON gadm_county (country);
CREATE INDEX ON gadm_county (gid_1);
CREATE INDEX ON gadm_county (hasc_1);
CREATE INDEX ON gadm_county (country, state_province);
CREATE UNIQUE INDEX ON gadm_county (country, state_province, county);
CREATE INDEX ON gadm_county (gid_1); -- Not unique
CREATE INDEX ON gadm_county (hasc_2); -- Not unique

DROP TABLE IF EXISTS gadm_poldivs;
CREATE TABLE gadm_poldivs AS
SELECT DISTINCT 
gid_0 AS iso_3,
name_0 as country, 
gid_1,
hasc_1,
name_1 as state_province,
gid_2,
hasc_2,
name_2 as county
FROM gadm
ORDER BY name_0, name_1, name_2 NULLS FIRST
;
CREATE INDEX ON gadm_poldivs (country);
CREATE INDEX ON gadm_poldivs (country, state_province);
CREATE INDEX ON gadm_poldivs (country, state_province, county);

