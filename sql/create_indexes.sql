-- -------------------------------------------------------------------
-- Indexes table gadm
-- -------------------------------------------------------------------

DROP INDEX IF EXISTS gadm_fid_idx;
DROP INDEX IF EXISTS gadm_uid_idx;
DROP INDEX IF EXISTS gadm_gid_0_idx;
DROP INDEX IF EXISTS gadm_gid_1_idx;
DROP INDEX IF EXISTS gadm_gid_2_idx;
DROP INDEX IF EXISTS gadm_gid_3_idx;
DROP INDEX IF EXISTS gadm_name_0_idx;
DROP INDEX IF EXISTS gadm_name_1_idx;
DROP INDEX IF EXISTS gadm_name_2_idx;
DROP INDEX IF EXISTS gadm_name_3_idx;
DROP INDEX IF EXISTS gadm_hasc_1_idx;
DROP INDEX IF EXISTS gadm_hasc_2_idx;
DROP INDEX IF EXISTS gadm_hasc_3_idx;
DROP INDEX IF EXISTS gadm_type_1_idx;
DROP INDEX IF EXISTS gadm_type_2_idx;
DROP INDEX IF EXISTS gadm_type_3_idx;
DROP INDEX IF EXISTS gadm_engtype_1_idx;
DROP INDEX IF EXISTS gadm_engtype_2_idx;
DROP INDEX IF EXISTS gadm_engtype_3_idx;
DROP INDEX IF EXISTS gadm_wkb_geometry_idx;
DROP INDEX IF EXISTS gadm_wkb_geometry_geom_idx;
DROP INDEX IF EXISTS gadm_geom_idx;
DROP INDEX IF EXISTS gadm_geog_idx;

CREATE INDEX gadm_fid_idx ON gadm USING BTREE (fid);
CREATE INDEX gadm_uid_idx ON gadm USING BTREE (uid);
CREATE INDEX gadm_gid_0_idx ON gadm USING BTREE (gid_0);
CREATE INDEX gadm_gid_1_idx ON gadm USING BTREE (gid_1);
CREATE INDEX gadm_gid_2_idx ON gadm USING BTREE (gid_2);
CREATE INDEX gadm_gid_3_idx ON gadm USING BTREE (gid_3);
CREATE INDEX gadm_name_0_idx ON gadm USING BTREE (name_0);
CREATE INDEX gadm_name_1_idx ON gadm USING BTREE (name_1);
CREATE INDEX gadm_name_2_idx ON gadm USING BTREE (name_2);
CREATE INDEX gadm_name_3_idx ON gadm USING BTREE (name_3);
CREATE INDEX gadm_hasc_1_idx ON gadm USING BTREE (hasc_1);
CREATE INDEX gadm_hasc_2_idx ON gadm USING BTREE (hasc_2);
CREATE INDEX gadm_hasc_3_idx ON gadm USING BTREE (hasc_3);
CREATE INDEX gadm_type_1_idx ON gadm USING BTREE (type_1);
CREATE INDEX gadm_type_2_idx ON gadm USING BTREE (type_2);
CREATE INDEX gadm_type_3_idx ON gadm USING BTREE (type_3);
CREATE INDEX gadm_engtype_1_idx ON gadm USING BTREE (engtype_1);
CREATE INDEX gadm_engtype_2_idx ON gadm USING BTREE (engtype_2);
CREATE INDEX gadm_engtype_3_idx ON gadm USING BTREE (engtype_3);
CREATE INDEX gadm_wkb_geometry_idx ON gadm USING GIST (wkb_geometry);
CREATE INDEX gadm_geom_idx ON gadm USING GIST (geom);
CREATE INDEX gadm_geog_idx ON gadm USING GIST (geog);
