/* select-cube.sql */

SELECT Field_A, Field_B, Field_C
     , STRING_AGG(AccountName, ', ') within GROUP (ORDER BY AccountName) as Accounts
     , SUM(Cost) as 'Total Cost'
--INTO #tempTable
  FROM dbo.DataTable
 GROUP BY
  CUBE(Field_A, Field_B, Field_C)
 ORDER BY
       Field_A, Field_B, Field_C
;
