#Requires -PSEdition Desktop
#Requires -Version 5.1

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

<# Prologue #>

$ScrName = [io.path]::GetFileNameWithoutExtension($PSCommandPath)

$SysDir = [Environment]::CurrentDirectory
if ($SysDir -ne (pwd).Path) { throw }

$ScrDir = $PSScriptRoot
if ($SysDir -ne $ScrDir) { throw }

$logsDir = ".\logs\${ScrName}-D*"
$o=Get-ChildItem (Split-Path $logsDir) -Directory (Split-Path $logsDir -Leaf) `
|? CreationTime -lt (Get-Date).AddDays(-33)

$logsDir = $logsDir -replace '\*$', ((Get-Date -f s)-replace':','-'-replace'-')
ni -Type Directory $logsDir | out-null

Start-Transcript $logsDir\Transcript.txt
$o | Remove-Item -Recurse -ea:Continue
try { # finally Stop-Transcript

try {
  $flock = [io.file]::Open("$ScrDir\$ScrName.lock", 'Create', 'Write')
} catch {
  $msg = 'Cannot acquire lock file: ' + $_.Exception.InnerException.Message
  Write-Error $msg
  exit 1 # is superfluous if -ea:Stop is in effect for `Write-Error`
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

} finally {
Stop-Transcript
}
