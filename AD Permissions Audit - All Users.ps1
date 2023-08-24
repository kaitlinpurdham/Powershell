# Script to use the Get-AzureADUserMembership cmdlet, which only returns direct memberships and also uses easy to identify Group Names instead of gibberish randomized identifiers
# Jira case:  
# Author: Kaitlin Purdham
# Date: 21JUN2021

#Authenticate with AzureAD
Connect-AzureAD

#Get date/time
$date = Get-Date -Format "ddMMMyy-hhmm"

#Set count 0
$Count = 0

#Inform user that getting user accounts will take a little bit
Write-Host "Getting all user accounts. This will take a minute..." -ForegroundColor Green

#Save list of all user accounts as $AllUsers object
$AllUsers = Get-AzureADUser -All $true | Select UserPrincipalName | Sort-Object UserPrincipalName

#Create empty array to be used later
$Array1 = @()

#Loop through the list of user accounts
foreach ($UPN in $AllUsers) {
    #Trim unneeded data off of user account's UPN
    $UPN = "$UPN".TrimEnd('}')
    $UPN = "$UPN".TrimStart('@{UserPrincipalName')
    $UPN = "$UPN".TrimStart('=')

    #Inform user which user's groups are being documented
    Write-Host "Documenting group memberships for $UPN" -ForegroundColor Yellow

    #Save list of user account's direct memberships as $groups object
    $groups = Get-AzureADUserMembership -ObjectId $UPN | Select DisplayName | Sort-Object DisplayName

    #Return username of account
    $Username = Get-AzureADUser -ObjectId $UPN | Select mailNickname

    #Trim unneeded data off of the username
    $Username = "$Username".TrimEnd('}')
    $Username = "$Username".TrimStart('@{MailNickName')
    $Username = "$Username".TrimStart('=')


    #Use on-prem Get-ADUser cmdlet to return EmployeeID
    $EmployeeID = Get-ADUser -Identity $Username -Properties employeeID | Select employeeID

    #Trim unneeded data off of the group's name
    $EmployeeID = "$EmployeeID".TrimEnd('}')
    $EmployeeID = "$EmployeeID".TrimStart('@{employeeID')
    $EmployeeID = "$EmployeeID".TrimStart('=')


    #Loop through the list of groups, appending the CSV file with a row containing the user account and the group that user account is a member of
    foreach ($groupName in $groups) {
        #Trim unneeded data off of group's name
        $groupName = "$groupName".TrimEnd('}')
        $groupName = "$groupName".TrimStart('@{DisplayName')
        $groupName = "$groupName".TrimStart('=')

        #Create second array to store group name, associated member, username, and EmployeeID
        $Array2 = @{
            UserPrincipalName = $UPN
            Username = $Username
            EmployeeID = $EmployeeID
            Group = $groupName
        }

        #Add Array2 to the .csv file
        $Array1 = New-Object psobject -Property $Array2 | Export-Csv "C:\InfoSec_Audit_Scripts\AllUserGroupMemberships-$date.csv" -NoClobber -NoTypeInformation -Append -Force
    }

#Set EmployeeID to "{None}" until next account is loaded
$EmployeeID = "{None}"    

#iterate the count
$Count += 1
}

#Inform user that script has completed and where to find it
Write-Host "Script complete. CSV file saved at C:\InfoSec_Audit_Scripts\ with count of $Count rows"