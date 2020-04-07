#!/bin/bash

#########################################################################
# Standardize GADM political division names
#  
# Purpose:
#	Standardize GADM political division names according to Geonames 
# 	(www.geonames.org) using the Geographic Name Resolution Service
#	(GNRS). Standardized
#	names are added as new columns to table gadm. Original GADM
# 	names are not changed.
#
# Notes:
#	* NOT standalone! MUST be called by master script gadm.sh
#	* Won't work if you do not have local installation of command-
#		line GNRS (https://github.com/ojalaquellueva/gnrs.git)
#	* Optional. You can still build the basic GADM database without
#		this step. To turn off, set STANDARDIZE_POLDIV_NAMES="f" in
#		params.sh.
#
# Author: Brad Boyle (bboyle@email.arizona.edu)
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo; echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Extract political divisions and export for scrubbing
######################################################

echoi $e -n "- Altering table gadm..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q 	-f $DIR/sql/alter_gadm.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Extracting  verbatim political divisions to table 'gadm_poldivs_raw'..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/sql/prepare_poldivs.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Exporting CSV file of political divisions for scrubbing by GNRS..."
sql="\copy (select distinct '' as user_id, country, state_province, county_parish from gadm_poldivs_raw ) to ${GNRS_DATA_DIR}/gnrs_submitted.csv CSV HEADER"
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -c "$sql"
source "$DIR/includes/check_status.sh"

#########################################################################
# Validate political divisions
#########################################################################

# Back up current value of $DIR, process name and echo settings
# As these will be reset by validation app
DIR_BAK=$DIR		
pname_bak=$pname
e_bak=$e
i_bak=$i
prev_bak=$prev

echoi $e -n "- Scrubbing political divisions with GNRS..."
e=""; i=""	# Turn off application screen echo
source $GNRS_DIR"/gnrs_import.sh" -s -n	# Import data to GNRS db
source $GNRS_DIR"/gnrs.sh" -s			# Process poldivs with GNRS
source $GNRS_DIR"/gnrs_export.sh" -s		# Export GNRS results

# Restore settings
DIR=$DIR_BAK
pname=$pname_bak
e=$e_bak
i=$i_bak
prev=$prev_bak

source "$DIR/includes/check_status.sh"	

#########################################################################
# Import GNRS results 
#########################################################################

# Reset local directory
DIR="${BASH_SOURCE%/*}"

echoi $e -n "- Creating GNRS results table \"gadm_gnrs\"..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gadm_gnrs.sql
source "$DIR/includes/check_status.sh"	

echoi $i -n "- Importing GNRS validation results..."
sql="\COPY gadm_gnrs FROM '${GNRS_DATA_DIR}/gnrs_results.csv' DELIMITER ',' CSV HEADER;"
PGOPTIONS='--client-min-messages=warning' psql gadm $user -q -c "$sql"
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Indexing \"gadm_gnrs\"..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/index_gadm_gnrs.sql
source "$DIR/includes/check_status.sh"	

#########################################################################
# Update GNRS results columns in original tables
#########################################################################

echoi $e -n "- Updating political division columns in table \"gadm\"..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/update_gadm.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Indexing \"gadm\"..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gnrs_indexes.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Dropping temporary tables..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/drop_temp_tables.sql
source "$DIR/includes/check_status.sh"	

#########################################################################
# Creating world geom poldiv tables, for quick filtering
#########################################################################

#echoi $e -n "- Creating lookup tables of gadm political divisions..."
#PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gadm_poldiv_tables.sql
#source "$DIR/includes/check_status.sh"	
