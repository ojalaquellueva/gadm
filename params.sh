#!/bin/bash

##############################################################
# Application parameters
# Check and change as needed
##############################################################

# Name of this database
DB_GADM="gadm"

# Code version (github repo for this code)
# Assign tag and use tag #
# Otherwise entire commit hash or leave blank
VERSION="3.6"

# Target URL for GADM Geopackage, including file name
# Australia only, for testing:
#URL_DB_DATA="https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_AUS_gpkg.zip"
# Complete GADM world package:
URL_DB_DATA="https://biogeo.ucdavis.edu/data/gadm3.6/gadm36_gpkg.zip"

# Data version
DB_DATA_VERSION="3.6"

# Name of downloaded compressed data package
DB_DATA_ARCHIVE=$(basename $URL_DB_DATA)

# Name of the main uncompressed data file
# Need both commands to replace '_' with '.' and remove extension
DB_DATA=${DB_DATA_ARCHIVE/_gpkg/.gpkg}
DB_DATA=${DB_DATA/.zip/}

# Base application directory
APP_BASE_DIR="/home/boyle/bien/gadm"

# Main application directory
APP_DIR="${APP_BASE_DIR}/src"

# Path to db_config.sh
# For production, keep outside app working directory & supply
# absolute path
# For development, if keep inside working directory, then supply
# relative path
# Omit trailing slash
db_config_path="${APP_BASE_DIR}/config"

# Path to general function directory
# If directory is outside app working directory, supply
# absolute path, otherwise supply relative path
# Omit trailing slash
#functions_path=""
functions_path="${APP_BASE_DIR}/src/includes"

# Path to data directory
# DB input data from GADM will be saved here
# If directory is outside app working directory, supply
# absolute path, otherwise use relative path (i.e., no 
# forward slash at start).
# Recommend keeping outside app directory
# Omit trailing slash
DATA_BASE_DIR="${APP_BASE_DIR}/data"

# Makes user_admin the owner of the db and all objects in db
# If leave user_admin blank ("") then database will be owned
# by whatever user you use to run this script, and postgis tables
# will belong to postgres
USER_ADMIN="bien"		# Admin user

# Give user_read select permission on the database
# If leave blank ("") user_read will not be added and only
# you will have access to db
USER_READ="bien_private"	# Read only user

########################################################
# GNRS parameters
########################################################

# Add columns of political division names standardized using GNRS 
# Values: t|f
STANDARDIZE_GNRS="t"

# GNRS database name
DB_GNRS="gnrs"

# Absolute path to GNRS root application & data directories
# Path to GNRS DB required for extracting political division tables
# Leave blank ("") if not applicable and/or STANDARDIZE_POLDIV_NAMES="f"
GNRS_DIR="/home/boyle/bien/gnrs/src"
GNRS_DATA_DIR="/home/boyle/bien/gnrs/data/user"

# GNRS file names
GNRS_INPUT_FILE="gadm_gnrs_submitted.csv"
outfile_basename=$(basename ${GNRS_INPUT_FILE%.*})
GNRS_RESULTS_FILE=$outfile_basename"_gnrs_results.csv"

########################################################
# Natural Earth crosswalk table parameters
########################################################

# Index political divisions to GNRS using Natural Earth crosswalk table
# Values: t|f
STANDARDIZE_NE="t"

# Download crosswalk data directly from source?
# Values:
#	t 	Download directly from source
#	f 	Import from file already present in data directory)
# If $DOWNLOAD_CROSSWALK="f", you MUST manually download the archive,
# extract the dbf file to utf-8 csv, and place it in the crosswalk
# data directory
DOWNLOAD_CROSSWALK="f"

# Link to dbf file of admin1 political divisions and codes
# Needed for linking GADM admin1 to geonames admin1
# Once unzipped, you still need to be able to dump the dbf file
URL_ADM1_CROSSWALK="https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces.zip"

# The archive should just be the basename of the url, but 
# adjust accordingly if not
ARCHIVE_ADM1_CROSSWALK=$(basename $URL_ADM1_CROSSWALK)

# Name of dbf file that needs to be unpacked. 
# Adjust accordingly if this formula changes
DBF_ADM1_CROSSWALK=${ARCHIVE_ADM1_CROSSWALK/.zip/.dbf}

# This is only crosswalk file nameparameter needed needed
# if not importing directly from source
CSV_ADM1_CROSSWALK=${DBF_ADM1_CROSSWALK/.dbf/.csv}

########################################################
# Geonames parameters
########################################################

# Geonames database name
DB_GEONAMES="geonames"

########################################################
# Misc parameters
########################################################

# Destination email for process notifications
# You must supply a valid email if you used the -m option
email="bboyle@email.arizona.edu"

# Short name for this operation, for screen echo and 
# notification emails. Number suffix matches script suffix
pname="Build database $DB_GADM"

# General process name prefix for email notifications
pname_header_prefix="BIEN notification: process"

# Log file parameters
today=$(date +"%Y-%m-%d")
glogfile="log/gadm_log_${today}.txt"
appendlog="false"