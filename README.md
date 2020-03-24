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

Creates & populates a local postgres instance of the Global Administrative Areas(GADM) Database. Downloads entire GADM world database as Geopackage and imports to PostgreSQL database 'gadm'. Changes ownership to an admin-level user and enables select access for one read-only user, as specified in parameter file. Standardized political division names according to Geonames database (www.geonames.org). 

## Software

Ubuntu 16.04 or higher  
PostgreSQL/psql 12.2, or higher (PostGIS extension will be installed by this script)

## Dependencies

Requires postgres database geonames, installed locally. See repo `https://github.com/ojalaquellueva/gnrs.git`

## Permissions

This script must be run by a user with sudo and authorization to connect to postgres (as specified in `pg_hba` file). The admin-level and read-only Postgres users for the gadm database (specified in `params.sh`) should already exist and must be authorized to connect to postgres (as specified in pg_hba file).

## Installation and configuration
* Recommend the following setup:

```
mkdir -p gadm
cd gadm
mkdir src
cd src
git clone https://github.com/ojalaquellueva/gadm.git
mv data ../
mv config ../
```

## Usage

1. Set parameters in `params.sh`.
2. Set passwords and other sensitive parameters in `config/db_config.sh`.
2. Run the master script, `gadm.sh`.

### Syntax

```
./gadm.sh [options]
```

### Options
-m: Send notification emails  
-n: No warnings: suppress confirmations but not progress messages  
-s: Silent mode: suppress all confirmations & progress messages  

### Example:

```
./gadm -m -s
```
* Run silently without terminal echo
* Send notification message at start and completion


