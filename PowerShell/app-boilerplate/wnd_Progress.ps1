
# > PowerShell -NoProfile -ExecutionPolicy Bypass -File …

Set-StrictMode -Version:Latest; $ErrorActionPreference = 'Stop'

function rpt_catch ([Management.Automation.ErrorRecord]$err) { Write-Host ('{0}:{1:d4}: {2}' -f $err.InvocationInfo.ScriptName, $err.InvocationInfo.ScriptLineNumber, $err.Exception.Message) }


Add-Type -Ass PresentationFramework
$App = [Windows.Application]::new()

function PumpMessages {
    $App.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{})
}


[xml]$xaml = [io.file]::ReadLines([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand)+'.xaml') `
                        -replace '^<Window.+', '<Window' `
                        -notMatch '^\s+mc:Ignorable="d"$' -notMatch '^\s+xmlns:local="[^"]+"$'

$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)

function Buttons_Enable ($b = $true) {
    $xaml.Window.Grid.Button.Name |% { $MainForm.FindName($_).IsEnabled = $b }
    PumpMessages
}

$ProgressBar = $MainForm.FindName('ProgressBar') # $ProgressBar.Value

$DataGrid = $MainForm.FindName('DataGrid') # $DataGrid.ItemsSource


$MainForm.FindName('btn_A').Add_Click({
    Buttons_Enable $false
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
    sleep 1
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
  }
})


$MainForm.FindName('btn_B').Add_Click({
    Buttons_Enable $false
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
    sleep 1
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
  }
})


$MainForm.FindName('btn_C').Add_Click({
    Buttons_Enable $false
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
  try {
    sleep 1
  } finally {
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
  }
})


$App.add_Exit({ param ( $sender, [Windows.ExitEventArgs]$evtA )
    Write-Host App.OnExit
    $evtA.ApplicationExitCode = 0
})


$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
