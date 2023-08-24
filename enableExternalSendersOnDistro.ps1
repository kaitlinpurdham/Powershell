$path = "<csv path>"


import-csv $path | foreach-object{
    $groupName =  $_.name
    $newGroupName = $_.nameDIST
    write-host $newGroupName
    get-distributiongroup $newGroupName | set-distributiongroup -requiresenderauthentication $false

}