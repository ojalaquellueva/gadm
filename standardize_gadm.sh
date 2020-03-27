#!/bin/bash

#########################################################################
# Purpose: Standardize GADM political division names
#  
# Standardizes GADM political division names according to Geonames 
# 	(www.geonames.org) using the Geographic Name Resolution Service
#	(GNRS, https://github.com/ojalaquellueva/gnrs.git)
#
# Author: Brad Boyle (bboyle@email.arizona.edu)
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo; echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set parameters, load functions & confirm operation
# 
# Loads local parameters only if called by master script.
# Otherwise loads all parameters, functions and options
######################################################

######################################################
# Set parameters, functions and options
######################################################

# Enable the following for strict debugging only:
#set -e

# The name of this file. Tells sourced scripts not to reload general  
# parameters and command line options as they are being called by  
# another script. Allows component scripts to be called individually  
# if needed
master=`basename "$0"`

# Get working directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Set includes directory path, relative to $DIR
includes_dir=$DIR"/includes"

# Load parameters, functions and get command-line options
source "$includes_dir/startup_master.sh"

# Confirm operation
source "$includes_dir/confirm.sh"

# Adjust data directory if needed
data_dir=$DATA_BASE_DIR

#########################################################################
# Main
#########################################################################

######################################################
# Extract political divisions and export for scrubbing
######################################################

echoi $e -n "- Altering table gadm..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q 	-f $DIR/sql/alter_gadm.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Extracting  verbatim political divisions to table 'gadm_poldivs'..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/sql/prepare_poldivs.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Exporting CSV file of political divisions for scrubbing by GNRS..."
sql="\copy (select distinct '' as user_id, country, state_province, county_parish from gadm_poldivs ) to ${GNRS_DATA_DIR}/gnrs_submitted.csv CSV HEADER"
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
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/index_gadm.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Dropping temporary tables..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/drop_temp_tables.sql
source "$DIR/includes/check_status.sh"	

#########################################################################
# Creating world geom poldiv tables, for quick filtering
#########################################################################

echoi $e -n "- Creating lookup tables of gadm political divisions..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gadm_poldiv_tables.sql
source "$DIR/includes/check_status.sh"	

######################################################
# Report total elapsed time and exit
######################################################

source "$includes_dir/finish.sh"