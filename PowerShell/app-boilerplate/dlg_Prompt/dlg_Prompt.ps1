param ( $xaml_file, $ParentWindow )

$ThisDialog = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] [xml] [io.file]::ReadLines($xaml_file))
$ThisDialog.Owner = $ParentWindow

$ThisDialog.Add_KeyDown({ param ($sender, [Windows.Input.KeyEventArgs]$e)
  if ($e.Key -eq 'Escape') {
    $this.DialogResult = $false
  }
})

$ThisDialog.FindName('dlg_Prompt_btn_Okay').Add_Click({

    $txt = $ThisDialog.FindName("dlg_Prompt_txt_A").Text.Trim()
    if ($txt.Length) { Write-Host "Value A: $txt" }

    $txt = $ThisDialog.FindName("dlg_Prompt_txt_B").Text.Trim()
    if ($txt.Length) { Write-Host "Value B: $txt" }

    $txt = $ThisDialog.FindName("dlg_Prompt_txt_C").Text.Trim()
    if ($txt.Length) { Write-Host "Value C: $txt" }

$ThisDialog.DialogResult = $true
})

$ThisDialog.FindName('dlg_Prompt_btn_Cancel').Add_Click({
$ThisDialog.DialogResult = $false
})


function C_premodif_Reset {
}

$ThisDialog.FindName("dlg_Prompt_txt_C").add_DropDownOpened({
  # $text = $this.Text
    $this.SelectedItem = $null
  # $this.Text = $text
    $this.Text = $null
    #$this.SelectAll()
})

$ThisDialog.FindName("dlg_Prompt_txt_C").Add_SelectionChanged({
    C_premodif_Reset

    # previous text: $this.Text
    # new selection: $this.SelectedItem

    if ($this.SelectedItem -ne $null) {
        # new selection via dropdown
    } else {
    }
})

$ThisDialog.FindName("dlg_Prompt_txt_C").ItemsSource = '', 'alpha', 'beta'

$ThisDialog.FindName("dlg_Prompt_txt_C").add_PreviewTextInput({ C_premodif_Reset })

$ThisDialog.FindName("dlg_Prompt_txt_C").add_PreviewKeyDown({ param ($sender, [Windows.Input.KeyEventArgs]$e)
  if ($e.Key -in 'Delete', 'Back', 'Space') {
    C_premodif_Reset
  }
})


return $ThisDialog.ShowDialog()
