param ( [switch]$Hide )

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class Win32 {

[DllImport("Kernel32")]
public static extern IntPtr GetConsoleWindow();

[DllImport("User32")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
}
'@

$hWnd = [Win32]::GetConsoleWindow()
[void][Win32]::ShowWindow($hWnd, !$Hide)
