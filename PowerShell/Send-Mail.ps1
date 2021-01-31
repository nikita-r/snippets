#·Send-Mail.ps1
param ( $subject = $(throw), $body = $(throw)
, $addrTo=( 'Nikita.Retyunskiy@outlook.com' )
, $attachments = @()
)
$addrFrom = $env:UserName + '|' + [net.dns]::GetHostName() + '@' + $env:UserDnsDomain

[string]::IsNullOrWhiteSpace($subject) -and $(throw) | out-null

#if ([string]::IsNullOrWhiteSpace($body)) {
    $body=@"
<!DOCTYPE html>
<html>
<head>
</head>
<body>
$body
<br />
<hr color='Navy' style='height:8px' />
</body>
</html>
"@
#}

$mail = New-Object net.mail.MailMessage($addrFrom, $addrTo, $subject, $body)
$mail.IsBodyHtml = $true

$attachments |% { $mail.Attachments.Add($(New-Object net.mail.Attachment($_))) }

$smtp = New-Object net.mail.SmtpClient('smtp.sendgrid.net', 587)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object net.NetworkCredential('SMTP Relay username', 'SMTP Relay password')

$smtp.Send($mail)

