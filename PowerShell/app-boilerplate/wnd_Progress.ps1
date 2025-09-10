#Requires -PSEdition Desktop
#Requires -Version 5.1

$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest

<# Prologue #>

$AppName = [io.path]::GetFileNameWithoutExtension($PSCommandPath)

$SysDir = [Environment]::CurrentDirectory
if ($SysDir -ne (pwd).Path) { throw }

$AppDir = $PSScriptRoot
if ($SysDir -ne $AppDir) { throw }

function report_catch ([Management.Automation.ErrorRecord]$err) {
    Write-Host -ForegroundColor Red `
    ('{0}:{1:d4}: {2}' -f $err.InvocationInfo.ScriptName, $err.InvocationInfo.ScriptLineNumber, $err.Exception.Message)
}

<# init data #>

$AppData = Get-Content "$AppName.json" | ConvertFrom-Json

if ('error' -in ( $AppData.psobject.Properties |% Name )) {
    throw $AppData.error
}

<# init $App #>

Add-Type -Ass PresentationFramework
$App = [Windows.Application]::new()

function PumpMessages {
    $App.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{})
}

$App | Add-Member -MemberType NoteProperty -Name myExitCode -Value 0
$App.add_Exit({ param ( $sender, [Windows.ExitEventArgs]$evtA )
    #Write-Host App.OnExit
    $evtA.ApplicationExitCode = $App.myExitCode
})

# By default, a TextBox restores previous cursor position/selection when Tab is
# used to focus the control; change this behaviour Application-wide as follows:
[Windows.EventManager]::RegisterClassHandler(
    [Windows.Controls.TextBox], [Windows.Controls.TextBox]::GotFocusEvent, [Windows.RoutedEventHandler] {
        param ( $sender, [Windows.RoutedEventArgs]$argsRoutedEvent )
        if ([Windows.Input.Keyboard]::PrimaryDevice.IsKeyDown([Windows.Input.Key]::Tab)) { $sender.SelectAll() }
    }
)
<#~#>


<# init elements of form #>

[xml]$xaml = [io.file]::ReadLines("$AppName.xaml") `
                        -replace '^<Window.+', '<Window' `
                        -notMatch '^\s+mc:Ignorable="d"$' -notMatch '^\s+xmlns:local="[^"]+"$'

$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)

$MainForm.Title = $AppName

<# ToDo: specify which buttons #>
$xName_AllBtn = $xaml.Window.Grid.Button.Name

$ProgressBar, $DataGrid = 'ProgressBar', 'DataGrid' |% { $MainForm.FindName($_) }

$DataGrid.add_AutoGeneratingColumn({
    param( $o, [Windows.Controls.DataGridAutoGeneratingColumnEventArgs]$e )

    $e.Column.IsReadOnly = $e.Column.Header -ne '?'

    #$e.Column.Width = [Windows.Controls.DataGridLength]::new(1, [Windows.Controls.DataGridLengthUnitType]::Star) # proportional
    $e.Column.MaxWidth = 356

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
    } } else {
        $e.Column.MinWidth = 36
    }

    $TyAlign = @{ [int]='Right'; [char]='Center'; }; $Property = 'HorizontalAlignment'
    if ($e.PropertyType -in $TyAlign.Keys) {
        $ns = [Windows.Style]::new($e.Column.ElementStyle.TargetType, $e.Column.ElementStyle)
        $val = ([type]"Windows.$Property")::$($TyAlign[$e.PropertyType])
        $ns.Setters.Add([Windows.Setter]::new([Windows.Controls.TextBlock]::"${Property}Property", $val))
        $e.Column.ElementStyle = $ns
    }
})


<# Application logic begins #>

function Buttons_Enable ($b = $true) {
    $xName_AllBtn |% { $MainForm.FindName($_).IsEnabled = $b }
    PumpMessages
}

$xName_AllBtn |% { $MainForm.FindName($_).add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
    Buttons_Enable $false
}) }

$MainForm.FindName('btn_A').Add_Click({
  try {
    $DataGrid.ItemsSource = $null
    $ProgressBar.Value = $null
    PumpMessages

    $items = [char]'A'..[char]'Z' + 65..70 |% { [char]$_ }

    $items = @($items)
    $total = $items.Count

    if ($total -eq 0) {
        $ProgressBar.Value = 100
        [void] [Windows.MessageBox]::Show('0 items found', $this, 'ok', 64)
        return
    }

    1..$total |% { $dt = [Data.DataTable]::new()

        $dt.Columns.AddRange(@( 'Idx', '?', 'Chr', 'Ord', 'Is_a_Vowel' ))
        'Idx', 'Ord' |% { $dt.Columns[$_].DataType = 'int' }
        'Chr' |% { $dt.Columns[$_].DataType = 'char' }
        'Is_a_Vowel', '?' |% { $dt.Columns[$_].DataType = 'bool' }
    } {
        if ($false) {
            return # %-continue
        } else {
            <# ToDo: actual work instead of #> Start-Sleep -ms 100
        }

        $vow = switch ($items[$_-1]) { default { $false }
              { $_ -in 'yeaiou'.ToCharArray() } { $true }
              { $_ -eq 'w' } { $null } }

        [void] $dt.Rows.Add(@( [int]$_, $null, $items[$_-1], [int]$items[$_-1], $vow ))

        $ProgressBar.Value = 100 * $_ / $total
        PumpMessages

    } { $DataGrid.ItemsSource = $dt.DefaultView }

    #[void] [Windows.MessageBox]::Show($this, 'Action Completed', 'ok', 64)
  } catch {
    report_catch $_
    [void] [Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$MainForm.FindName('btn_B').Add_Click({
  try {
    $r = [Windows.MessageBox]::Show('Really?', 'Are you sure?', 'YesNoCancel', 32)
    if ($r -cne 'Yes') { return }
    [void] [Windows.MessageBox]::Show('Not Implemented', 'Expected Error', 'ok', 48)
    $DataGrid.SelectedItems |% { $c = $DataGrid.ItemContainerGenerator.ContainerFromItem($_); $c.Background = '#800000'; $c.Foreground = '#DCDCDC' }
    throw ('In the red now: count=' + $DataGrid.SelectedItems.Count)
  } catch {
    report_catch $_
    [void] [Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$MainForm.FindName('btn_C').Add_Click({
  try {
    $dlg = & ./dlg_Prompt/dlg_Prompt.ps1 ./dlg_Prompt/dlg_Prompt.xaml ([Windows.Window]::GetWindow($this))
    $r = $dlg.ShowDialog()
    if (-not $r) { return }

    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
    PumpMessages

    $DataGrid.ItemsSource = $null
    $ProgressBar.Value = $null

    sleep 1
  } catch {
    report_catch $_
    [void] [Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$xName_AllBtn |% { $MainForm.FindName($_).add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
}) }


<# menu items events #>

$MainForm.FindName('Grid_Menu_Exit_1').add_Click({
    $App.myExitCode=1
    $MainForm.Close()
})

$MainForm.FindName('DataGrid_Menu_Colour').Items.add_Click({
    $DataGrid.SelectedItems |% { $c = $DataGrid.ItemContainerGenerator.ContainerFromItem($_); $c.Background = $this.Header }
})


<# Main.Run #>

$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host "ApplicationExitCode=$ExitCode"
exit $ExitCode
