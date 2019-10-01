#!/bin/bash

BASEDIR=`dirname "${BASH_SOURCE%/*}"`
echo "Found base directory of $BASEDIR"

cd "$BASEDIR" || exit

# PWD should be the top level directory of RPGCat

if [ ! -x "script/rpgcat_server.pl" ]
then
    echo "Test server script is either not present or not executable"
    exit
fi

# Load the environment if the database name is not already configured.
if [ -z "$MYSQL_DATABASE" ]
then
    # This is the heart of the set-env.sh script
    [ -f environment.conf ] && $(cat environment.conf | ( while read E; do if [[ $E =~ ^[A-Z0-9_]+=.+$ ]]; then echo "export $E"; fi; done ))
fi
if [ -z "$MYSQL_DATABASE" ]
then
    echo "ERROR: MYSQL_DATABASE environment var not already defined or in environment.conf"
    exit
fi

script/rpgcat_server.pl -r --fork -d -p 3016 2>&1

