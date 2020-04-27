-- -------------------------------------------------------------------
-- Creates & populates metadata table
--
-- Required parameters:
-- 	$VERSION
-- 	$URL_DB_DATA
-- 	$DB_DATA_VERSION
-- 	$download_timestamp
-- -------------------------------------------------------------------

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (
version text,
data_uri text,
data_version text,
date_accessed timestamp
);

INSERT INTO meta (
version,
data_uri, 
data_version, 
date_accessed
)
VALUES (
:'VERSION', 
:'URL_DB_DATA', 
:'DB_DATA_VERSION', 
:'download_timestamp'
);