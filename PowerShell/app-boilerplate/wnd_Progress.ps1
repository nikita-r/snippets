
# > PowerShell -NoProfile -ExecutionPolicy Bypass -File …

Add-Type -Ass PresentationFramework
$App = [Windows.Application]::new()
function PumpMessages {
    $App.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{})
}


[xml]$xaml = [io.file]::ReadLines([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand)+'.xaml') `
                        -replace '^<Window.+', '<Window' `
                        -notMatch '^\s+mc:Ignorable="d"$' -notMatch '^\s+xmlns:local="[^"]+"$'

$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)

$ProgressBar = $MainForm.FindName('ProgressBar') # $ProgressBar.Value
$DataGrid = $MainForm.FindName('DataGrid') # $DataGrid.ItemsSource


$MainForm.FindName('btn_A').Add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
  }
})


$MainForm.FindName('btn_B').Add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
  }
})


$MainForm.FindName('btn_C').Add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
  }
})


$App.add_Exit({ param ( $sender, [Windows.ExitEventArgs]$e )
    Write-Host App.OnExit
    $e.ApplicationExitCode = 0
})


$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)


