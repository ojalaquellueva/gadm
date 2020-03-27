-- ---------------------------------------------------------
-- Index GNRS results table 
-- ---------------------------------------------------------

-- Populate user_id as well
UPDATE gadm_gnrs
SET user_id=poldiv_full
;

DROP INDEX IF EXISTS gadm_gnrs_poldiv_full_idx;
DROP INDEX IF EXISTS gadm_gnrs_country_verbatim_idx;
DROP INDEX IF EXISTS gadm_gnrs_state_province_verbatim_idx;
DROP INDEX IF EXISTS gadm_gnrs_county_parish_verbatim_idx;
DROP INDEX IF EXISTS gadm_gnrs_country_idx;
DROP INDEX IF EXISTS gadm_gnrs_state_province_idx;
DROP INDEX IF EXISTS gadm_gnrs_county_parish_idx;
DROP INDEX IF EXISTS gadm_gnrs_match_method_state_province_idx;
DROP INDEX IF EXISTS gadm_gnrs_match_method_county_parish_idx;
DROP INDEX IF EXISTS gadm_gnrs_poldiv_submitted_idx;
DROP INDEX IF EXISTS gadm_gnrs_poldiv_matched_idx;
DROP INDEX IF EXISTS gadm_gnrs_match_status_idx;
DROP INDEX IF EXISTS gadm_gnrs_user_id_idx;


CREATE INDEX  gadm_gnrs_poldiv_full_idx ON gadm_gnrs (poldiv_full);
CREATE INDEX  gadm_gnrs_country_verbatim_idx ON gadm_gnrs (country_verbatim);
CREATE INDEX  gadm_gnrs_state_province_verbatim_idx ON gadm_gnrs (state_province_verbatim);
CREATE INDEX  gadm_gnrs_county_parish_verbatim_idx ON gadm_gnrs (county_parish_verbatim);
CREATE INDEX  gadm_gnrs_country_idx ON gadm_gnrs (country);
CREATE INDEX  gadm_gnrs_state_province_idx ON gadm_gnrs (state_province);
CREATE INDEX  gadm_gnrs_county_parish_idx ON gadm_gnrs (county_parish);
CREATE INDEX  gadm_gnrs_match_method_state_province_idx ON gadm_gnrs (match_method_state_province);
CREATE INDEX  gadm_gnrs_match_method_county_parish_idx ON gadm_gnrs (match_method_county_parish);
CREATE INDEX  gadm_gnrs_poldiv_submitted_idx ON gadm_gnrs (poldiv_submitted);
CREATE INDEX  gadm_gnrs_poldiv_matched_idx ON gadm_gnrs (poldiv_matched);
CREATE INDEX  gadm_gnrs_match_status_idx ON gadm_gnrs (match_status);
CREATE INDEX  gadm_gnrs_user_id_idx ON gadm_gnrs (user_id);
