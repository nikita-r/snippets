
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # for Windows Server <= 2016

function Get-IMDS-AccessToken ( $AppID = $(throw) ) {
    #
    # App ID URI of the target resource (aud in JWT)
    # key vault #$AppID = 'https://vault.azure.net'
    # sql server #$AppID = 'https://database.windows.net'
    # storage blob #$AppID = 'https://storage.azure.com/'
    #
    $uri = 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource='
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Method Get -Headers @{ Metadata = 'true' } -Uri $uri$AppID
    } catch [net.WebException] {
        if ($_.Exception.Status -eq [net.WebExceptionStatus]::ProtocolError) {
            Write-Host "HTTP $([int] $_.Exception.Response.StatusCode): $($_.Exception.Response.StatusDescription)" -ForegroundColor Yellow
            Write-Host $_.ErrorDetails.Message
        }
        throw
    }
    $AccessToken = $response.Content | ConvertFrom-Json |% access_token
    return $AccessToken
}

$cached_BearerTokens = @{}
function Get-Az-AccessToken ( $url = $(throw) ) {
    if (-not $cached_BearerTokens[$url]) {
        $cached_BearerTokens[$url] = Get-AzAccessToken -ResourceUrl $url -AsSecureString
    }
    Write-Host "Bearer for `"$url`" expires" ((Get-Date $cached_BearerTokens[$url].ExpiresOn.UtcDateTime -f s) + 'Z')
    return ConvertFrom-SecureString $cached_BearerTokens[$url].Token -AsPlainText #Requires -Version 7.0
}

function Get-KvSecretValue ( $kv = $(throw), $secretName = $(throw), $secretVersion = '' ) {
    $uriBaseKV = 'vault.azure.net'
    $AccessToken = Get-IMDS-AccessToken "https://$uriBaseKV"
    $uri = 'https://' + $kv + '.' + $uriBaseKV + '/secrets/' + $secretName + '/' + $secretVersion + '?api-version=7.4'
    $response = iwr -UseBasicParsing $uri -Headers @{ Authorization = 'Bearer ' + $AccessToken }
    $value = ConvertFrom-Json $response |% value
    return $value
}

function Download-Blob ( $sa = $(throw), $container = $(throw), $blob = $(throw), $pathOut ) {
    $AccessToken = Get-IMDS-AccessToken https://storage.azure.com/
    $uri = "https://$sa.blob.core.windows.net/$container/$blob"
    $headers = @{ Authorization = 'Bearer ' + $AccessToken; 'x-ms-version' = '2019-02-02' }
    if (-not $pathOut) { $pathOut = $blob }
    Invoke-WebRequest -OutFile $pathOut -Uri $uri -Headers $headers
}

