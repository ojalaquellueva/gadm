#!/bin/bash

#########################################################################
# Standardize GADM political division names using Natural Earth ISO-HASC
# code crosswalk table
#  
# Notes:
#	* NOT standalone! MUST be called by master script gadm.sh
#	* Won't work if you do not have local installation of command-
#		line GNRS (https://github.com/ojalaquellueva/gnrs.git)
#	* Optional. You can still build the basic GADM database without
#		this step. To turn off, set STANDARDIZE_NE="f" in
#		params.sh.
#
# Author: Brad Boyle (bboyle@email.arizona.edu)
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo; echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

############################################
# Import geonames tables
#
# Tables country, state_province and 
# county_parish are produced by GNRS. Must
# have local GNRS installation for this
# to run
############################################

echoi $e "Importing tables from DB $DB_GEONAMES to DB $DB_GADM:"

echoi $e -n "- Dropping previous tables, if any..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB_GADM -q -c "DROP TABLE IF EXISTS geoname, admin1codesascii, admin2codesascii, postalcodes, country, state_province, county_parish, geonames_country, geonames_admin_1, geonames_admin_2, geonames_state_province, geonames_county_parish"
source "$DIR/includes/check_status.sh"	

# Dump table from source databse
# --clean (-c) option replaces existing objects if they already exist
echoi $e -n "- Creating dumpfile..."
dumpfile="/tmp/gnrs_extract_for_gadm.sql"
sudo -u postgres pg_dump --no-owner -t geoname -t admin1codesascii -t admin2codesascii -t postalcodes -t country -t state_province -t county_parish "$DB_GEONAMES" > $dumpfile
source "$includes_dir/check_status.sh"	

# Import table from dumpfile to target db & schema
echoi $e -n "- Importing tables from dumpfile..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 $DB_GADM < $dumpfile > /dev/null > /tmp/templog
source "$includes_dir/check_status.sh"	

echoi $e -n "- Renaming geonames derived tables..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql $DB_GADM --set ON_ERROR_STOP=1 -q <<EOT
ALTER TABLE country RENAME TO geonames_country;
ALTER TABLE state_province RENAME TO geonames_state_province;
ALTER TABLE county_parish RENAME TO geonames_county_parish;
EOT
source "$includes_dir/check_status.sh"

echoi $e -n "- Removing dumpfile..."
rm $dumpfile
source "$includes_dir/check_status.sh"	

######################################################
# Import & unpack Natural Earth iso/hasc code crosswalk
######################################################

echoi $e "Importing ISO/HASC code crosswalk table:"

# Set date/time of access
download_timestamp=$(date '+%F_%H:%M:%S')

# Make subdirectory to hold contents of download 
data_dir_crosswalk=${data_dir}/crosswalk
mkdir -p $data_dir_crosswalk

# Import directly from source if requested
# If this option not used, you MUST manually download the archive,
# extract the dbf file to utf-8 csv, and place it in the crosswalk
# data directory

if [ "$DOWNLOAD_CROSSWALK" == "t" ]; then
	echoi $e -n "- Downloading ${ARCHIVE_ADM1_CROSSWALK} to $data_dir_crosswalk..."
	rm -f ${data_dir_crosswalk}/${ARCHIVE_ADM1_CROSSWALK}
	wget -q $URL_ADM1_CROSSWALK -P $data_dir_crosswalk
	source "$includes_dir/check_status.sh"  

	echoi $e -n "- Unzipping archive..."
	unzip -o -q "${data_dir_crosswalk}/${ARCHIVE_ADM1_CROSSWALK}" -d $data_dir_crosswalk
	source "$includes_dir/check_status.sh"  

	# WARNING: not yet working properly!!!
	# Currently Postgres copy command throws the following error:
	# ERROR:  invalid byte sequence for encoding "UTF8": 0x00
	echoi $e -n "- Converting dbf file to CSV..."
	php "$DIR"/php/dbfToCsv.php "${data_dir_crosswalk}/${DBF_ADM1_CROSSWALK}"
	source "$includes_dir/check_status.sh"  
fi

echoi $e -n "- Creating tables..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q 	-f $DIR/sql/create_admin1_crosswalk_raw.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Inserting data from file '${CSV_ADM1_CROSSWALK}'..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql $DB_GADM --set ON_ERROR_STOP=1 -q <<EOT
copy admin1_crosswalk_raw from '${data_dir_crosswalk}/${CSV_ADM1_CROSSWALK}' CSV HEADER;
EOT
source "$includes_dir/check_status.sh"

echoi $e "- Trimming whitespace from all columns in admin1_crosswalk_raw:"
echoi $e -n "-- Generating SQL..."
echo $(PGOPTIONS='--client-min-messages=warning' psql -d gadm -qt -c "SELECT 'UPDATE '||quote_ident(c.table_name)||' SET '||c.COLUMN_NAME||'=TRIM('||quote_ident(c.COLUMN_NAME)||');' as sql_stmt FROM (SELECT table_name,COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name='admin1_crosswalk_raw' AND (data_type='text' or data_type='character varying') ) AS c
")  >> sql/admin1_crosswalk_raw_trim_ws.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "-- Executing SQL..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/admin1_crosswalk_raw_trim_ws.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Inserting data to table admin1_crosswalk..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_admin1_crosswalk.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Altering table admin1_crosswalk..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/admin1_crosswalk_alter.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Dropping table admin1_crosswalk_raw..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -c "DROP TABLE IF EXISTS admin1_crosswalk_raw"
source "$DIR/includes/check_status.sh"

COMMENT_BLOCK_10

######################################################
# Index gadm political divisions with geonames IDs
######################################################

echoi $e "Linking gadm political divisions to geonames:"

echoi $e -n "- Countries..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/gadm_geonames_index_country.sql 
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Admin 1..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/gadm_geonames_index_admin_1.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "- Admin 2..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/gadm_geonames_index_admin_2.sql
source "$DIR/includes/check_status.sh"

######################################################
# Add missing gadm names to gnrs-geonames tables
######################################################

echoi $e "Adding new gadm political divisions to gnrs/geonames tables:"

echoi $e -n "- Countries..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/geonames_add_gadm_country.sql > /dev/null
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Admin 1..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/geonames_add_gadm_admin_1.sql > /dev/null
source "$DIR/includes/check_status.sh"

echoi $e -n "- Admin 2..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $APP_DIR/sql/geonames_add_gadm_admin_2.sql > /dev/null
source "$DIR/includes/check_status.sh"
