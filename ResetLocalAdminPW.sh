#!/bin/bash

# Script to reset uadmin account password via Casper policy

# Author  : r.purves@arts.ac.uk
# Version : 1.0 - Initial Version
# Version : 1.1 - 28-11-2013 - Implemented a deletion and recreation of the keychain

# Script relies on old and new passwords being passed via parameter 4.
# Based on the filewave original by Adam Atkinson 10-11-2009.

# Grab passed password
newpassword=$4

# Make the password change
/usr/bin/dscl . passwd /Users/uadmin $newpassword

# Fix the keychain
# We have to perform the following operations as uadmin for this to work
# So lots of su coming right up!

# Change working directory to uadmin folder or this will fail badly!

cd /Users/uadmin

# Find the correct uadmin login keychain

KEYCHAIN=`su uadmin -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}'`

# Delete the uadmin login keychain if it exists

if [ "$KEYCHAIN" != "" ]
then
	su uadmin -c "security delete-keychain $KEYCHAIN"
else
	echo "Keychain is missing! Skipping deletion ..."
fi

# Recreate the uadmin login keychain with the new password as specified in the policy

expect <<- DONE
  set timeout -1
  spawn su uadmin -c "security create-keychain login.keychain"

# Look for prompt
  expect "*?chain:*"
  
# Send new password specified from policy

  send "$newpassword\n"
  expect "*?chain:*"
  send "$newpassword\r"
  
  expect EOF
DONE

#Set the newly created login.keychain as the users default keychain
su uadmin -c "security default-keychain -s login.keychain"

exit 0