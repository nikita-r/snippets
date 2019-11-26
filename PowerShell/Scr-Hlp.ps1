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
  } catch {
    $errorEx = $_.Exception
    continue
  }
    $Error.Clear()
    break
}
if ($cntTry -lt 0) {
    throw $errorEx
}

