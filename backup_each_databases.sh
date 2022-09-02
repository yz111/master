#!/bin/bash

#DATABASES=(`psql -AXqtc "select datname from pg_database where datname !='template0' and datname != 'template1' "`)

#for d in ${DATABASES[@]}; do
#    echo $d
#done

KEEP=3
PATH=/usr/pgsql-14/bin:$PATH
PREFIX=/var/lib/pgsql/scripts
BASE=/var/lib/pgsql/14/backups
LOGICAL_BACKUP_DIR=$BASE/logical
PHYSICAL_BACKUP_DIR=$BASE/physical

EXPIRE=`date --date="$KEEP days ago" +%Y%m%d`
CURRENT=`date +%Y%m%d`

if [ -d "$LOGICAL_BACKUP_DIR/$EXPIRE" ]; then
    rm -rf $LOGICAL_BACKUP_DIR/$EXPIRE
fi

mkdir -p $LOGICAL_BACKUP_DIR/$CURRENT

pg_dumpall --schema-only > $LOGICAL_BACKUP_DIR/$CURRENT/schema.$CURRENT.sql

DATABASES=`psql -AXqtc "select datname from pg_database where datname not in ('template0','template1') "`

for d in ${DATABASES}; do
    pg_dump -F c -v -f $LOGICAL_BACKUP_DIR/$CURRENT/$d.$CURRENT.dbf $d 
done
