#!/bin/bash

#########################################################################
# Purpose: Indexes GADM and sets permissions 
#
# Usage:	./cds_db.sh
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

# Confirm operation
source "$includes_dir/confirm.sh"

# Adjust data directory if needed
data_dir=$DATA_BASE_DIR

#########################################################################
# Main
#########################################################################

############################################
# Alter ownership and permissions
############################################

echoi $e "Changing database ownership and permissions:"

echoi $e -n "- Changing DB owner to 'user_admin'..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "ALTER DATABASE gadm OWNER TO $user_admin" 
source "$includes_dir/check_status.sh"  

echoi $e -n "- Granting permissions..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q <<EOF
\set ON_ERROR_STOP on
REVOKE CONNECT ON DATABASE gadm FROM PUBLIC;
GRANT CONNECT ON DATABASE gadm TO $user_admin;
GRANT CONNECT ON DATABASE gadm TO $user_read;
GRANT ALL PRIVILEGES ON DATABASE gadm TO $user_admin;
\c gadm
GRANT USAGE ON SCHEMA public TO $user_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $user_read;
EOF
echoi $i "done"

echoi $e "- Changing ownership of non-postgis relations to user '$user_admin':"
# Note: views not changed as all at this point are postgis relations

echoi $e -n "-- Tables..."
for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname='public' and tableowner<>'postgres';" gadm` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter table \"$tbl\" owner to $user_admin" gadm ; done
source "$includes_dir/check_status.sh"  

echoi $e -n "-- Sequences..."
for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" gadm` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter sequence \"$tbl\" owner to $user_admin" gadm ; done
source "$includes_dir/check_status.sh"  

############################################
# Create indexes
############################################

echoi $e -n "Creating indexes..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -v URL_DB_DATA="$URL_DB_DATA" -v DB_DATA_VERSION="$DB_DATA_VERSION" -v downloaded="$downloaded" -f $DIR/sql/create_indexes.sql
source "$includes_dir/check_status.sh"

echoi $e -n "Optimizing indexes..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -d gadm -q -c "VACUUM ANALYZE gadm"
source "$includes_dir/check_status.sh"

######################################################
# Report total elapsed time and exit
######################################################

source "$includes_dir/finish.sh"
