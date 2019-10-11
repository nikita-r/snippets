#·Send-Mail.ps1
param ( $subj = $(throw), $body = $(throw)
, $addr = 'Nikita.Retyunskiy@moodys.com' )

$mail = New-Object net.mail.MailMessage("$env:UserName@$([net.dns]::GetHostByName('localhost').HostName)", $addr, $subj, $body)
#$mail.Attachments.Add(New-Object net.mail.Attachment($FilePath))
$smtp = New-Object net.mail.SmtpClient('smtp.sendgrid.net', 587)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object net.NetworkCredential('SMTP Relay username', 'SMTP Relay password')
$smtp.Send($mail)

