
# > PowerShell -NoProfile -ExecutionPolicy Bypass -File …

Set-StrictMode -Version:Latest; $ErrorActionPreference = 'Stop'

function report_catch ([Management.Automation.ErrorRecord]$err) {
    Write-Host ('{0}:{1:d4}: {2}' -f $err.InvocationInfo.ScriptName, $err.InvocationInfo.ScriptLineNumber, $err.Exception.Message)
}


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


function Buttons_Enable ($b = $true) {
    $xaml.Window.Grid.Button.Name |% { $MainForm.FindName($_).IsEnabled = $b }
    PumpMessages
}

$xaml.Window.Grid.Button.Name |% { $MainForm.FindName($_).add_Click({
    Buttons_Enable $false
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
}) }

$MainForm.FindName('btn_A').Add_Click({
  try {
    $DataGrid.ItemsSource = $null
    $ProgressBar.Value = $null
    PumpMessages

    $total=32
    1..$total |% { $rows = @() } {
        <# ToDo: actual work instead of #> sleep -mil 100
        $rows += [pscustomobject]@{ Num=$_; Chr=[char]([int][char]'A' + ($_-1)%26); Ord=([int][char]'A' + ($_-1)%26) }
        $ProgressBar.Value = $_ * 100 / $total
        PumpMessages
    } { $DataGrid.ItemsSource = $rows }

    [void][Windows.MessageBox]::Show($this, 'Action Completed', 'ok', 64)
  } catch {
    report_catch $_
    [void][Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$MainForm.FindName('btn_B').Add_Click({
  try {
    $DataGrid.SelectedItems |% { $c = $DataGrid.ItemContainerGenerator.ContainerFromItem($_); $c.Background = '#800000'; $c.Foreground = '#DCDCDC' }
    throw ('In the red now: count=' + $DataGrid.SelectedItems.Count)
  } catch {
    report_catch $_
    [void][Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$MainForm.FindName('btn_C').Add_Click({
  try {
    $DataGrid.ItemsSource = $null
    $ProgressBar.Value = $null
    sleep 1
  } catch {
    report_catch $_
    [void][Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$xaml.Window.Grid.Button.Name |% { $MainForm.FindName($_).add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
}) }


$App.add_Exit({ param ( $sender, [Windows.ExitEventArgs]$evtA )
    Write-Host App.OnExit
    $evtA.ApplicationExitCode = 0
})


$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
