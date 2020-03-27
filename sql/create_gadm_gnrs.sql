-- ---------------------------------------------------------
-- Create table for storing GNRS validation results
--
-- Exact copy of table user_data in db gnrs
-- ---------------------------------------------------------

DROP TABLE IF EXISTS gadm_gnrs;
CREATE TABLE gadm_gnrs (
id BIGINT NOT NULL PRIMARY KEY,
poldiv_full text DEFAULT NULL,
country_verbatim text DEFAULT '',
state_province_verbatim text DEFAULT '',
county_parish_verbatim text DEFAULT '',
country VARCHAR(250) DEFAULT NULL,
state_province VARCHAR(250) DEFAULT NULL,
county_parish VARCHAR(250) DEFAULT NULL,
country_id INTEGER DEFAULT NULL,
state_province_id INTEGER DEFAULT NULL,
county_parish_id INTEGER DEFAULT NULL,
match_method_country VARCHAR(50) DEFAULT NULL,
match_method_state_province VARCHAR(50) DEFAULT NULL,
match_method_county_parish VARCHAR(50) DEFAULT NULL,
match_score_country NUMERIC(4,2) DEFAULT NULL,
match_score_state_province NUMERIC(4,2) DEFAULT NULL,
match_score_county_parish NUMERIC(4,2) DEFAULT NULL,
poldiv_submitted VARCHAR(50) DEFAULT NULL, 
poldiv_matched VARCHAR(50) DEFAULT NULL,
match_status VARCHAR(50) DEFAULT NULL,
user_id text DEFAULT NULL,
job text DEFAULT NULL,
country_iso text DEFAULT NULL,
state_province_iso text DEFAULT NULL,
county_parish_iso text DEFAULT NULL
)  
;
