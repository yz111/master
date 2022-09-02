SELECT 
	ns.nspname AS SchemaName
	,c.relname AS SequenceName
FROM pg_class AS c
JOIN pg_namespace AS ns 
	ON c.relnamespace=ns.oid
WHERE c.relkind = 'S'
  AND NOT EXISTS (SELECT * FROM pg_depend WHERE objid=c.oid AND deptype='a')
ORDER BY c.relname;
