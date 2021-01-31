#·Scr-Hlp.ps1
throw

function Get-FileName_LineNo {
"$($MyInvocation.ScriptName):$($MyInvocation.ScriptLineNumber)"
}

(Get-Date (Get-Date).ToUniversalTime() -f s) + '.000Z'
"D$((Get-Date -f s) -replace ':', '-' -replace '-')"

<# bypass SSL certificate checks #>
Add-Type @'
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
            return true;
        }
    }
'@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

<# repo mem #>
rv * -ea SilentlyContinue
[gc]::Collect()

<# Elvis operator — Invoke-NullCoalescing in Pscx #>
function ?? ($PossiblyNil, $ValueIfNil = $(throw)) {
if ([string]::IsNullOrWhiteSpace($PossiblyNil)) { $ValueIfNil } else { $PossiblyNil }
}

<# looking for the perfect exceptional one-liner #>
try { throw } catch { # $_.ToString() is $_.Exception.ToString() sans exception type?
'{0}:{1:d4}: {2}' -f (?? $_.InvocationInfo.ScriptName '<interactive>'), $_.InvocationInfo.ScriptLineNumber, $_.Exception
}
$(if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message })

<# spoof profile-loading #>
if ($host.Name -clike '* ISE *' -and -not $global:is_host_profile_loaded) {
    . ($profile -creplace 'ISE')
    $global:is_host_profile_loaded = $true
}

<# re-try #>
[int]$cntTry = $maxTry
$errorEx = $null
while ($cntTry-- -gt 0) {
    Write-Host ('Try #{0:D2}' -f ($maxTry - $cntTry))
  try {
    # . . .
  } catch {
    #$errorEx = $_.Exception
    continue
  }
    $Error.Clear()
    break
}
if ($cntTry -lt 0) {
    $errorEx = $Error[0].Exception
    throw $errorEx
}

<# spinster #>
:mainLoop `
while (1) { # once a minute
  $Error.Clear()
  sleep (61 - (Get-Date -f:ss))
  try {
  } catch {
  }
}


<# dict.update #>

$obj = ConvertFrom-Json '{}' # [pscustomobject]
$obj.{row·id} = [string][char]0xd8 # Ø
if (!@($obj.psobject.Properties).Count -or $kv.Key -notIn $obj.psobject.Properties.Name) {
    $obj | Add-Member -MemberType NoteProperty -Name $kv.Key -Value $kv.Value.Clone() # ? Value.PSObject.Copy()
} else {
    $obj.$($kv.Key) | Should -Be $kv.Value
}


<# shape output #>

$n = 123456789.6599
$n.ToString('.###') # '123456789.66'
$n.ToString('#,0.000') -eq $n.ToString('N3') # '123,456,789.660'
$n.ToString('#,.000') # '123456.790'

$delta.ToString('Δ+0.#####%;Δ−0.#####%;Δ·')
$delta.ToString('Δ+0%;Δ−0%;Δ~0') # returns 'Δ~0' for non-zero values that are less than 1%; more precisely, less than 0.5%, as the value is rounded to nearest (half away from zero)

$init = { $datetime = Get-Date }
$proc = { "${_}: " + $datetime.ToString([cultureinfo]::CreateSpecificCulture($_)) }
[cultureinfo]::GetCultures([Globalization.CultureTypes]::AllCultures).Name |% $init $proc
'fr-FR', 'fr-CA', 'en-US', 'en-GB', 'ru-RU' |% $init $proc


# MS SQL Server
[Data.SqlClient.SqlConnection]$cnxn
Write-Host ('SQL Server Connection timeout=' + $cnxn.ConnectionTimeout)
if ($cnxn.State -ne 1) { $cnxn.Open(); Write-Host ('SQL Server Connection re-opened') }

