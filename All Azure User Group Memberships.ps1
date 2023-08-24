# Script to use the Get-AzureADUserMembership cmdlet, which only returns direct memberships and also uses easy to identify Group Names instead of gibberish randomized identifiers
# Author: Kaitlin Purdham
# Date: 02FEB2022

#Get date/time
$date = Get-Date -Format "ddMMMyy-hhmm"

#Authenticate with AzureAD
Connect-AzureAD

#Inform user that getting user accounts will take a little bit
Write-Host "Getting all user accounts. This will take a minute..." -ForegroundColor Yellow

#Save list of all user accounts as $AllUsers object
$AllUsers = Get-AzureADUser -All $true | Select UserPrincipalName, ExtensionProperty, MailNickname | Sort-Object UserPrincipalName

#Create empty array to be used later
$Array1 = @()

#Loop through the list of user accounts
foreach ($UPN in $AllUsers) {

    #Inform user which user's groups are being documented
    Write-Host "Documenting group memberships for" $UPN.UserPrincipalName -ForegroundColor Green

    #Save list of user account's direct memberships as $groups object
    $groups = Get-AzureADUserMembership -ObjectId $UPN.UserPrincipalName | where {$_.ObjectType -eq "Group" -and $_.SecurityEnabled -eq $true} | Select DisplayName | Sort-Object DisplayName


    #Loop through the list of groups, appending the CSV file with a row containing the user account and the group that user account is a member of
    foreach ($groupName in $groups) {

        #Create second array to store group name, associated member, username, and EmployeeID
        $Array2 = @{
            UserPrincipalName = $UPN.UserPrincipalName
            Username = $UPN.MailNickName
            EmployeeID = $UPN.ExtensionProperty.employeeId
            Group = $groupName.DisplayName
        }

        #Add Array2 to the .csv file
        $Array1 = New-Object psobject -Property $Array2 | Export-Csv ".\AllUserGroupMemberships-$date.csv" -NoClobber -NoTypeInformation -Append -Force
    }

}

#Inform user that script has completed and where to find it
Write-Host "Script complete. CSV file saved at C:\InfoSec_Audit_Scripts\"