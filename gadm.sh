#!/bin/bash

#########################################################################
# Purpose: Creates and populates GADM database 
#
# Authors: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 23 Mar 2020
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x
#echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set basic parameters, functions and options
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

# # Suppress default confirmation message, but start timer
# suppress_main='true'
# source "$includes_dir/confirm.sh"

# Adjust data directory if needed
data_dir=$DATA_BASE_DIR

######################################################
# Custom confirmation message. 
# Will only be displayed if -s (silent) option not used.
######################################################

# Admin user message
curr_user="$(whoami)"
user_admin_disp=$curr_user
if [[ "$USER_ADMIN" != "" ]]; then
	user_admin_disp="$USER_ADMIN"
fi

# Read-only user message
user_read_disp="[n/a]"
if [[ "$USER_READ" != "" ]]; then
	user_read_disp="$USER_READ"
fi

# GNRS messages
standardize_disp="No"
if [[ "$STANDARDIZE_POLDIV_NAMES" == "t" ]]; then
	standardize_disp="Yes"
fi
gnrs_dir_disp="[n/a]"
if [[ "$GNRS_DIR" != "" ]] && [[ "$STANDARDIZE_POLDIV_NAMES" == "t" ]]; then
	gnrs_dir_disp="$GNRS_DIR"
fi
gnrs_data_dir_disp="[n/a]"
if [[ "$GNRS_DATA_DIR" != "" ]] && [[ "$STANDARDIZE_POLDIV_NAMES" == "t" ]]; then
	gnrs_data_dir_disp="$GNRS_DATA_DIR"
fi

# Reset confirmation message
msg_conf="$(cat <<-EOF

Run process '$pname' using the following parameters: 

GADM source url:		$URL_DB_DATA
GADM archive:			$DB_DATA_ARCHIVE
GADM file:			$DB_DATA
GADM version:			$DB_DATA_VERSION
Data directory:			$DATA_BASE_DIR
Standardize poldiv names:	$standardize_disp
GNRS directory:			$gnrs_dir_disp
GNRS data directory:		$gnrs_data_dir_disp
Current user:			$curr_user
Admin user/db owner:		$user_admin_disp
Additional read-only user:	$user_read_disp

EOF
)"		
confirm "$msg_conf"

# Start time, send mail if requested and echo begin message
source "$includes_dir/start_process.sh"  

#########################################################################
# Main
#########################################################################

download_timestamp=$(date '+%F_%H:%M:%S')
: <<'COMMENT_BLOCK_1'

############################################
# Create database in admin role & reassign
# to principal non-admin user of database
############################################

# Run pointless command to trigger sudo password request, 
# needed below. Should remain in effect for all
# sudo commands in this script, regardless of sudo timeout
sudo pwd >/dev/null

# Check if db already exists
# Warn to drop manually. This is safer.
if psql -lqt | cut -d \| -f 1 | grep -qw "gadm"; then
	# Reset confirmation message
	msg="Database 'gadm' already exists! Please drop first."
	echo $msg; exit 1
fi

echoi $e -n "Creating database 'gadm'..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "CREATE DATABASE gadm" 
source "$includes_dir/check_status.sh"  

echoi $e "Installing extensions:"

# POSTGIS
echoi $e -n "- postgis..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -d gadm -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS postgis;
CREATE EXTENSION postgis;
EOF
echoi $i "done"

############################################
# Download GADM data to data directory
############################################

echoi $e "Downloading GADM data:"

# Set date/time of access
download_timestamp=$(date '+%F_%H:%M:%S')

echoi $e -n "- Downloading to $data_dir..."
rm -f ${data_dir}/${DB_DATA_ARCHIVE}
wget -q $URL_DB_DATA -P $data_dir
source "$includes_dir/check_status.sh"  

echoi $e -n "- Unzipping..."
unzip -o -q ${data_dir}/${DB_DATA_ARCHIVE} -d $data_dir
source "$includes_dir/check_status.sh"  

############################################
# Import the data
############################################

