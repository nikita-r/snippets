
function New-Pwd ([int]$len = 16) {
    -join(
        @( 65..90 | Get-Random -Count 1 ) `
      + @( 65..90 + 97..122 + 48..57 | Get-Random -Count ($len-1) ) `
        |% { [char] $_ }
    )
}

