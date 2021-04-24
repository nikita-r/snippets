#·go-ifconfig.ps1
$host.ui.RawUI.WindowTitle = 'ifconfig'
(iwr icanhazip.com).Content
irm ifconfig.me; ''
ipconfig | select -Index (6..10); ''
