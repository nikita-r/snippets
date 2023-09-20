#Requires -PSEdition Desktop
#Requires -Version 5.1

param (
    $cnxnStringDB = $(throw),
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

Start-Transcript "$PSCommandPath.Transcript.log"

cd (Split-Path $PSCommandPath)
[Environment]::CurrentDirectory = (Split-Path $PSCommandPath)

#Find-Module SqlServer -MaximumVersion 21.1.18256 | Save-Module -Path .
$env:PSModulePath = '.'
Import-Module SqlServer


Write-Host ('Count=' + $data.Count)


$sqlDDL = @"
DROP TABLE IF EXISTS dbo.ETL_Table;
GO
CREATE TABLE dbo.ETL_Table (
);
GO
"@


$sqlDML = ''
$data |% {
$sqlDML += @"
INSERT INTO dbo.ETL_Table ( ) VALUES (
);

"@
}


Invoke-Sqlcmd -ConnectionString $cnxnStringDB -Query @"
SET XACT_ABORT ON;
GO
BEGIN TRANSACTION;

$sqlDDL

$sqlDML

COMMIT;
"@


Stop-Transcript
