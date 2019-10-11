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

