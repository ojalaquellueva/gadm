#!/bin/bash

#########################################################################
# Purpose: Prepares for political division scrubbing within BIEN database  
#	by importing reference table world_geom from previous production  
#	version of BIEN db, & populating columns of political division names  
# 	standardized using the GNRS
#  
# Note: This script and pdg_2_scrub.sh are provision solutions only. To be
# 	replaced by single scripts, pdg.sh, which will use standalone pdg  
#	scripts in separate repository and external pdg reference database.
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

# Get local working directory
DIR_LOCAL="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR_LOCAL" ]]; then DIR_LOCAL="$PWD"; fi

# $local = name of this file
# $local_basename = name of this file minus ='.sh' extension
# $local_basename should be same as containing directory, as  
# well as local data subdirectory within main data directory, 
# if local data directory needed
local=`basename "${BASH_SOURCE[0]}"`
local_basename="${local/.sh/}"

# Set parent directory if running independently & suppress main message
if [ -z ${master+x} ]; then
	DIR=$DIR_LOCAL"/.."
	suppress_main='true'
else
	suppress_main='false'
fi

# Load startup script for local files
# Sets remaining parameters and options, and issues confirmation
# and startup messages
source "$DIR/includes/startup_local.sh"	

# Construct LIMIT clause if applicable (for testing only)
sql_limit_local=""
if [ $use_limit_local == "true" ]; then
	if  [ $use_limit == "false" ] && [ $force_limit == "true" ]; then
		sql_limit_local=""
	else
		sql_limit_local=$sql_limit_global
	fi
fi

######################################################
# Custom confirmation message. 
# Will only be displayed if running as
# standalone script and -s (silent) option not used.
######################################################

if [[ "$i" = "true" && -z ${master+x} ]]; then 

	# Record limit display
	if [[ "$sql_limit_local" == "" ]]; then
		limit_disp="false"
	else 
		limit_disp="true (limit="$recordlimit")"
	fi

	# Reset confirmation message
	msg_conf="$(cat <<-EOF

	Process '$pname' will use following parameters: 
	
	Database:				$db_private
	Schema:					$dev_schema
	Source schema for table 
		world geom:			$src_schema
	GNRS data dir:			$gnrs_data_dir
	GNRS app dir:			$gnrs_dir
	GNRS submitted file:		$gnrs_submitted_filename
	GNRS results file:		$gnrs_results_filename
	Use record limit?		$limit_disp
	
EOF
	)"		
	confirm "$msg_conf"
fi

#########################################################################
# Main
#########################################################################

echoi $e "Executing module '$local_basename'"

######################################################
# Extract political divisions and export for scrubbing
######################################################

echoi $e -n "- Importing existing table world_geom from schema '$src_schema'..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v src_schema=$src_schema -v limit="$sql_limit_local" -f $DIR_LOCAL/sql/copy_world_geom.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Altering table world_geom..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/alter_world_geom.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Extracting  verbatim political divisions to table $tbl_poldivs..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/prepare_poldivs.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Exporting CSV file of political divisions for scrubbing by GNRS..."
sql="\copy (select distinct '' as user_id, country, state_province, county_parish from world_geom_poldivs ) to ${gnrs_data_dir}/${gnrs_submitted_filename} csv header"
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private -q << EOF
\set ON_ERROR_STOP on
SET search_path TO $dev_schema;
$sql
EOF
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
source $gnrs_dir"/gnrs_import.sh" -s -n	# Import data to GNRS db
source $gnrs_dir"/gnrs.sh" -s			# Process poldivs with GNRS
source $gnrs_dir"/gnrs_export.sh" -s		# Export GNRS results

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
DIR_LOCAL="${BASH_SOURCE%/*}"

echoi $e -n "- Creating GNRS results table \"world_geom_gnrs\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/create_world_geom_gnrs.sql
source "$DIR/includes/check_status.sh"	

echoi $i -n "- Importing GNRS validation results..."
sql="\COPY world_geom_gnrs FROM '${gnrs_data_dir}/${gnrs_results_filename}' DELIMITER ',' CSV HEADER;"
PGOPTIONS='--client-min-messages=warning' psql $db_private $user -q << EOF
\set ON_ERROR_STOP on
SET search_path TO $dev_schema;
$sql
EOF
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Indexing \"world_geom_gnrs\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/index_world_geom_gnrs.sql
source "$DIR/includes/check_status.sh"	

#########################################################################
# Update GNRS results columns in original tables
#########################################################################

echoi $e -n "- Updating political division columns in table \"world_geom\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/update_world_geom.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Indexing \"world_geom\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/index_world_geom.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Dropping temporary tables..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/pdg_1_drop_tables.sql
source "$DIR/includes/check_status.sh"	

#########################################################################
# Creating world geom poldiv tables, for quick filtering
#########################################################################

echoi $e -n "- Creating lookup tables of world_geom political divisions..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/create_world_geom_poldiv_tables.sql
source "$DIR/includes/check_status.sh"	

######################################################
# Report total elapsed time and exit if running solo
######################################################

if [ -z ${master+x} ]; then source "$DIR/includes/finish.sh"; fi