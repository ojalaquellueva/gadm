-- ---------------------------------------------------------
-- Update starndard political division columns 
-- with results of GNRS validations
-- ---------------------------------------------------------

UPDATE gadm a
SET 
country=b.country,
state_province=b.state_province,
county=b.county_parish,
match_status=b.match_status
FROM gadm_gnrs b
WHERE a.poldiv_full=b.poldiv_full
;