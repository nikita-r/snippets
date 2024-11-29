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

<# Prompting #>

$cred = [pscredential]::new($username, (Read-Host password -AsSecureString))
New-PSSession -Credential $cred | Enter-PSSession

$choice = $host.ui.PromptForChoice('[ prompt title ]', 'Is it safe to proceed?', ('&Yes', '&No'), 1)
if ($choice -ne 0) { throw }

<# Web #>

function Get-RedirectionUrl ($url) {
    $request = [net.WebRequest]::Create($url)
    $request.AllowAutoRedirect = $false
    $response = $request.GetResponse()

    if (300 -le $response.StatusCode -and $response.StatusCode -lt 400) {
        $response.GetResponseHeader('Location')
    } else {
        '(' + $response.StatusCode + ')'
    }
}

<# Invoke-Sqlcmd #>

Import-Module SqlServer -Version 21.1.18256
$rows = @(Invoke-Sqlcmd <#..#> -ServerInstance SI -Database DB -Query @"
"@)
Write-Host $rows.Count
$rows | Out-GridView -Title <#..#> -PassThru | Format-Table


<# Parallel Jobs #>
<# Remotely Echo #>

$sb = { c:\scripting\try.ps1 }
$machines = Get-ADComputer -Filter * |% DNSHostName
$jobs = $machines |% { Invoke-Command -AsJob -Credential $cred -ComputerName $_ -ScriptBlock $sb }

Get-EventSubscriber -SourceIdentifier DataAdded-* | Unregister-Event -ea:0
$jobsCount = 0
$jobs |% { Register-ObjectEvent -InputObject $_.ChildJobs[0].Output -EventName DataAdded `
                                                            -SourceIdentifier "DataAdded-$((++$jobsCount).ToString().PadLeft(3, '0'))" -MessageData $jobsCount }
$jobs |% { Register-ObjectEvent -InputObject $_ -EventName StateChanged }

while ($jobs |? State -eq 'Running') {
    Wait-Event |? SourceIdentifier -like 'DataAdded-*' `
    |% { $output = Receive-Job $jobs[$_.MessageData - 1]
        Write-Host @($output).Count; $_ } | Remove-Event
}

$jobs | Receive-Job

$jobs |? State -eq 'Failed' |% {
    Write-Host 'Failed:' $_.ChildJobs[0].Location $_.ChildJobs[0].Command
    Write-Host 'Reason:' $_.ChildJobs[0].JobStateInfo.Reason.GetType()
    Write-Host $_.ChildJobs[0].JobStateInfo.Reason.Message
    Write-Host
}

$jobs | Remove-Job -Force
Get-Event | Remove-Event


