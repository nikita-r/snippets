
$pathnameGitExe = gcm git -ea:0 |% Path
if (-not $pathnameGitExe) {
    # $pathnameGitExe === $null
}

# root of the repository (top-level directory of the working tree)
$root = & $pathnameGitExe rev-parse --show-toplevel
if ($LASTEXITCODE) {
    $root = $null
} else {
    $root = $root -replace '/', '\' # get Windows path
}

$branch = & $pathnameGitExe rev-parse --abbrev-ref HEAD
if ($branch -ceq 'HEAD') {
    # detached
}

