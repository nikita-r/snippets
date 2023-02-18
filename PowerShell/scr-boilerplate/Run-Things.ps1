#Requires -PSEdition Desktop
#Requires -Version 5.1

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

<# Prologue #>

$ScrName = [io.path]::GetFileNameWithoutExtension($PSCommandPath)

$SysDir = [Environment]::CurrentDirectory
if ($SysDir -ne (Get-Location).Path) { throw }

$ScrDir = $PSScriptRoot
if ($SysDir -ne $ScrDir) { throw }

$logsDir = ".\logs\${ScrName}-D*"
$oldies = Get-ChildItem (Split-Path $logsDir) `
             -Directory (Split-Path $logsDir -Leaf) `
          |? CreationTime -lt (Get-Date).AddDays(-33)

$logsDir = $logsDir -replace '\*$', ((Get-Date -f s)-replace':','-'-replace'-')
New-Item -Type Directory $logsDir | Out-Null

Start-Transcript $logsDir\Transcript.txt
$oldies | Remove-Item -Recurse -ea:Continue
try { # finally Stop-Transcript

try {
  $flock = [io.file]::Open("$ScrDir\$ScrName.lock", 'Create', 'Write')
} catch {
  $msg = 'Cannot acquire lock file: ' + $_.Exception.InnerException.Message
  Write-Error $msg
  exit 1 # not reachable once -ea:Stop is in effect for `Write-Error` above
}

<# Logs ini #>

$dtLog = [data.DataTable]::new()
$dtLog.Columns.AddRange(@( 'when', 'what', 'why' ))
#[void]$dtLog.Rows.Add(@( when, what, why ))

try {

<# Action!! #>

<# Logs out #>

} finally {

$dtLog.Select("", 'when, what deSC, why') `
| ConvertTo-Csv -NoType | Set-Content $logsDir\Log.csv

}

<# Epilogue #>

} catch {
$Error[0]
} finally {
Stop-Transcript
}
