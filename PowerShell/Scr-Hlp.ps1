#·Scr-Hlp.ps1
throw

function Get-FileName_LineNo {
"$($MyInvocation.ScriptName):$($MyInvocation.ScriptLineNumber)"
}

(Get-Date (Get-Date).ToUniversalTime() -f s) + '.000Z'

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

rv * -ea SilentlyContinue
[gc]::Collect()

function ?? ($PossiblyNil, $ValueIfNil = $(throw)) {
if ([string]::IsNullOrWhiteSpace($PossiblyNil)) { $ValueIfNil } else { $PossiblyNil }
}

try { throw } catch { # $_.ToString() is $_.Exception.ToString() sans exception type?
'{0}:{1:d4}: {2}' -f (?? $_.InvocationInfo.ScriptName '<interactive>'), $_.InvocationInfo.ScriptLineNumber, $_.Exception
}

if ($host.Name -clike '* ISE *' -and -not $global:is_host_profile_loaded) {
    . ($profile -creplace 'ISE')
    $global:is_host_profile_loaded = $true
}

