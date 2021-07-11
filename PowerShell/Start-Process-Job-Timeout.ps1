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
    } else { # if an arg of the form "-a:1" is passed from cmd, it gets split
        $argv += @('"' + $args[$i] + ':' + $args[$i+1] + '"')
        $i += 2
    }
}

Write-Host $cmd
$argv | Write-Host

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

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

$JobD = Start-Job `
        {
          $ErrorActionPreference='Stop'

          # WinUser.h
          Add-Type -Name User -Namespace Win32 -MemberDefinition @'
[DllImport("User32")]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

[DllImport("User32")]
[return: MarshalAs(UnmanagedType.Bool)] // not strictly necessary
public static extern bool PostMessage(IntPtr hWnd, uint Msg, uint wParam, IntPtr lParam);

[DllImport("User32")]
public static extern int GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);

public const uint WM_SYSCOMMAND = 0x0112;
public const uint SC_CLOSE = 0xF060;

public const uint WM_KEYDOWN = 0x0100;
public const uint VK_RETURN = 0x0D;

public const uint WM_CLOSE = 0x0010;
'@
          while (1) {

            Start-Sleep -mil 333
            [IntPtr]$hWnd = [Win32.User]::FindWindow('#32770', 'Dialog One')
            if ($hWnd -eq [IntPtr]::Zero) { continue } # (!$hWnd) is always false for [IntPtr]

            # FIXME: verify PID
            #[IntPtr]$_pid = 0
            #[void][Win32.User]::GetWindowThreadProcessId($hWnd, ([ref]$_pid));

            # Dismiss Dialog One: try and press 'x' or 'okay'
            [void][Win32.User]::PostMessage($hWnd
                , [Win32.User]::WM_SYSCOMMAND, [Win32.User]::SC_CLOSE, [IntPtr]::Zero)
            [void][Win32.User]::PostMessage($hWnd
                , [Win32.User]::WM_KEYDOWN, [Win32.User]::VK_RETURN, [IntPtr]::Zero)

            Start-Sleep -mil 333
            $hWnd = [Win32.User]::FindWindow('#32770', 'Dialog Two')
            if ($hWnd -eq [IntPtr]::Zero) { continue }

            # Dismiss Dialog Two: able to post WM_CLOSE directly
            [void][Win32.User]::PostMessage($hWnd, [Win32.User]::WM_CLOSE, 0, 0)
          }
        }

$JobT = Start-Job { param ([int]$sec) Start-Sleep $sec } -ArgumentList $sec

$Job = Get-Job | Wait-Job -Any # Could return an array?

if ($Job -eq $JobD) {
    (Get-Job) -ne $JobD | Remove-Job -Force
    $err = $JobD.ChildJobs[0].JobStateInfo.Reason.Message
    Remove-Job $JobD
    throw $err
} elseif ($Job -eq $JobA) {
    Remove-Job $JobD -Force
    Remove-Job $JobT -Force
    $proc_id, $ExitCode = Receive-Job $JobA
    if ($JobA.State -eq 'Completed') {
        Write-Host ("PID=$proc_id" + ' ' + $JobA.State + '!')
    } else {
        Write-Host -fore Red ("Script Job $($JobA.State): " `
            + $JobA.ChildJobs[0].JobStateInfo.Reason.Message)
    }
    Remove-Job $JobA
    if (!$proc_id) {
        throw 'Failed to Start-Process'
    }
    if ($null -eq $ExitCode) {
        throw '~ unexpected error'
    }
} elseif ($Job -eq $JobT) {
    Remove-Job $JobD -Force
    Remove-Job $JobT
    Write-Host 'Time is out...'
    $proc_id, $ExitCode = Receive-Job $JobA
    if (!$proc_id) {
        Remove-Job $JobA -Force
        throw 'Timed out trying to Start-Process'
    }
    if ($null -ne $ExitCode) {
        Write-Host '~ unfortunate timing' -fore Red
        Remove-Job $JobA
    } else {
        Write-Host "Kill PID=$proc_id"
        (Get-Process -Id $proc_id).Kill()
        Wait-Job $JobA | Out-Null
        $ExitCode = Receive-Job $JobA
        Remove-Job $JobA
        throw "Timed out PID=$proc_id ExitCode=$ExitCode"
    }
} else {
    Get-Job | Remove-Job -Force
    throw
}

$ExitCode
