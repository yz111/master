SELECT 
	datname AS DatabaseName
	,pg_catalog.pg_get_userbyid(datdba) AS OwnerName
	,CASE 
		WHEN pg_catalog.has_database_privilege(datname, 'CONNECT')
		THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(datname))
		ELSE 'No Access For You'
	END AS DatabaseSize
FROM pg_catalog.pg_database
ORDER BY 
	CASE 
		WHEN pg_catalog.has_database_privilege(datname, 'CONNECT')
		THEN pg_catalog.pg_database_size(datname)
		ELSE NULL
	END DESC;
