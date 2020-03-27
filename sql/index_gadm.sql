-- ---------------------------------------------------------
-- Index verbatim & scrubbed political division columns 
-- Re-index geom field, including not null filter
-- ---------------------------------------------------------

DROP INDEX IF EXISTS gadm_country_verbatim_idx;
CREATE INDEX gadm_country_verbatim_idx ON gadm (country_verbatim);

DROP INDEX IF EXISTS gadm_state_province_verbatim_idx;
CREATE INDEX gadm_state_province_verbatim_idx ON gadm (state_province_verbatim);

DROP INDEX IF EXISTS gadm_county_verbatim_idx;
CREATE INDEX gadm_county_verbatim_idx ON gadm (county_verbatim);

DROP INDEX IF EXISTS gadm_country_idx;
CREATE INDEX gadm_country_idx ON gadm (country);

DROP INDEX IF EXISTS gadm_state_province_idx;
CREATE INDEX gadm_state_province_idx ON gadm (state_province);

DROP INDEX IF EXISTS gadm_county_idx;
CREATE INDEX gadm_county_idx ON gadm (county);

DROP INDEX IF EXISTS gadm_match_status_idx;
CREATE INDEX gadm_match_status_idx ON gadm (match_status);

DROP INDEX IF EXISTS gadm_wkb_geometry_idx;
CREATE INDEX gadm_wkb_geometry_idx ON gadm USING gist (wkb_geometry) WHERE wkb_geometry IS NOT NULL;
