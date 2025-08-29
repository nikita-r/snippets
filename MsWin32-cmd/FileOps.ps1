
function Get-Subject ($folder, $msi) {
    $sh = New-Object -COM Shell.Application
    $ns = $sh.NameSpace($folder)
    $Subject = $null
    if (Test-Path $msi) {
        $Subject = $ns.GetDetailsOf(($ns.Items() |? Name -eq $msi), 22)
    }
    return $Subject
}

