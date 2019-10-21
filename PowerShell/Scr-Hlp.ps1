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

# $_.ToString() would omit the exception type
try { throw } catch {
("$(?? $_.InvocationInfo.ScriptName '<interactive>'):{0:d4}: " -f $_.InvocationInfo.ScriptLineNumber) + $_.Exception.ToString()
}

