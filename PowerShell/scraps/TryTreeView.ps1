
[Windows.Forms.Application]::EnableVisualStyles()

Add-Type -TypeDefinition @'
using System.Windows.Forms;

public partial class MyTreeView : TreeView
{
    protected override void WndProc(ref Message m)
    {
        if (m.Msg == 0x0203) m.Msg = 0x0201;

        base.WndProc(ref m);
    }
}
'@ -ReferencedAssemblies System.Windows.Forms

