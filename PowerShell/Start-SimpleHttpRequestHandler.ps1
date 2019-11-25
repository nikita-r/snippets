#·Start-SimpleHttpRequestHandler.ps1

#> netsh http add urlacl url=http://+:8080/ user=%UserDomain%\%UserName%

$listenr = New-Object net.HttpListener
$listenr.Prefixes.Add('http://+:8080/')
$listenr.Start()
while ($listenr.IsListening) {
    $context = $listenr.GetContext()
    $rekwest = $context.Request
    $rekwest_url = $rekwest.Url.OriginalString
    Write-Host ($rekwest.HttpMethod + ' ' + $rekwest_url)

    if ($rekwest.HasEntityBody) {
        $strIn = [io.StreamReader]::new($rekwest.InputStream)
        Write-Host $strIn.ReadToEnd()
    }

    $responz = $context.Response
    $responz.Headers.Add('Content-Type', 'text/plain')
    $responz.StatusCode = 200

    $bufOut = [text.encoding]::UTF8.GetBytes('Oh, hi, Mark!')
    $responz.ContentLength64 = $bufOut.Length
    $responz.OutputStream.Write($bufOut, 0, $bufOut.Length)

    $responz.Close()

    if ($rekwest.HasEntityBody) {
        Write-Host
    }
}

