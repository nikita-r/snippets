/* see-upd.sql */

DECLARE @TableName varchar(max);
SET @TableName = '';

EXEC (
'select max(Date) as max_Date from ' + QUOTENAME(@TableName)
+';'
) ;

select OBJECT_NAME(i.object_id) as TableName, i.index_id
     , STATS_DATE(object_id(@TableName), i.index_id) as 'StatsUpdated'
     , i.Name as IndexName, i.type_desc
     , FORMAT( 8 * sum(a.used_pages)        , '#,0' ) AS 'IdxSz (KiB)'
     , FORMAT( 8 * sum(a.used_pages) / 1024 , '#,0' ) AS 'IdxSz (MiB)'
  from sys.indexes AS i
  JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
  JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
 where OBJECT_NAME(i.object_id) = @TableName
 group by i.object_id, i.index_id, Name, i.type_desc
 order by TableName, i.index_id
;

