#!/bin/bash

# Script to reset uadmin account password via Casper policy

# Author  : contact@richard-purves.com
# Version : 1.0 - Initial Version

# Script relies on old and new passwords being passed via parameter 4.

# Grab passed password
newpassword=$4

# Make the password change
/usr/bin/dscl . passwd /Users/admin $newpassword

exit 0