echoi $e -n "Importing GADM data..."
# Note: add option "-lco LAUNDER=NO" to end to maintain case
ogr2ogr -f PostgreSQL "PG:dbname=gadm" "${data_dir}/${DB_DATA}"
source "$includes_dir/check_status.sh"  

echoi $e -n "Removing GADM data file (keeping compressed version)..."
rm -f ${data_dir}/${DB_DATA}
source "$includes_dir/check_status.sh"  

############################################
# Add additional spatial columns
############################################

echoi $e -n "Adding spatial columns geom and geog..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -f $DIR/sql/add_spatial_columns.sql
source "$includes_dir/check_status.sh"

############################################
# Create metadata table
############################################

echoi $e -n "Creating metadata table..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -v VERSION="$VERSION" -v URL_DB_DATA="$URL_DB_DATA" -v DB_DATA_VERSION="$DB_DATA_VERSION" -v download_timestamp="$download_timestamp" -f $DIR/sql/create_metadata.sql
source "$includes_dir/check_status.sh"

############################################
# Standardize poldiv names using GNRS if
# requested. See separate script.
############################################

if [ "$STANDARDIZE_POLDIV_NAMES" == "t" ]; then
	source "${DIR}/standardize_poldiv_names.sh"
fi


COMMENT_BLOCK_1


#########################################################################
# Creating world geom poldiv tables, for quick filtering
#########################################################################

echoi $e -n "- Creating lookup tables of gadm political divisions..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gadm_poldiv_tables.sql
source "$DIR/includes/check_status.sh"	

echoi $e -n "- Creating lookup tables of gnrs political divisions..."
PGOPTIONS='--client-min-messages=warning' psql -d gadm --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gnrs_poldiv_tables.sql
source "$DIR/includes/check_status.sh"	

############################################
# Alter ownership and permissions
############################################

if [ "$USER_ADMIN" != "" ]; then
	echoi $e "Changing database ownership and permissions:"

	echoi $e -n "- Changing DB owner to '$USER_ADMIN'..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "ALTER DATABASE gadm OWNER TO $USER_ADMIN" 
	source "$includes_dir/check_status.sh"  

	echoi $e -n "- Granting permissions..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q <<EOF
	\set ON_ERROR_STOP on
	REVOKE CONNECT ON DATABASE gadm FROM PUBLIC;
	GRANT CONNECT ON DATABASE gadm TO $USER_ADMIN;
	GRANT ALL PRIVILEGES ON DATABASE gadm TO $USER_ADMIN;
EOF
	echoi $i "done"

	echoi $e "- Transferring ownership of non-postgis relations to user '$USER_ADMIN':"
	# Note: views not changed as all at this point are postgis relations

	echoi $e -n "-- Tables..."
	for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname='public' and tableowner<>'postgres';" gadm` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter table \"$tbl\" owner to $USER_ADMIN" gadm ; done
	source "$includes_dir/check_status.sh"  

	echoi $e -n "-- Sequences..."
	for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" gadm` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter sequence \"$tbl\" owner to $USER_ADMIN" gadm ; done
	source "$includes_dir/check_status.sh"  
fi

if [[ ! "$USER_READ" == "" ]]; then
	echoi $e -n "- Granting read access to \"$USER_READ\"..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q <<EOF
	\set ON_ERROR_STOP on
	REVOKE CONNECT ON DATABASE gadm FROM PUBLIC;
	GRANT CONNECT ON DATABASE gadm TO $USER_READ;
	\c gadm
	GRANT USAGE ON SCHEMA public TO $USER_READ;
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO $USER_READ;
EOF
	echoi $i "done"
fi 

############################################
# Create remaining indexes
############################################

echoi $e -n "Creating remaining indexes..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -v URL_DB_DATA="$URL_DB_DATA" -f $DIR/sql/create_indexes.sql
source "$includes_dir/check_status.sh"

echoi $e -n "Optimizing indexes..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -c "VACUUM ANALYZE gadm"
source "$includes_dir/check_status.sh"

######################################################
# Report total elapsed time and exit
######################################################

source "$includes_dir/finish.sh"