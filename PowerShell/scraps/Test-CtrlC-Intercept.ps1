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
    Write-Host 'Exiting now!' -back DarkRed
    exit 1
}

$i=0
while ($true) {
    Write-Host -non ('Line #{0:d3}' -f ++$i) -back Black -fore Yellow
    1..3 |% {
        sleep -mil $ms
        Write-Host -non . -back Black -fore ([ConsoleColor]($_+12))
        Catch-ControlC
    }
    Write-Host
}
