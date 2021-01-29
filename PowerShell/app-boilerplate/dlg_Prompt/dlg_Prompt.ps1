param ( $xaml_file, $ParentWindow )

$dlg_Prompt = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] [xml] [io.file]::ReadLines($xaml_file))
$dlg_Prompt.Owner = $ParentWindow

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

    # …
})

return $dlg_Prompt
