<#
Expand-Archive -ea:0 …
if (-not $?) { . . . }
#>
function Expand-Archive {
  [CmdletBinding()]
  param ( [string]$Path, [string]$DestinationPath )
  try {
    Write-Host " $((Get-Date -Format s) -replace 'T', ' ') . . . Commenced * Expand-Archive -Path `"$Path`" -DestinationPath `"$DestinationPath`""

    $err = 'Unacceptable wildcard characters in arg'
    if ($Path -match '[][*`?]') { throw "${err}: $Path" }
    if ($DestinationPath -match '[][*`?]') { throw "${err}: $DestinationPath" }

    if (-not (Test-Path $Path -PathType Leaf) -or -not ([io.path]::GetExtension($Path) -eq '.zip')) { throw "`"$Path`" does not exist / not a `".zip`" file" }
    if (-not (Test-Path $DestinationPath -PathType Container)) { throw "`"$DestinationPath`" does not exist / not a folder" }

    $app = New-Object -ComObject Shell.Application

    $zip = $app.NameSpace($Path)
    if (-not $zip.Items().Count) { throw "`"$Path`" does not contain any items" }

    $dir = $app.NameSpace($DestinationPath)
    if (-not $dir.Self.IsFolder) { throw "`"$DestinationPath`" is not a folder" }

    $dir.CopyHere($zip.Items(), 0x14) # &H10& "Yes to All" | &H4& without progress dialog

    Write-Host " $((Get-Date -Format s) -replace 'T', ' ') . . . Completed * Expand-Archive"
  } catch {
    $psCmdlet.WriteError($_)
  }
}
