# Build GADM PostgreSQL database

Author: Brad Boyle (bboyle@email.arizona.edu)  
Date created: 24 March 2020  


## Contents

[Overview](#overview)  
[Software](#software)  
[Dependencies](#dependencies)  
[Permissions](#permissions)  
[Installation and configuration](#installation-and-configuration)  
[Usage](#usage)  

## Overview

Creates & populates a local postgres instance of the Global Administrative Areas(GADM) Database (www.gadm.org). Downloads entire GADM world database as Geopackage and imports to PostgreSQL database 'gadm'. Optionally changes ownership to an admin-level user and adds one read-only user, as specified in parameter file. Optionally populates additional columns consisting of standardized political division names according to Geonames (www.geonames.org). Names standardized using the Geographic Name Resolution Service (GNRS, https://github.com/ojalaquellueva/gnrs.git).

## Software

Ubuntu 16.04 or higher  
PostgreSQL/psql 12.2, or higher (PostGIS extension will be installed by this script)

## Dependencies

Optional standardization of political division names requires local installation of the GNRS (see rhttps://github.com/ojalaquellueva/gnrs.git). 

## Permissions

* Scripts must be run by user with sudo. User must also have authorization to connect to postgres (as specified in `pg_hba.conf`) without a password. 
* Admin-level and read-only Postgres users for the gadm database (specified in `params.sh`) must already exist, with authorization to connect to postgres.

## Installation and configuration

```
# Create application base directory
mkdir -p gadm
cd gadm

# Create application code directory
mkdir src

# Install repo to application code directory
cd src
git clone https://github.com/ojalaquellueva/gadm.git

# Move data and sensitive parameters directories outside of code directory
# Be sure to change paths to these directories (in params.sh) accordingly
mv data ../
mv config ../
```

## Usage

1. Set parameters in `params.sh`.
2. Set passwords and other sensitive parameters in `config/db_config.sh`.
2. Run the master script, `gadm_db.sh`.

### Syntax

```
./gadm.sh [options]
```

### Command line options
-m: Send notification emails  
-n: No warnings: suppress confirmations but not progress messages  
-s: Silent mode: suppress all confirmations & progress messages  
* All other options must be set in params.inc

### Example:

```
./gadm.sh -m -s
```
* Runs silently without terminal echo
* Sends notification message at start and completion


