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

echo %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log
PowerShell "Set-NetFirewallProfile -Profile Domain,Private,Public -LogAllowed True -LogBlocked True"
rem Events 5156/5157 in "Windows Logs\Security"
auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:enable

