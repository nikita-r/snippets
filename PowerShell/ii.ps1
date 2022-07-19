ii $home

notepad (Get-PSReadLineOption).HistorySavePath

Get-NetTCPConnection |? OwningProcess -in ( Get-Process | Out-GridView -PassThru ).id `
| select @{N='PID';E={'{0:d6}' -f $_.OwningProcess}}`
, LocalAddress, LocalPort, State, RemoteAddress, RemotePort | Sort-Object PID, `
LocalAddress, LocalPort, RemoteAddress, RemotePort `
|% {''}{ $_.PSObject.ToString() -replace '; State=|}',"`n`$0" }

-join( 32..126 |% {[char]$_} | Sort-Object {$_.ToString()} )

Get-PSProvider | select -ExpandProperty Drives # == Get-PSDrive

New-TemporaryDirectory | tee -Variable path
Find-Module admin | Save-Module -Path $path

Get-Module -ListAvailable
Get-Module -list az.*
Get-ExecutionPolicy -list

$env:PSModulePath -split ';'

[AppDomain]::CurrentDomain.GetAssemblies()

Update-Help -Force -Ea 0 -Ev errVar

(Join-Path (Get-Location) $null) # != [Environment]::CurrentDirectory

$cred = [pscredential]::new($username, (Read-Host password -AsSecureString))
New-PSSession -Credential $cred | Enter-PSSession

$choice = $host.ui.PromptForChoice('[ prompt title ]', 'Is it safe to proceed?', ('&Yes', '&No'), 1)
if ($choice -ne 0) { throw }

