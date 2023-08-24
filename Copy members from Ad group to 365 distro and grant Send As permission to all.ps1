$SourceAD_Group = read-host "Enter source AD group name" 
$Destination_365_Distro = read-host "Enter destination 365 distro name" 
 
$Target = (Get-ADGroupMember -Identity $SourceAD_Group -Recursive | get-aduser -Properties displayname, samaccountname, mail) 
foreach ($Person in $Target) {  
    #Write-Host $person.mail
   # Add-DistributionGroupMember -identity $Destination_365_Distro -member $person.mail  
    Add-RecipientPermission -Identity $Destination_365_Distro -Trustee $person.mail -AccessRights SendAs -Confirm:$false

} 