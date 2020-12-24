<#
.Synopsis
    A boilerplate WPF application for launching long-running tasks in PowerShell.
    Task to be executed on the UI thread, but UI may be updated via PumpMessages.
.Description
    Cannot be launched from ISE.
#>

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

$DataGrid.add_AutoGeneratingColumn({
    param( $o, [Windows.Controls.DataGridAutoGeneratingColumnEventArgs]$e )

    $e.Column.IsReadOnly = $e.Column.Header -ne '?'

    $e.Column.Header = $e.Column.Header -replace '_', '__' # emulate RecognizesAccessKey="False"
<#
    if ($e.PropertyType -eq [Boolean]) {
        $e.Cancel = $true
    }
#>
    if ($e.Column -is [Windows.Controls.DataGridCheckBoxColumn]) {
    # # $e.Column.ElementStyle = $this.FindResource([Windows.Controls.CheckBox])
    #
    # CheckBox in an auto-generated column does not pick up user-defined Style.
    # Instead, it creates its own "default" style which we will try and modify.
    #
    foreach ($Editing in '', 'Editing') {
        $ns = [Windows.Style]::new($e.Column."${Editing}ElementStyle".TargetType, $e.Column."${Editing}ElementStyle")
        $p = ( $e.Column."${Editing}ElementStyle".Setters.Property |? Name -eq 'VerticalAlignment' )
        $ns.Setters.Add([Windows.Setter]::new($p, [Windows.VerticalAlignment]::Center))
        $ns.Setters.Add([Windows.Setter]::new(    [Windows.Controls.CheckBox]::FocusVisualStyleProperty
                                             ,  $MainForm.FindResource('custom_FocusVisualStyle') ))
        $e.Column."${Editing}ElementStyle" = $ns
    } }

    $TyAlign = @{ [int]='Right'; [char]='Center'; }; $Property = 'HorizontalAlignment'
    if ($e.PropertyType -in $TyAlign.Keys) {
        $ns = [Windows.Style]::new($e.Column.ElementStyle.TargetType, $e.Column.ElementStyle)
        $val = ([type]"Windows.$Property")::$($TyAlign[$e.PropertyType])
        $ns.Setters.Add([Windows.Setter]::new([Windows.Controls.TextBlock]::"${Property}Property", $val))
        $e.Column.ElementStyle = $ns
    }
})


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

    <# ToDo: fetch items #> $items = $null
    $items = @($items)
    $total = $items.Count
    <# ToDo: use real number instead of #> $total=32

    if ($total -eq 0) {
        $ProgressBar.Value = 100
        [void][Windows.MessageBox]::Show('0 items found', $this, 'ok', 64)
        return
    }

    1..$total |% { $dt = [Data.DataTable]::new()

        $dt.Columns.AddRange(@( 'Idx', '?', 'Chr', 'Ord', 'Is_a_Vowel' ))
        'Idx', 'Ord' |% { $dt.Columns[$_].DataType = 'int' }
        'Chr' |% { $dt.Columns[$_].DataType = 'char' }
        'Is_a_Vowel', '?' |% { $dt.Columns[$_].DataType = 'bool' }
    } { <# ToDo: actual work instead of #> sleep -mil 100

        $ord = ([int][char]'A' + ($_-1)%26)
        $vow = switch ([char]$ord) { default { $false }
            { $_ -in 'yeaiou'.ToCharArray() } { $true }
            { $_ -eq 'w' } { $null } }
        [void]$dt.Rows.Add(@( [int]$_, $null, [char]$ord, $ord, $vow ))

        $ProgressBar.Value = 100 * $_ / $total
        PumpMessages

    } { $DataGrid.ItemsSource = $dt.DefaultView }

    #[void][Windows.MessageBox]::Show($this, 'Action Completed', 'ok', 64)
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
    $r = [Windows.MessageBox]::Show('Are you sure?', ('Confirm [ {0} ]' -f $this.Content), 'okcancel', 32)
    if ($r -ne 'ok') { return }

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


$MainForm.FindName('Grid_Menu_Exit').add_Click({
    $MainForm.Close()
})

$MainForm.FindName('DataGrid_Menu_Colour').Items.add_Click({
    $DataGrid.SelectedItems |% { $c = $DataGrid.ItemContainerGenerator.ContainerFromItem($_); $c.Background = $this.Header }
})


$App.add_Exit({ param ( $sender, [Windows.ExitEventArgs]$evtA )
    Write-Host App.OnExit
    $evtA.ApplicationExitCode = 0
})


$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
