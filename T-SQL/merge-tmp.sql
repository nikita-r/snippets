/* merge-tmp.sql */

DROP TABLE #a;
DROP TABLE #b;

CREATE TABLE #a ( id int IDENTITY(1,1), c1 int, c2 int, c3 int );
CREATE TABLE #b ( id int IDENTITY(1,1), c1 int, c2 int, c3 int );

INSERT INTO #a (c1,c2,c3) VALUES
(1, 2, 3),
(4, 2, 3),
(5, null, 3),
(6, 2, 3),
(7, 2, 3),
(8, 2, 3)
;

INSERT INTO #b (c1,c2,c3) VALUES
(1, 2, 3),
(4, 2, 3),
(5, null, 5),
(6, 2, 3),
(7, 2, 3),
(8, 2, 3)
;

MERGE INTO #a as Target
USING #b as Source
ON Source.c1 = Target.c1 AND Source.c2 = Target.c2
WHEN MATCHED AND Source.c3 <> Target.c3
THEN UPDATE SET Target.c3 = Source.c3
WHEN NOT MATCHED BY TARGET
THEN INSERT /*(c1,c2,c3)*/ VALUES (c1,c2,c3)
WHEN NOT MATCHED BY SOURCE
THEN DELETE
OUTPUT $Action, INSERTED.id
     , DELETED.id, DELETED.c1, DELETED.c2, DELETED.c3
;

SELECT * from #a;

