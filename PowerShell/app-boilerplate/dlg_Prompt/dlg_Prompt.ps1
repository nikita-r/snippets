param ( $xaml_file, $ParentWindow )

$dlg_Prompt = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] [xml] [io.file]::ReadLines($xaml_file))
$dlg_Prompt.Owner = $ParentWindow

#$dlg_Prompt.WindowStyle = 'None'
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    public const int GWL_STYLE = -16;
    public const int WS_SYSMENU = 0x80000;
    public const int WS_MINIMIZEBOX = 0x20000;
    public const int WS_MAXIMIZEBOX = 0x10000;
    [DllImport("User32")]
    public static extern IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex);
    [DllImport("User32")]
    public static extern IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);
}
"@
$dlg_Prompt.add_ContentRendered({
    # Remove minimize/maximize/close buttons using Win32 API
    $windowHandle = (New-Object System.Windows.Interop.WindowInteropHelper $this).Handle # $dlg_Prompt is not accessible here as this block is executed within "parent context"
    $style = [Win32]::GetWindowLongPtr($windowHandle, [Win32]::GWL_STYLE)
    $newStyle = $style -bAnd (-bNot ([Win32]::WS_MINIMIZEBOX + [Win32]::WS_MAXIMIZEBOX + [Win32]::WS_SYSMENU))
    [Win32]::SetWindowLongPtr($windowHandle, [Win32]::GWL_STYLE, $newStyle)
})


$dlg_Prompt.add_KeyDown({ param ($sender, [Windows.Input.KeyEventArgs]$e)
  if ($e.Key -eq 'Escape') {
    $this.DialogResult = $false
  }
})

$dlg_Prompt.FindName('dlg_Prompt_btn_Okay').Add_Click({
$dlg_Prompt = [Windows.Window]::GetWindow($this)

    $txt = $dlg_Prompt.FindName("dlg_Prompt_txt_A").Text.Trim()
    if ($txt.Length) { Write-Host "Value A: $txt" }

    $txt = $dlg_Prompt.FindName("dlg_Prompt_txt_B").Text.Trim()
    if ($txt.Length) { Write-Host "Value B: $txt" }

    $txt = $dlg_Prompt.FindName("dlg_Prompt_txt_C").Text.Trim()
    if ($txt.Length) { Write-Host "Value C: $txt" }

$dlg_Prompt.DialogResult = $true
})

$dlg_Prompt.FindName('dlg_Prompt_btn_Cancel').Add_Click({
$dlg_Prompt = [Windows.Window]::GetWindow($this)
$dlg_Prompt.DialogResult = $false
})

$dlg_Prompt.FindName("dlg_Prompt_txt_C").Text = 'αβγδεζηθικλμνξοπρςστυφχψω'
$dlg_Prompt.FindName("dlg_Prompt_txt_C").ItemsSource = $null, 'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'

$dlg_Prompt.FindName("dlg_Prompt_txt_C").Add_SelectionChanged({

    # previous text: $this.Text
    # new selection: $this.SelectedItem

    if ($this.SelectedItem -eq $null) { return }

    <#
    ## • validate value outside of this handler: $_.Text -eq $_.SelectedItem.Content
    ## • provided the item was added programmatically
    ##    $item = New-Object Windows.Controls.ComboBoxItem
    ##    $item.Content = $
    ##    $item.Tag = $
    ##    $_.Items.Add($item) | Out-Null
    #>
})

return $dlg_Prompt
