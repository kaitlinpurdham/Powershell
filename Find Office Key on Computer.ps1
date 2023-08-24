#Kaitlin Purdam 2/21/17
$host.ui.RawUI.WindowTitle = "Find Office Key"

$name = Read-Host -Prompt 'Computer name: '
Invoke-Command $name -ScriptBlock {cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus} 