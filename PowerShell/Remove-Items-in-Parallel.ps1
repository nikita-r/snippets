
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 10)
$RunspacePool.Open()

$sb = {
    param ( $item )
    Remove-Item -Recurse $item -Force -ea:Stop
}

$tasks = [Collections.ArrayList]::new()
$items |% {
    $t = '' | select PowerShell, Args, AsyncResult, StartedAt, Idx, Result
    $t.PowerShell = [powershell]::Create().AddScript($sb).AddArgument($_)
    $t.PowerShell.RunspacePool = $RunspacePool
    $t.Args = @( $_ )
    $t.AsyncResult = $t.PowerShell.BeginInvoke()
    $t.StartedAt = [datetime]::Now
    $t.Idx = $tasks.Add($t)
}

foreach ($t in $tasks) {
    try {
        $t.Result = $t.PowerShell.EndInvoke($t.AsyncResult)
        Write-Host "Removed `"$($t.Args)`""
    } catch {
        Write-Error "Except `"$($t.Args)`": $($_.Exception.InnerException.Message)" -ea:Continue
    } finally {
        $t.PowerShell.Dispose()
    }
}

$RunspacePool.Close()
$RunspacePool.Dispose()
