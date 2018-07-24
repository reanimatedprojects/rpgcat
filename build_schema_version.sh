#!/bin/bash

# Run this in the top level directory of RPGCat

# Load the environment if the database name is not already configured.
if [ -z "$MYSQL_DATABASE" ]
then
    # This is the heart of the set-env.sh script
    [ -f environment.conf ] && $(cat environment.conf | ( while read E; do if [[ $E =~ ^[A-Z0-9_]+=.+$ ]]; then echo "export $E"; fi; done ))
fi
if [ -z "$MYSQL_DATABASE" ]
then
    echo "ERROR: MYSQL_DATABASE environment var not already defined or in environment.conf"
    exit;
fi

# Build the DBI connection string (assumes MySQL in use)
DBI="dbi:mysql:database=${MYSQL_DATABASE};host=${MYSQL_HOST};user=${MYSQL_USER};password=${MYSQL_PASSWORD}"

script/rpgcat_dh.pl -Ilib --schema RPGCat::Schema -c "$DBI" -o $PWD/ddl $*
