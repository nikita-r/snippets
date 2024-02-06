
function Post-Request ([string]$uri, [hashtable]$body, [string]$ContentType, [hashtable]$headers) {
    $H1 = if (-not $ContentType) { @{} } else { @{ ContentType = $ContentType } } # [System.Nullable[string]] cannot be
    $H2 = if (-not $headers) { @{} } else { @{ Headers = $headers } }
    $splat = $H1 + $H2
    $response = try {
        Invoke-WebRequest -Method Post @splat -Uri $uri -Body (
            [text.encoding]::UTF8.GetBytes( (ConvertTo-Json -c $body) )
        ) -UseBasicParsing # -is [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]
    } catch [net.WebException] {
        if ($_.Exception.Status -ne [net.WebExceptionStatus]::ProtocolError) { throw }
        ${HTTP_status_string} = $_.Exception.Message -replace '^The remote server returned an error: \((\d+)\) (.+)\.$', 'HTTP $1: $2'
        Write-Host ${HTTP_status_string} -ForegroundColor Yellow
        if ($_.Exception.Response.StatusCode -eq 200) { throw $null }
        Write-Host $_.ErrorDetails.Message
        if ($_.Exception.Response.ContentType -match '^[^;]+/json\b') {
            $details = $_.ErrorDetails.Message | ConvertFrom-Json
            if ('error' -in $details.psObject.Properties.Name) {
                if ('message' -in $details.error.psObject.Properties.Name) {
                    Write-Host $details.error.message -ForegroundColor Red
                } else {
                    Write-Host $details.error -ForegroundColor Red
                }
            }
        }
        $_.Exception.Response
    }
    if ($response -isNot [net.HttpWebResponse] -and $response.BaseResponse -isNot [net.HttpWebResponse]) { throw }
    return $response
}

function Fetch-Data ( [string]$uri, [hashtable]$body
                    , [string]$ContentType = 'application/json; charset=utf-8', [hashtable]$headers = $null ) {
    $response = Post-Request $uri $body $ContentType $headers
    if ($response.StatusCode -eq [net.HttpStatusCode]::OK) { # 'Content' -in $response.psObject.Properties.Name
        return,@(ConvertFrom-Json $response |% data)
    }
    Write-Output -NoEnumerate @()
}

