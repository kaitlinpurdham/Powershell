$CSVFile = import-csv 'C:\temp\SourceFile.csv'
$Counter = $CSVFile.count
foreach($Line in $CSVFile)
{
    $NewColumnValue = 'This is the new column value'
    $Line | Add-Member -NotePropertyName NewColumnName -NotePropertyValue $NewColumnValue
    $Counter = $Counter -1
    Write-Host $Counter
}
$CSVFile | Export-CSV 'c:\temp\ResultFile.csv'