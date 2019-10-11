#·startup.py
#$env:PythonStartup=%LocalAppData%\Programs\Python\startup.py

import random; random.seed()

#~|~#

import ctypes
ctypes_FuncPtr_Win32 = [ ('kernel32', 'SetConsoleTitle')
                       #, ('user32', 'FindWindow')
                       #, ('user32', 'SendMessage')
                       , ('user32', 'PostMessage')
                       ]
for FuncPtr_Win32 in ctypes_FuncPtr_Win32:
    locals()[FuncPtr_Win32[1]] = getattr(getattr(ctypes.windll, FuncPtr_Win32[0]), FuncPtr_Win32[1] + 'W')

ShellTitle = "Python" + ' ' + chr(ord('A') + random.randrange(26))
SetConsoleTitle(ShellTitle)

#hwnd = FindWindow(None, ShellTitle)
#SendMessage(hwnd, 0x80, None, None)

PostMessage(ctypes.windll.kernel32.GetConsoleWindow(), 0x80, None, None)

del ShellTitle
for FuncPtr_Win32 in ctypes_FuncPtr_Win32:
    del locals()[FuncPtr_Win32[1]]
del FuncPtr_Win32
del ctypes_FuncPtr_Win32
del ctypes

#~|~#

import json
from types import SimpleNamespace as Sns

def json2Sns(jstr): return json.loads(jstr, object_hook=(lambda dict: Sns(**dict)))

#~|~#

def MyBin(n):
    a = []
    for b in str(n).split('.'):
        b = int(b)
        i = []
        while True:
            i += (f'{b%(1<<8):0>8b}',)
            b //= (1<<8)
            if b == -1: i.append('(−)'); break
            if b == 0: break
        a += (' '.join(reversed(i)),)
    return ' . '.join(a)

#~|~#

