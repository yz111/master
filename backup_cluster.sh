#!/bin/bash

#DATABASES=(`psql -AXqtc "select datname from pg_database where datname !='template0' and datname != 'template1' "`)

#for d in ${DATABASES[@]}; do
#    echo $d
#done

KEEP=7
PATH=/usr/pgsql-14/bin:$PATH
PREFIX=/var/lib/pgsql/scripts
BASE=/var/lib/pgsql/14/backups
PHYSICAL_BACKUP_DIR=$BASE/physical

EXPIRE=`date --date="$KEEP days ago" +%Y%m%d`
CURRENT=`date +%Y%m%d`

if [ -d "$PHYSICAL_BACKUP_DIR/$EXPIRE" ]; then
    rm -rf $PHYSICAL_BACKUP_DIR/$EXPIRE
fi

mkdir -p $PHYSICAL_BACKUP_DIR/$CURRENT

pg_basebackup -D $PHYSICAL_BACKUP_DIR/$CURRENT
