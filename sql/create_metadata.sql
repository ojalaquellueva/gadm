-- -------------------------------------------------------------------
-- Creates & populates metadata table
--
-- Required parameters:
-- 	$VERSION
-- 	$URL_DB_DATA
-- 	$DB_DATA_VERSION
-- 	$download_timestamp
-- -------------------------------------------------------------------

DROP TABLE IF EXISTS metadata;
CREATE TABLE metadata (
version text,
data_uri text,
data_version text,
date_accessed timestamp
);

INSERT INTO metadata (
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