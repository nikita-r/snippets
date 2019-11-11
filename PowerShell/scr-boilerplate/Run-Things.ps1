
$ErrorActionPreference = 'Stop'; Set-StrictMode -Version:Latest

<# Prologue #>

$SysDir = [Environment]::CurrentDirectory
if ($SysDir -ne (pwd).Path) { throw }
if ((Split-Path (pwd).Path -Leaf) -ne 'scr') { throw }

$ScrName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand)

try {
  $flock = [io.file]::Open("$(Split-Path -Resolve $MyInvocation.MyCommand -Parent)\$ScrName.lock", 'Create', 'Write')
} catch {
  $msg = 'Cannot acquire lock file: ' + $_.Exception.InnerException.Message
  Write-Error $msg
  exit 1
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
