ii $home

notepad (Get-PSReadLineOption).HistorySavePath

Get-NetTCPConnection |? OwningProcess -in ( Get-Process | Out-GridView -PassThru ).id `
| select @{N='PID';E={'{0:d6}' -f $_.OwningProcess}}`
, LocalAddress, LocalPort, State, RemoteAddress, RemotePort | sort PID, `
LocalAddress, LocalPort, RemoteAddress, RemotePort `
|% {''}{ $_.PSObject.ToString() -replace '; State=|}',"`n`$0" }

-join( 32..126 |% {[char]$_} | sort {$_.ToString()} )

Get-PSProvider

New-TemporaryDirectory | tee -Variable path
Find-Module admin | Save-Module -Path $path

Get-Module -ListAvailable
Get-Module -list az.*
Get-ExecutionPolicy -list

[AppDomain]::CurrentDomain.GetAssemblies()

Update-Help -Force -Ea 0 -Ev errVar

