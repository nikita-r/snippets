
function Get-Subject ($folder, $file) {
    $sh = New-Object -COM Shell.Application
    $ns = $sh.NameSpace($folder)
    $Subject = @()
    $ns.Items() |? Path -like (Join-Path $folder $file) |% {
        $Subject += ,@( $_.Name, $ns.GetDetailsOf($_, 22) ) # Name may lack file extension depending on Windows Explorer config
    }
    return $Subject
}

