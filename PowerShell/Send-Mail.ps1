#·Send-Mail.ps1
param ( $subject = $(throw), $body = $(throw)
, $addrTo=( 'Nikita.Retyunskiy@outlook.com' )
, $attachments = @()
)
$addrFrom = [net.dns]::GetHostName() + '|' + $env:UserDomain + '+' + $env:UserName + '@' + $env:UserDnsDomain

[string]::IsNullOrWhiteSpace($subject) -and $(throw) | out-null

$body=@"
<!DOCTYPE html>
<html>
<head>
</head>
<body>
$([Security.SecurityElement]::Escape($body))
<br />
<hr color='Navy' style='height:8px' />
</body>
</html>
"@

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Send-MailMessage -UseSsl -Priority High -Subject $subject -BodyAsHtml -Body $body

$mail = New-Object net.mail.MailMessage($addrFrom, $addrTo, $subject, $body)
$mail.IsBodyHtml = $true

$attachments |% { $mail.Attachments.Add($(New-Object net.mail.Attachment($_))) }

$smtp = New-Object net.mail.SmtpClient('smtp.sendgrid.net', 587)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object net.NetworkCredential('SMTP Relay username', 'SMTP Relay password')

$mail.Priority = [Net.Mail.MailPriority]::High

$smtp.Send($mail)
