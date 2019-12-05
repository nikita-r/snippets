
--DD

CREATE TABLE #Data (
id int IDENTITY(1,1)
, list nvarchar(63)
);

INSERT #Data (list)
VALUES
  ( 'abc;def;ghi;jkl' )
, ( 'abc;def;ghi;jkl;abc;def' )
, ( '' ), ( 'pqr' )
, ( 'abc;jkl;' )
, ( 'ghi;ghi;ghi' )
, ( ';;' ), ( NULL )
, ( ';ghi' )
, ( 'abc' )
;

--DM

SELECT id
     , string_agg(value, ',') within GROUP (ORDER BY value) AS pruned_list
FROM (
SELECT DISTINCT id, List.value
  FROM #Data
 CROSS APPLY string_split(list, ';') as List
 WHERE List.value IN ( 'abc', 'ghi' )
) as X
 GROUP BY id
 ORDER BY id

--//
