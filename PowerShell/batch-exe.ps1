
$files | ForEach-Object {
    $cmd = 'python process.py "' + $_.FullName + '"'
    $global:LASTEXITCODE = 0
    iex $cmd
    if ($LASTEXITCODE) { throw }
}

