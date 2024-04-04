
$dateNow = Get-Date
$tsLower = Get-Date $dateNow.AddMinutes(-20) -f s
$tsUpper = Get-Date $dateNow -f s

$xpath = @"
*[System
  [TimeCreated['$tsLower'<@SystemTime and @SystemTime<'$tsUpper']]
  [EventID=$() or EventID=$()]
 ]
"@

try {
    $events = @(Get-WinEvent -ComputerName $hostname -LogName $LogName -FilterXPath $xpath -ea:Stop)
} catch {
    if ($_.Exception.Message -cNE 'No events were found that match the specified selection criteria.') {
        throw
    }
    $events = @()
}

