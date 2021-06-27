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

try {
  $flock = [io.file]::Open("$ScrDir\$ScrName.lock", 'Create', 'Write')
} catch {
  $msg = 'Cannot acquire lock file: ' + $_.Exception.InnerException.Message
  Write-Error $msg
  exit 1 # is superfluous if -ea:Stop is in effect for `Write-Error`
}

$dlog = ".\logs\${ScrName}_D$((Get-Date -f s) -replace ':', '-' -replace '-')"
ni -Type Directory "$dlog" | out-null

Start-Transcript "$dlog\Transcript.txt"
try {

<# Logs ini #>

$dtLog = [data.DataTable]::new()
$dtLog.Columns.AddRange(@( 'when', 'what', 'why' ))
#[void]$dtLog.Rows.Add(@( when, what, why ))

try {

<# Action!! #>

<# Logs out #>

} finally {

$dtLog.Select("", 'when, what deSC, why') `
| ConvertTo-Csv -NoType | Set-Content "$dlog\Log.csv"

}

<# Epilogue #>

} finally {
Stop-Transcript
}
