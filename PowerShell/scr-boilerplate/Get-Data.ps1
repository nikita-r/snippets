param (
#$ = $(throw)
)

$script:Result = [Data.DataTable]::new()

$script:cnxn = [Data.SqlClient.SqlConnection] $connectionString

[void] `
[Data.SqlClient.SqlDataAdapter]::new(
    [Data.SqlClient.SqlCommand]::new(@"
SELECT *
  FROM dbo.Table
 WHERE 1=1
   AND ...
 ORDER BY 1 deSC, 2, 3
;
"@, $cnxn)
).Fill($Result)

$cnxn.Dispose()

,$Result # need the comma to return the actual DataTable and not an Object[] of DataRow
