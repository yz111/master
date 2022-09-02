SELECT
    TableName
    ,pg_size_pretty(pg_table_size(TableName)) AS TableSize
    ,pg_size_pretty(pg_indexes_size(TableName)) AS IndexSize
    ,pg_size_pretty(pg_total_relation_size(TableName)) AS TotalSize
FROM 
(
     SELECT ('"' || table_schema || '"."' || table_name || '"') AS TableName
     FROM information_schema.tables
) AS Tables
ORDER BY 4 DESC;
