
$utcNow = (Get-Date).ToUniversalTime()
$tsHour = Get-Date $utcNow -Minute 0 -Second 0 -Millisecond 0

${function:Get-RowKeyPrefix} = {
    param ( [datetime]$ts = $utcNow )
    $dr = [Int64]::DivRem($ts.Ticks, 10000000) # Ticks is at 100-nanosecond precision and counts 18 digits
    return [string] ([Int64] ('9' * 11) - $dr.Item1) # 11-digit string — seconds until 3169-11-16T09:46:39Z
}.GetNewClosure()

