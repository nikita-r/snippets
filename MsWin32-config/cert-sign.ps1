
makecert -n "CN=PowerShell Local Certificate Root" -a sha1 `
-eku 1.3.6.1.5.5.7.3.3 -sv root.pvk root.cert -r `
-ss Root -sr LocalMachine

makecert -pe -n "CN=PowerShell User" -a sha1 `
-eku 1.3.6.1.5.5.7.3.3 -iv root.pvk -ic root.cert `
-ss My

Set-AuthenticodeSignature $PROFILE (Get-ChildItem cert:\CurrentUser\My -CodeSigningCert)

