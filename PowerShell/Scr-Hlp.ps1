#·Scr-Hlp.ps1
throw

function Get-FileName_LineNo {
"$($MyInvocation.ScriptName):$($MyInvocation.ScriptLineNumber)"
}

function Get-ScriptDirectory {
  $pathnameCurrentFile = if ($host.Name -clike '* ISE Host') { $global:psISE.CurrentFile.FullPath } else { $global:PSCommandPath }
  Split-Path $(if (Split-Path $pathnameCurrentFile -IsAbsolute) { $pathnameCurrentFile } else { Join-Path ([environment]::CurrentDirectory) . })
}


<# ad-logging #>

Start-Transcript -LiteralPath ($PSCommandPath + '.' + $env:ClientName + '[' + $env:UserDomain + '+' + $env:UserName + '@' + $env:ComputerName + '.' + $env:UserDnsDomain + ']' + '.Transcript.log')

cmd.exe /c "echo $name on %date% at %time: =0%>C:\ad-logs\$name.log"
cmd.exe /c ($line + ' 2>&1') | Out-File -Append C:\ad-logs\$name.log -Encoding ascii


# Bitmask the selection of TLS versions.
# [Net.SecurityProtocolType]::SystemDefault -eq 0

# force SSL 3.0
[Net.ServicePointManager]::SecurityProtocol = 'Ssl3'

# disallow TLS 1.0
[Net.ServicePointManager]::SecurityProtocol = `
[Net.ServicePointManager]::SecurityProtocol -bAnd -bNot [Net.SecurityProtocolType] 'Tls'

# allow TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = `
[Net.ServicePointManager]::SecurityProtocol -bOr 'Tls12'


<# bypass TLS cert validation #>
# pwsh: -SkipCertificateCheck
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
[Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()

# same as the above, but sans C♯
class TrustAllCertsPolicy : Net.ICertificatePolicy {
    [bool]CheckValidationResult([Net.ServicePoint]$a
    , [Security.Cryptography.X509Certificates.X509Certificate]$b
    , [Net.WebRequest]$c, [int]$d) {
        return $true
    }
}
[Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# same as the above, C♯-only
'System.Net.ServicePointManager.ServerCertificateValidationCallback += (a, b, c, d) => true;'


# input secrets
$strSecure = Read-Host 'Enter strSecure' -AsSecureString
using namespace System.Runtime.InteropServices
$str = [Marshal]::PtrToStringAuto([Marshal]::SecureStringToBSTR($strSecure))


<# repo mem #>
rv * -ea SilentlyContinue
[gc]::Collect()


<# Elvis operator — Invoke-NullCoalescing in Pscx #>
function ?? ($PossiblyNil, $ValueIfNil = $(throw)) {
if ([string]::IsNullOrWhiteSpace($PossiblyNil)) { $ValueIfNil } else { $PossiblyNil }
}


<# looking for the perfect exceptional one-liner #>
try { throw } catch {
'{0}:{1:d4}: {2}' -f (?? $_.InvocationInfo.ScriptName '<interactive>'),
$_.InvocationInfo.ScriptLineNumber,
$_.Exception.ToString() # type & message + StackTrace
}


<# dump to stdout all antecedent exceptions in chronological order #>
$Error.Reverse()
$Error |% {
    if ($_ -is [Management.Automation.ErrorRecord]) {
        Write-Host; Write-Host ('{0}:{1:d4}: {{{2}}} {3}' -f
            $_.InvocationInfo.ScriptName, $_.InvocationInfo.ScriptLineNumber,
            $_.FullyQualifiedErrorId, $_.Exception.Message)
    } else {
        Write-Host ('~: [' + $_.GetType().ToString() + ']')
    }
}
$Error.Clear()
Write-Host; throw 'Script aborted; see stdout for errors.'


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
    $_
    continue mainLoop
  }
}


<# dict.update #>

$obj = ConvertFrom-Json '{}' # [pscustomobject]
$obj.{row·id} = [string][char]0xd8 # Ø
if (!@($obj.psObject.Properties).Count -or $kv.Key -notIn $obj.psObject.Properties.Name) {
    $obj | Add-Member -MemberType NoteProperty -Name $kv.Key -Value $kv.Value.Clone() # ? Value.psObject.Copy()
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


<# Web #>
iwr $url -UseBasicParsing |% Links |% href


