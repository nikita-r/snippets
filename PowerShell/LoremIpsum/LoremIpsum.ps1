
Add-Type -Ass PresentationFramework
$App = [Windows.Application]::new()

[xml]$xaml = [io.file]::ReadLines([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand)+'.xaml') `
                        -replace '^<Window.+', '<Window'

$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)

$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
