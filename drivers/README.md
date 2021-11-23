# Install Additional Drivers

## Overview

Each additional driver to be installed has to be created according to the directory structure and installation mechanism.

## Directory Structure

`<vendor>`/[`vendor sub-type`]/`<driver type>`

Examples:

* `ibm`/`db2`/`odbc`
* `mariadb`/`odbc`
* `postgresql`/`pgsql`


## Install Script

Each driver directory has an `install.ps1` script plus (if needed) additional files required for the installation. The `install.ps1` script will be called by the `install-drivers.ps1` script inside the `scripts` directory.  

Please make sure to add all necessary steps to automate the installation of the additional driver inside the `install.ps1` script. It is also 
recommended to have clean-up steps to remove setup files, zip files etc. That would help to keep the image small. 