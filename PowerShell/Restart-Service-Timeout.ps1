
param ( [string]$svcName = $(throw), [timespan]$timeout = '00:01:00' )

$svc = Get-Service -Name $svcName
#$svc.WaitForStatus('Running', $timeout)
#if ($svc.Status -ne 'Running') { throw 'The service "' + $svcName + '" was not found Running' }
$svc.Stop()
$svc.WaitForStatus('Stopped', $timeout)
if ($svc.Status -ne 'Stopped') { throw 'The service "' + $svcName + '" could not be Stopped' }

<# . . . #>

Clear-EventLog -LogName "$svcName Service Log"
Limit-EventLog -LogName "$svcName Service Log" -MaximumSize 10MB

<# . . . #>

$svc.Start()
$svc.WaitForStatus('Running', $timeout)
if ($svc.Status -ne 'Running') { throw 'The service "' + $svcName + '" failed to re-Start' }

