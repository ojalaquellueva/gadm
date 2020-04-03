-- -----------------------------------------------------------------
-- Additional spatial columns 
-- -----------------------------------------------------------------

-- This column is an exact copy of wkb_geometry
-- For backward-compatibility with tons of old code that 
-- references column "geom"
ALTER TABLE gadm ADD COLUMN geom geometry(MultiPolygon,4326);
UPDATE gadm SET geom=wkb_geometry;

-- Geography representation
ALTER TABLE gadm ADD COLUMN geog geography(MultiPolygon);
UPDATE gadm SET geog=ST_GeogFromWKB(wkb_geometry);
