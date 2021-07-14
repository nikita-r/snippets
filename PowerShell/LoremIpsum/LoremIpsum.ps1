
Add-Type -Ass PresentationFramework
$App = [Windows.Application]::new()

[xml]$xaml = [io.file]::ReadLines([io.path]::GetFileNameWithoutExtension(
                        $MyInvocation.MyCommand) + '.xaml'
                        ) -replace '^<Window.+', '<Window'

$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)

$MainForm.FindName('DataGrid').add_AutoGeneratingColumn({
    param( $o, [Windows.Controls.DataGridAutoGeneratingColumnEventArgs]$e )
    $e.Column.Header = $e.Column.Header -replace '_', '__' # emulate RecognizesAccessKey="False"
})

$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
