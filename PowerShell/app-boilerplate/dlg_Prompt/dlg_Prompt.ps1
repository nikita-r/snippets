param ( $xaml_file, $MainWindow )

$ThisDialog = [windows.markup.XamlReader]::Load([xml.XmlNodeReader] [xml] [io.file]::ReadLines($xaml_file))
$ThisDialog.Owner = $MainWindow

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

$ThisDialog.DialogResult = $true
})

$ThisDialog.FindName('dlg_Prompt_btn_Cancel').Add_Click({
$ThisDialog.DialogResult = $false
})

return $ThisDialog.ShowDialog()
