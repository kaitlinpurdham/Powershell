$path = "<csv path>"


import-csv $path | foreach-object{
    $groupName =  $_.name

    $newDistroName = $groupName+"_DIST"
    $newSMTP = $newDistroName+"@company.com"


    #new-distributiongroup -name $newDistroName -primarysmtpaddress $newSMTP
    #get-distributiongroup $newDistroName | set-distributiongroup -RequireSenderAuthenticationEnabled $false

    

    $oldgroup = $_.name + "@company.onmicrosoft.com"
    $oldgroup
    $a = get-distributiongroupmember $oldgroup
    foreach ($member in $a){
        $b = $member.alias
        Add-DistributionGroupMember $newSMTP -Member $b
        }
}