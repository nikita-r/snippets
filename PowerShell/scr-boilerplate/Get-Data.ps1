param (
$cnxnStr = $(throw)
)

$script:cnxn = [Data.SqlClient.SqlConnection] $cnxnStr

$script:data = [Data.DataTable]::new()

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
).Fill($data)

$cnxn.Close()

,$data # need the comma to return the actual DataTable and not an Object[] of DataRow
