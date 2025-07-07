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

<# Out-GridView #>
$rows = @(Invoke-Sqlcmd <#..#> -ServerInstance SI -Database DB -Query @"
"@)
Write-Host $rows.Count
$rows | Out-GridView -Title <#..#> -PassThru | Format-List

<# INSERT with OUTPUT #>
$sql = "INSERT [Table] ( [ColA], [ColN] )"
$sql += ' OUTPUT Inserted.ID'
$sql += " VALUES ( '$valA', '$valN' );"
Write-Host "$sql"
$id = 0
$id = Invoke-Sqlcmd <#..#> -ServerInstance SI -Database DB -Query $sql -ea:Continue
<# `$id -eq $null` upon SQL error; `$id -eq 0` if login failed #>
if ($id) { Write-Host "[ ID: $($id.ID) ]" }

<# serialize table data in ASCII #>
$outs = @()
foreach ($row in $rows) {
    [ordered]$out = @{}
    foreach ($c in ($row.Table.Columns |% Caption)) {
        if ($row.$c -is [datetime]) {
            $out.$c = (Get-Date $row.$c -f s) + (Get-Date $row.$c -F.fff)
        } else {
            $out.$c = ([string] $row.$c) -replace '[^\x09\x20-\x7E\x0d\x0a]','?'
        }
    }
    $outs += @($out)
}
$text = $outs | ConvertTo-Csv -NoHeader #Requires -Version 7.4


<# Invoke-Command #>

$filepath = 'c$\Windows\System32\drivers\etc\hosts'
$dirpath = Split-Path ($filepath -replace '^c\$\\', 'C:\')
Write-Host cmd.exe /c "rd/s/q $local:dirpath"
Invoke-Command -ComputerName $hostname -ScriptBlock { cmd.exe /c "rd/s/q $using:dirpath" }
Write-Host DONE cmd.exe


<# Parallel Jobs #>
<# Remotely Echo #>

$sb = { c:\scripting\try.ps1 }
$machines = Get-ADComputer -Filter * |% DNSHostName
$jobs = $machines |% { Invoke-Command -AsJob -Credential $cred -ComputerName $_ -ScriptBlock $sb }

Get-EventSubscriber -SourceIdentifier DataAdded-* | Unregister-Event -ea:0
$jobsCount = 0
$jobs |% { Register-ObjectEvent -InputObject $_.ChildJobs[0].Output -EventName 'DataAdded' -MessageData $jobsCount `
                                                            -SourceIdentifier ('DataAdded-{0:D3}' -f ++$jobsCount) }
$jobs |% { Register-ObjectEvent -InputObject $_ -EventName StateChanged }

function handle ($output, $idx) {
    Write-Host @($output).Count
}

while ($jobs |? State -eq 'Running') {
    Wait-Event |
    % { Write-Host $_.SourceIdentifier
        if ($_.SourceIdentifier -like 'DataAdded-*') {
            $output = Receive-Job $jobs[$_.MessageData]
            handle $output $_.MessageData
        }
        $_ } | Remove-Event
}

1..$jobsCount |% { handle (Receive-Job $jobs[$_-1]) ($_-1) }

$jobs |? State -eq 'Failed' |% {
    Write-Host 'Failed:' $_.ChildJobs[0].Location $_.ChildJobs[0].Command
    Write-Host 'Reason:' $_.ChildJobs[0].JobStateInfo.Reason.GetType()
    Write-Host $_.ChildJobs[0].JobStateInfo.Reason.Message
    Write-Host
}

$jobs | Remove-Job -Force
Get-EventSubscriber | Unregister-Event
Get-Event | Remove-Event


<# 32-bit PoSh #>
$wd = 'C:\Scripts'
$splat = @{
    ArgumentList = '[environment]::Is64BitProcess -eq $false'
    UseNewEnvironment = $true

    RedirectStandardInput = "$wd\stdin.txt" # must exist
    RedirectStandardOutput = "$wd\stdout.txt"
    RedirectStandardError = "$wd\stderr.txt"
}
Start-Process -Wait @splat -WorkingDirectory $wd -FilePath $env:SystemRoot/SysWOW64/WindowsPowerShell/v1.0/powershell.exe

