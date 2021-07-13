#Requires -Version 7.1

param ( [int]$ms = 333 )

[console]::TreatControlCAsInput = $true

function Catch-ControlC {
    # Ctrl+C: VirtualKeyCode=67; ControlKeyState='LeftCtrlPressed'|'RightCtrlPressed'
    if ($host.ui.RawUI.KeyAvailable `
        -and 3 -eq $host.ui.RawUI.ReadKey('AllowCtrlC, IncludeKeyUp, NoEcho').Character)
    { throw [ExecutionEngineException] 'caught Ctrl+C' }
}

trap [ExecutionEngineException] {
    Write-Host
    Write-Host '^C caught!!!' -back DarkCyan -fore Cyan
    exit 1
}

$i=0
while ($true) {
    Write-Host -n ('Line #{0:d3}' -f ++$i) -back Black -fore Yellow
    1..3 |% {
        Start-Sleep -ms $ms
        Write-Host -n . -back Black -fore ([ConsoleColor]($_+12))
        Catch-ControlC
    }
    Write-Host
}
