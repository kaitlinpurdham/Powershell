
import-module exchangeonlinemanagement

$path = "<csv path>"
$doc = import-csv $path 


foreach ($group in $doc){
    $count = 0
    write-host $group.email
    $strgroup = $group.email
    $ADgroup = get-adgroup -filter {mail -eq $strgroup}
    $ADGroupMembers = get-ADGroupMember $adgroup
    foreach ($member in $ADGroupMembers){
        $count = $count+1
    }
    $output = @(
        [pscustomobject]@{
        group = $group.email
        membercount = $count
        }
    )
    $output | export-csv -path <csv path> -Append -Notypeinformation
}