#·Send-Mail.ps1
param ( $subj = $(throw), $body = $(throw)
, $attachments = @()
, $addr = 'Nikita.Retyunskiy@moodys.com' )

#$addrFrom = "$env:UserName@$([net.dns]::GetHostByName('localhost').HostName)"
$addrFrom = "$env:UserName.$([net.dns]::GetHostName())@$env:UserDnsDomain"

$mail = New-Object net.mail.MailMessage($addrFrom, $addr, $subj, $body)
$attachments |% { $mail.Attachments.Add($(New-Object net.mail.Attachment($_))) }

$smtp = New-Object net.mail.SmtpClient('smtp.sendgrid.net', 587)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object net.NetworkCredential('SMTP Relay username', 'SMTP Relay password')

$smtp.Send($mail)

