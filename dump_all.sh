#!/bin/bash

KEEP=3
PATH=/usr/pgsql-14/bin:$PATH
PREFIX=/var/lib/pgsql/scripts

EXPIRE=`date --date="$KEEP days ago" +%Y%m%d`
CURRENT=`date +%Y%m%d`

if [ -f "$PREFIX/pg_dumpall_$EXPIRE.gz" ]; then
    rm $PREFIX/pg_dumpall_$EXPIRE.gz
fi

pg_dumpall -U postgres | gzip > $PREFIX/pg_dumpall_$CURRENT.gz
