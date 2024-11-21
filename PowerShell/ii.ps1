ii $home

notepad (Get-PSReadLineOption).HistorySavePath

gc Function:\prompt

Update-Help -Force -Ea 0 -Ev errVar

(Join-Path (Get-Location) $null) # != [Environment]::CurrentDirectory
[Environment]::CurrentDirectory = pwd
if ($PSVersionTable.PSVersion.Major -gt 6) {
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction += { [Environment]::CurrentDirectory = $pwd.Path }
}

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

$env:PSModulePath = '.'
Import-Module $env:WinDir\System32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1
Test-NetConnection sql.url -Port 1433

[AppDomain]::CurrentDomain.GetAssemblies()

$cred = [pscredential]::new($username, (Read-Host password -AsSecureString))
New-PSSession -Credential $cred | Enter-PSSession

$choice = $host.ui.PromptForChoice('[ prompt title ]', 'Is it safe to proceed?', ('&Yes', '&No'), 1)
if ($choice -ne 0) { throw }

<# Web #>

function Get-RedirectedUrl ($url) {
    $request = [net.WebRequest]::Create($url)
    $request.AllowAutoRedirect = $false
    $response = $request.GetResponse()

    if ($response.StatusCode -in 'Found', 'MovedPermanently' ) {
        $response.GetResponseHeader('Location')
    } else {
        '(' + $response.StatusCode + ')'
    }
}

