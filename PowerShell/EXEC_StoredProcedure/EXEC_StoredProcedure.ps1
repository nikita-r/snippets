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
    $evtA.ApplicationExitCode = $App.myExitCode
})


<# init elements of form #>

[xml]$xaml = [io.file]::ReadLines("$AppName.xaml")
$MainForm = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] $xaml)
#$MainForm.Title = $AppName

$btnAll = 'btn_ExecProc', 'btn_EchoFold'

$txtAll = @(
        'txt_argNum'
        'txt_argA'
        'txt_utcDateTime'
        'txt_host'
        'txt_user'
        )

foreach ($txt in $txtAll) {
    $txtBox = $MainForm.FindName($txt)
    $txtBox.Text = switch ($txt) {
        'txt_argNum' { 0 }
        'txt_argA' { '' }
        'txt_utcDateTime' { (Get-Date (Get-Date).ToUniversalTime() -f s) + 'Z' }
        'txt_host' { [net.dns]::GetHostName() }
        'txt_user' { "$env:UserDomain\$env:UserName" }
        default { throw }
    }
    $txtBox.SelectionStart = 0
    $txtBox.SelectionLength = [int]::MaxValue
}


<# init SQL #>

Write-Host "Connecting... to $($AppData.cnxnStr -split ';' | ConvertFrom-StringData |? { 'Server' -in $_.Keys } |% { $_['Server'] }):1433"
$cnxn = New-Object Data.SqlClient.SqlConnection $AppData.cnxnStr

Write-Host ('SQL Server Connection Timeout=' + $cnxn.ConnectionTimeout)

$spName = 'StoredProcedure'


<# Application logic begins #>

function Buttons_Enable ($b = $true) {
    $btnAll |% { $MainForm.FindName($_).IsEnabled = $b }
    PumpMessages
}

$btnAll |% { $MainForm.FindName($_).add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Wait
    Buttons_Enable $false
}) }

$MainForm.FindName('btn_ExecProc').Add_Click({
  try {
    foreach ($f in 'argA', 'utcDateTime', 'host', 'user') {
        if ([string]::IsNullOrWhiteSpace($MainForm.FindName("txt_$f").Text)) {
            [void][Windows.MessageBox]::Show("Cannot be empty: $f", 'Invalid Input', 'ok', 16)
            return
        }
    }

    foreach ($f in 'argNum') {
        if (-not (0 + $MainForm.FindName("txt_$f").Text -gt 0)) {
            [void][Windows.MessageBox]::Show("${f}: must be greater than 0", 'Invalid Input', 'ok', 16)
            return
        }
    }

    $cmd = [Data.SqlClient.SqlCommand]::new($spName, $cnxn)
    $cmd.CommandType = [Data.CommandType]::StoredProcedure

    ($Return = $cmd.Parameters.Add('@ReturnValue', [Data.SqlDbType]::Int)).Direction = [Data.ParameterDirection]::ReturnValue

    $cmd.Parameters.Add('@argNum', [Data.SqlDbType]::Int).Value = $MainForm.FindName('txt_argNum').Text
    $cmd.Parameters.Add('@argA', [Data.SqlDbType]::NVarChar).Value = $MainForm.FindName('txt_argA').Text
    $cmd.Parameters.Add('@utcDateTime', [Data.SqlDbType]::DateTime).Value = (Get-Date $MainForm.FindName('txt_utcDateTime').Text).ToUniversalTime()
    $cmd.Parameters.Add('@host', [Data.SqlDbType]::VarChar).Value = $MainForm.FindName('txt_host').Text
    $cmd.Parameters.Add('@user', [Data.SqlDbType]::VarChar).Value = $MainForm.FindName('txt_user').Text

    if ($cnxn.State -ne 1) { $cnxn.Open(); Write-Host ('SQL Server Connection re-opened') -fore DarkGray }

    Write-Host "EXEC $spName $($cmd.Parameters |% { $_.ToString() + '=' + $_.Value })"
    $rdr = $cmd.ExecuteReader()
    while ($rdr.Read()) {
        Write-Host ('Error ' + $rdr['ErrorNum'].ToString('00') + ': ' + $rdr['ErrorStr']) -fore Red
    }
    $rdr.Close()
    Write-Host ('ReturnValue=' + $Return.Value + '; ' + 'RecordsAffected=' + $rdr.RecordsAffected)

    Write-Host 'EXEC completed!' -fore DarkMagenta
  } catch {
    report_catch $_
    [void][Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$MainForm.FindName('btn_EchoFold').Add_Click({
  try {
    #[void][Windows.MessageBox]::Show('Not Implemented', 'Expected Error', 'ok', 48)
    Write-Host ('_' * $host.UI.RawUI.WindowSize.Width)
  } catch {
    report_catch $_
    [void][Windows.MessageBox]::Show('Exception caught!' + "`n"*2 + $this, 'Unexpected Error', 'ok', 16)
  }
})

$btnAll |% { $MainForm.FindName($_).add_Click({
    $MainForm.Cursor = [Windows.Input.Cursors]::Arrow
    Buttons_Enable
}) }


<# menu items events #>

$MainForm.FindName('Grid_Menu_Exit_1').add_Click({
    $App.myExitCode=1
    $MainForm.Close()
})


<# Main.Run #>

$App.ShutdownMode = 'OnMainWindowClose'
$ExitCode = $App.Run($MainForm)
Write-Host ('App.ExitCode='+$ExitCode)
exit $ExitCode
