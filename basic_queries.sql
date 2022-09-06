/* top 10 write tables */
select schemaname as "Schema Name", relname as "Table Name",
n_tup_ins+n_tup_upd+n_tup_del as "no.of writes" from
pg_stat_all_tables where schemaname not in ('snapshots','pg_catalog')
order by n_tup_ins+n_tup_upd+n_tup_del desc limit 10;

/* get all catalog tables */
\dt pg_catalog.*

/* Get name and value from pg_settings */
select name,setting from pg_settings;

/* check version() */
select version();

/* top 10 read tables */
SELECT schemaname as "Schema Name", relname as "Table
Name",seq_tup_read+idx_tup_fetch as "no. of reads" FROM
pg_stat_all_tables WHERE (seq_tup_read + idx_tup_fetch) > 0 and
schemaname NOT IN ('snapshots','pg_catalog') ORDER BY
seq_tup_read+idx_tup_fetch desc limit 10;

/* Largest Tables in DB */
SELECT QUOTE_IDENT(TABLE_SCHEMA)||'.'||QUOTE_IDENT(table_name) as
table_name,pg_relation_size(QUOTE_IDENT(TABLE_SCHEMA)||'.'||QUOTE_IDENT(table_name)) as size,
pg_total_relation_size(QUOTE_IDENT(TABLE_SCHEMA)||'.'||QUOTE_IDENT(table_name)) as total_size,
pg_size_pretty(pg_relation_size(QUOTE_IDENT(TABLE_SCHEMA)||'.'||QUOTE_IDENT(table_name))) as pretty_relation_size,pg_size_pretty(pg_total_relation_size(QUOTE_IDENT(TABLE_SCHEMA)||'.'||QUOTE_IDENT(table_name))) as pretty_total_relation_size FROM information_schema.tables WHERE QUOTE_IDENT(TABLE_SCHEMA) NOT IN ('snapshots') ORDER BY size DESC LIMIT 10;

/* DB Size */
SELECT datname, pg_database_size(datname),
pg_size_pretty(pg_database_size(datname))
FROM pg_database
ORDER BY 2 DESC;

/* Table Size */
SELECT schemaname, relname, pg_total_relation_size(schemaname
|| '.' || relname ) ,
pg_size_pretty(pg_total_relation_size(schemaname || '.' ||
relname ))
FROM pg_stat_user_tables
ORDER BY 3 DESC;

/* Index Size */
SELECT schemaname, relname, indexrelname,
pg_total_relation_size(schemaname || '.' || indexrelname ) ,
pg_size_pretty(pg_total_relation_size(schemaname || '.' ||
indexrelname ))
FROM pg_stat_user_indexes
ORDER BY 1,2,3,4 DESC;

/* Index Utilization */
SELECT schemaname, relname, indexrelname, idx_scan, idx_tup_fetch,
idx_tup_read
FROM pg_stat_user_indexes
ORDER BY 4 DESC,1,2,3;

/* Tables That Are Being Updated the Most and Looking for VACUUM*/
select relname, /* pg_size_pretty( pg_relation_size( relid ) ) as table_size,
                 pg_size_pretty( pg_total_relation_size( relid ) ) as table_total_size, */
                 n_tup_upd, n_tup_hot_upd, n_live_tup, n_dead_tup, last_vacuum::date, last_autovacuum::date, last_analyze::date, last_autoanalyze::date
from pg_stat_all_tables
where relid in (select oid from pg_class
                       where relnamespace not in (select oid from pg_namespace
                               where nspname in ('information_schema', 'pg_catalog','pg_toast', 'edbhc' ) ) )
order by n_tup_upd desc, schemaname, relname;
SELECT schemaname,
         relname,
         now() - last_autovacuum AS "noautovac",
         now() - last_vacuum AS "novac",
         n_tup_upd,
         n_tup_del,
         autovacuum_count,
         last_autovacuum,
         vacuum_count,
         last_vacuum
