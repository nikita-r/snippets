rem prof-disk.cmd
fsutil fsinfo ntfsinfo D:

rem https://github.com/microsoft/diskspd/releases/tag/v2.1

diskspd -W0 -d0 -c100G D:\nulful.A.dat > NUL
diskspd -L -D … -Sh … -w20 -rs20 D:\nulful.A.dat > diskspd-L-D…-Sh…-w20-rs20.txt

diskspd -W0 -w100 -z -Zr -d100 -c100G D:\random.B.dat | findstr /c:"random.B.dat (" /i
diskspd -W0 -w100 -z -Zr -d100 -c100G D:\random.C.dat | findstr /c:"random.C.dat (" /i
fc.exe /b D:\random.B.dat D:\random.C.dat | more

rem ZIP
diskspd -L -D -b32K -t1 -o1 -w50 D:\random.B.dat D:\random.C.dat

