# Import and standardize GADM PostgreSQL database

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

Creates & populates a local postgres instance of the Global Administrative Areas(GADM) Database (www.gadm.org). Downloads GADM world database as Geopackage and imports to PostgreSQL. Optionally, can changes ownership to an admin-level user and adds one or more read-only users. 

Two optional standardization steps link GADM to Geonames (www.geonames.org) political divisions. Option 1 links directly by matching on ISO 3166-2 and HASC codes. Option 2 uses the GNRS (https://github.com/ojalaquellueva/gnrs.git) to perform both exact and fuzzy matching to geonames. Either step populates additional columns of standardized political division identifiers and names according to Geonames.

## Software

Ubuntu 16.04 or higher  
PostgreSQL/psql 12.2, or higher (PostGIS extension will be installed by this script)

## Dependencies

1. **ISO/HASC code crosswalk table**. For optional standardization using ISO 3361-2 and HASC codes. Requires a lookup table of Admin 1 codes, downloaded from Natural Earth (https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-1-states-provinces/). Data package available here: `https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-1-states-provinces/`. *Will be downloaded automatically by this application, unless url has changed*.

2. **GNRS database**. Optional standardization using the GNRS requires local installation of the GNRS (see rhttps://github.com/ojalaquellueva/gnrs.git). 

3. **PHP extension dBase**, for unpacking the ISO-HASC crosswalk table from dbf file. This is not a standard PHP extension.  On Ubuntu 16.04+, you will need to do the following:

```
sudo add-apt-repository ppa:ondrej/php
suod apt update
sudo apt install php-pear
sudo apt install php7.0-dev
sudo pecl install dBase
```

Now add the following line to php.ini:

```
extension=dbase.so
```

No need to restart PHP.

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


