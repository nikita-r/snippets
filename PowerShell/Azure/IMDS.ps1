
Get-IMDS-AccessToken ( $AppID = $(throw) ) {
    #
    # App ID URI of the target resource (aud in JWT)
    # key vault #$AppID = 'https://vault.azure.net'
    # sql server #$AppID = 'https://database.windows.net'
    #
    $uri = 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource='
  #$response = try {
    $response = Invoke-WebRequest -UseBasicParsing -Method Get -Headers @{ Metadata = 'true' } -Uri "$uri$AppID"
  #} catch [System.Net.WebException] {
  #  $HttpErrorStatusCode = [int] $_.Exception.Response.StatusCode
  #  $HttpErrorStatusMessage = $_.Exception.Response.StatusDescription
  #  throw $_.Exception.Message
  #  #$_.Exception.Response
  #}
    $AccessToken = $response.Content | ConvertFrom-Json |% access_token
    return $AccessToken
}

Get-KvSecret ( $kv = $(throw), $secretName = $(throw), $secretVersion = '' ) {
    $AccessToken = Get-IMDS-AccessToken 'https://vault.azure.net'
    $uri = 'https://' + $kv + '.' + 'vault.azure.net' + '/secrets/' + $secretName + '/' + $secretVersion + '?api-version=7.4'
    $response = iwr -UseBasicParsing $uri -Headers @{ Authorization = 'Bearer ' + $AccessToken }
    $value = ConvertFrom-Json $response |% value
    return $value
}


