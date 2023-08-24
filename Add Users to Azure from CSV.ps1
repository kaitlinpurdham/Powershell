$csv=Get-Content <csv path>

foreach ($line1 in $csv)

{

$Users1=Get-AzureADUser -SearchString $line1

$Users1 | ForEach {Add-AzureADGroupMember -ObjectId <object ID> -RefObjectId $Users1.ObjectID}

}