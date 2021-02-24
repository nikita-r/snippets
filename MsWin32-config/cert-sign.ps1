
$alg = 'sha1' # default
$oid = '1.3.6.1.5.5.7.3.3'
$rootName = 'PowerShell Local Certificate Root'
$store = 'My'
$subject = 'PowerShell User'

makecert -n "CN=$rootName" -a $alg `
-eku $oid -sv root.pvk root.cert -r `
-ss Root -sr LocalMachine

makecert -pe -n "CN=$subject" -a $alg `
-eku $oid -iv root.pvk -ic root.cert `
-ss $store

Set-AuthenticodeSignature $PROFILE (
    Get-ChildItem Cert:\CurrentUser\$store -CodeSigningCert |? Subject -eq "CN=$subject" ) | Out-Null

