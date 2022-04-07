-- ------------------------------------------------------------------
-- Create view gadm_nospatial
-- ------------------------------------------------------------------

-- Use this query to generate the SQL
-- Source: https://dba.stackexchange.com/a/1958/27964
-- Will need to remove trailing "+" before final FROM 
SELECT 'SELECT ' || array_to_string(ARRAY(SELECT 'o' || '.' || c.column_name
	FROM information_schema.columns As c
	WHERE table_name = 'gadm' 
	AND  c.column_name NOT IN('wkb_geometry', 'geom', 'geog')
	), ',') || ' 
FROM gadm As o' As sqlstmt
;

-- Final SQL
DROP VIEW IF EXISTS gadm_nospatial;
CREATE VIEW gadm_nospatial AS
SELECT o.fid,o.uid,o.gid_0,o.id_0,o.name_0,o.gid_1,o.id_1,o.name_1,o.varname_1,o.nl_name_1,o.hasc_1,o.cc_1,o.type_1,o.engtype_1,o.validfr_1,o.validto_1,o.remarks_1,o.gid_2,o.id_2,o.name_2,o.varname_2,o.nl_name_2,o.hasc_2,o.cc_2,o.type_2,o.engtype_2,o.validfr_2,o.validto_2,o.remarks_2,o.gid_3,o.id_3,o.name_3,o.varname_3,o.nl_name_3,o.hasc_3,o.cc_3,o.type_3,o.engtype_3,o.validfr_3,o.validto_3,o.remarks_3,o.gid_4,o.id_4,o.name_4,o.varname_4,o.cc_4,o.type_4,o.engtype_4,o.validfr_4,o.validto_4,o.remarks_4,o.gid_5,o.id_5,o.name_5,o.cc_5,o.type_5,o.engtype_5,o.region,o.varregion,o.zone,o.poldiv_full,o.country_verbatim,o.state_province_verbatim,o.county_verbatim,o.country,o.state_province,o.county,o.match_status
FROM gadm AS o
;

