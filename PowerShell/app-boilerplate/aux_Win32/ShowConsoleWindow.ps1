param ( [switch]$Hide )

$src = @'
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'@

Add-Type -Name Bar -Namespace Foo -MemberDefinition $src

$hWnd = [Foo.Bar]::GetConsoleWindow()
[void][Foo.Bar]::ShowWindow($hWnd, !$Hide)
