$path = "<csv path>"


import-csv $path | foreach-object{
    $groupName =  $_.name
    $newGroupName = $_.nameDIST

    $members = get-distributiongroupmember $groupName
    foreach ($member in $members){
        $member = $member.name
        add-DistributionGroupMember $newGroupName -Member $member
    }

}