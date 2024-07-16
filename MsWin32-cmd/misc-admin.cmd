rem misc-admin.cmd

nltest /dsgetdc:%User[Dns]Domain%

for /F "tokens=*" %%E in ('wevtutil.exe el') DO wevtutil.exe cl "%%E"
wevtutil.exe cl System

net user nr /domain

dir %WinDir%\Logs\WindowsUpdate /O-D /A-D /B
PowerShell Get-WindowsUpdateLog

PowerShell "(New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole('Domain Admins')"

Start-Process cmd.exe /c -Credential (Get-Credential)
$credential | Export-CLIXML C:\Secrets\CR01#$env:UserDomain+$env:UserName@$(hostname.exe).credential.xml

