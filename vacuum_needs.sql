SELECT schemaname,
          relname,
          now() - last_autovacuum AS "noautovac",
          now() - last_vacuum AS "novac",
          n_tup_upd,
          n_tup_del,
          pg_size_pretty(pg_total_relation_size(schemaname||'.'||relname)),
          autovacuum_count,
          last_autovacuum,
          vacuum_count,
          last_vacuum
 FROM pg_stat_user_tables
 WHERE (now() - last_autovacuum > '7 days'::interval
         OR now() - last_vacuum >'7 days'::interval )
         OR (last_autovacuum IS NULL AND last_vacuum IS NULL )
 ORDER BY  novac DESC;
