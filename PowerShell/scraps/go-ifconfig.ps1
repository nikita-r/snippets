#·go-ifconfig.ps1
$host.ui.RawUI.WindowTitle = 'ifconfig'
(iwr 'icanhazip.com').Content
(iwr 'ifconfig.me').Content; ''
ipconfig | select -Index (6..10); ''
