
function Expand-Archive ( $Path, $DestinationPath ) {
    Write-Host "Commenced * Expand-Archive -Path `"$Path`" -DestinationPath `"$DestinationPath`""
    if (-not (Test-Path $Path)) { throw "`"$Path`" does not exist" }
    if (-not (Test-Path $DestinationPath)) { throw "`"$DestinationPath`" does not exist" }
    $app = New-Object -ComObject Shell.Application
    $zip = $app.NameSpace($Path)
    $dst = $app.NameSpace($DestinationPath)
    $dst.CopyHere($zip.Items(), 0x14) # &H10& "Yes to All" | &H4& without progress dialog
    Write-Host "Completed * Expand-Archive"
}

