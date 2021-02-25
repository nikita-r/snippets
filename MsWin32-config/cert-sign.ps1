
$alg = 'sha1' # default
$oid = '1.3.6.1.5.5.7.3.3' # iso(1) identified-organization(3) dod(6) internet(1) security(5) mechanisms(5) pkix(7) kp(3) id-kp-codeSigning(3)
$rootName = 'PowerShell Local Certificate Root'
$cName = 'PowerShell User'

makecert -n "CN=$rootName" -a $alg `
-eku $oid -sv root.pvk root.cert -r `
-ss Root -sr LocalMachine

makecert -pe -n "CN=$cName" -a $alg `
-eku $oid -iv root.pvk -ic root.cert `
-ss My

Set-AuthenticodeSignature $PROFILE (
    Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert |? Subject -eq "CN=$cName" ) | Out-Null

