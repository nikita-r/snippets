
param ( [string]$svcName = $(throw), [timespan]$timeout = '00:01:00' )

$_kept_ErrorActionPreference = [string] $ErrorActionPreference

$svc = Get-Service -Name $svcName
if (!$svc) { throw }

$ErrorActionPreference = 'SilentlyContinue' # WaitForStatus throws when time is out

#$svc.WaitForStatus('Running', $timeout)
#if ($svc.Status -ne 'Running') { throw 'The service "' + $svcName + '" was not found Running' }

$svc.Stop()
$svc.WaitForStatus('Stopped', $timeout)
if ($svc.Status -ne 'Stopped') { throw 'The service "' + $svcName + '" could not be Stopped' }

$ErrorActionPreference = $_kept_ErrorActionPreference

<# . . . #>

Clear-EventLog -LogName "$svcName Service Log"
Limit-EventLog -LogName "$svcName Service Log" -MaximumSize 10MB

<# . . . #>

$ErrorActionPreference = 'SilentlyContinue' # WaitForStatus throws when time is out

$svc.Start()
$svc.WaitForStatus('Running', $timeout)
if ($svc.Status -ne 'Running') { throw 'The service "' + $svcName + '" failed to re-Start' }

$ErrorActionPreference = $_kept_ErrorActionPreference

