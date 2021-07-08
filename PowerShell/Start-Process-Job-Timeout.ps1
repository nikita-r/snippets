#·Start-Process-Job-Timeout.ps1
#Requires -PSEdition Desktop
#Requires -Version 5.1

param ([int]$sec, [string]$cmd)
$argc = $args.Count
$argv = @()
$i=0; $f=0
while ($i -lt $argc) {
    if (!$f -and $args[$i] -eq '--') { $f = $true; $i += 1; continue }
    if ($f -or $i+1 -eq $argc `
           -or $args[$i] -notLike '-*' -or $args[$i+1] -like '-*') {
        $argv += @('"' + $args[$i] + '"')
        $i += 1
    } else { # if arg in the form "-a:1" is passed from cmd, it gets split
        $argv += @('"' + $args[$i] + ':' + $args[$i+1] + '"')
        $i += 2
    }
}

Write-Host $cmd
$argv | Write-Host

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

$JobT = Start-Job { param ([int]$sec) Start-Sleep $sec } -ArgumentList $sec

$JobA = Start-Job -ArgumentList $(if ([io.path]::IsPathRooted($cmd)) {"$cmd"}
                                else {"$PsScriptRoot\$cmd"}), $argv `
        { param ([string]$cmd, [string[]]$argv)
          $ErrorActionPreference='Stop'
          if ($argv) {
            $proc = Start-Process $cmd -ArgumentList $argv -PassThru
          } else {
            $proc = Start-Process $cmd -PassThru
          }
            $proc_handle = $proc.Handle # https://stackoverflow.com/questions/10262231/obtaining-exitcode-using-start-process-and-waitforexit-instead-of-wait
            $proc.Id
            $proc.WaitForExit()
            $proc.ExitCode
        }

$Job = Get-Job | Wait-Job -Any # Could return an array?
#Receive-Job $Job -OutVariable out
$proc_id, $ExitCode = $null, $null
if ($Job -eq $JobT) {
    Write-Host 'Time is out...'
    $proc_id, $ExitCode = Receive-Job $JobA
    if ($null -eq $proc_id) {
        Write-Host 'Timed out trying to Start-Process' -fore Red
        throw
    }
    if ($null -ne $ExitCode) {
        Write-Host '~ unfortunate timing' -fore Red
        throw
    }
    Write-Host "Kill PID=$proc_id"
    (Get-Process -Id $proc_id).Kill()
    Wait-Job $JobA | Out-Null
    $ExitCode = Receive-Job $JobA
    Remove-Job $JobA
} elseif ($Job -eq $JobA) {
    Remove-Job $JobT -Force
    if ($JobA.State -eq 'Completed') {
        $proc_id, $ExitCode = Receive-Job $JobA
        Write-Host ("PID=$proc_id" + ' ' + $JobA.State + '!')
    } else {
        Write-Host -fore Red ("Script Job $($JobA.State): " `
            + $JobA.ChildJobs[0].JobStateInfo.Reason.Message)
        throw
    }
} else {
    throw
}

$ExitCode
