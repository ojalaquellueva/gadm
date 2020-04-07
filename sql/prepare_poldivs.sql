-- ---------------------------------------------------------
-- Extract table of all unique political divisions from
-- ppg spatial reference table gadm
-- ---------------------------------------------------------

DROP TABLE IF EXISTS gadm_poldivs_raw;
CREATE TABLE gadm_poldivs_raw (
poldiv_full TEXT DEFAULT '',
country TEXT DEFAULT '',
state_province TEXT DEFAULT '',
county_parish TEXT DEFAULT ''
);

INSERT INTO gadm_poldivs_raw (
poldiv_full,
country,
state_province,
county_parish
)
SELECT DISTINCT
poldiv_full,
country_verbatim,
state_province_verbatim,
county_verbatim
FROM gadm
;

-- Index FK
DROP INDEX IF EXISTS gadm_poldivs_raw_poldiv_full_idx;
CREATE INDEX gadm_poldivs_raw_poldiv_full_idx ON gadm_poldivs_raw (poldiv_full);