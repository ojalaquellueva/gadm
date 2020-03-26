-- -------------------------------------------------------------------
-- Creates & populates metadata table
--
-- Required parameters:
-- 	$URL_DB_DATA
-- 	$DB_DATA_VERSION
-- 	$downloaded
-- -------------------------------------------------------------------

DROP TABLE IF EXISTS metadata;
CREATE TABLE metadata (
data_uri text,
data_version text,
date_accessed timestamp
);

INSERT INTO metadata (
data_uri, 
data_version, 
date_accessed
)
VALUES (
:'URL_DB_DATA', 
:'DB_DATA_VERSION', 
:'downloaded'
);