FROM pg_stat_user_tables
WHERE (now() - last_autovacuum > '7 days'::interval
        AND now() - last_vacuum >'7 days'::interval)
        OR (last_autovacuum IS NULL AND last_vacuum IS NULL ) AND n_dead_tup > 0
ORDER BY  novac DESC;
SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%",
to_char(last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') as autovacuum_date,
to_char(last_autoanalyze, 'YYYY-MM-DD HH24:MI:SS') as autoanalyze_date
FROM pg_stat_all_tables where schemaname not in ('pg_toast','pg_catalog','information_schema')
ORDER BY last_autovacuum ;

/* Real-Time Bloated Tables */
select relname, n_live_tup, n_dead_tup, (n_dead_tup/(n_dead_tup+n_live_tup)::float)*100 as "% of bloat", last_autovacuum, last_autoanalyze from pg_stat_all_tables where (n_dead_tup+n_live_tup) > 0 and (n_dead_tup/(n_dead_tup+n_live_tup)::float)*100 > 0;

/* Slow running queries on DB from last 5 min */
select now()-query_start as Running_Since,pid, datname, usename, application_name, client_addr, left(query,60) from pg_stat_activity where state in ('active','idle in transaction') and (now() - pg_stat_activity.query_start) > interval '2 minutes';

/* Grant privileges on all tables */
SELECT 'grant select,update,usage on '||c.relname||' to username;' FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r',") AND n.nspname='schemaname' AND pg_catalog.pg_get_userbyid(c.relowner)='username';

/* Check privileges on Tables */
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'S' THEN 'sequence' END as "Type",
  pg_catalog.array_to_string(c.relacl, E'\n') AS "Access privileges",
  pg_catalog.array_to_string(ARRAY(
    SELECT attname || E':\n  ' || pg_catalog.array_to_string(attacl, E'\n  ')
    FROM pg_catalog.pg_attribute a
    WHERE attrelid = c.oid AND NOT attisdropped AND attacl IS NOT NULL
  ), E'\n') AS "Column access privileges"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r') AND pg_catalog.pg_get_userbyid(c.relowner)='username' AND n.nspname='schemaname';

/* Find privileges of a user on objects */
Find Privileges of a User on Objects
SELECT n.nspname as "Schema",
    c.relname as "Name",
    CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'foreign table' END as "Type",
    pg_catalog.array_to_string(c.relacl, E'\n') AS "Access privileges",
    pg_catalog.array_to_string(ARRAY(
      SELECT attname || E':\n  ' || pg_catalog.array_to_string(attacl, E'\n  ')
      FROM pg_catalog.pg_attribute a
      WHERE attrelid = c.oid AND NOT attisdropped AND attacl IS NOT NULL
    ), E'\n') AS "Column access privileges"
  FROM pg_catalog.pg_class c
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind IN ('r', 'v', 'S', 'f')
    AND n.nspname !~ '^pg_' AND pg_catalog.pg_table_is_visible(c.oid) and pg_catalog.pg_get_userbyid(c.relowner)='owner'
  ORDER BY 1, 2;

/* Get list of all tables and their row count */
SELECT
pgClass.relname AS tableName,
pgClass.reltuples AS rowCount
FROM
pg_class pgClass
LEFT JOIN
pg_namespace pgNamespace ON (pgNamespace.oid = pgClass.relnamespace)
WHERE
pgNamespace.nspname NOT IN ('pg_catalog', 'information_schema') AND
pgClass.relkind='r';

/* Find parameters changes for a table */
SELECT c.relname, pg_catalog.array_to_string(c.reloptions || array(select 'toast.' || x from pg_catalog.unnest(tc.reloptions) x), ', ')
FROM pg_catalog.pg_class c
 LEFT JOIN pg_catalog.pg_class tc ON (c.reltoastrelid = tc.oid)
WHERE c.relname = 'test';
