## Getting Service account
$ServiceAccounts = Get-ADUser -Filter * -Properties SAMAccountName -SearchBase "" | Select-Object -ExpandProperty SAMAccountName

## Getting date for export
$date = Get-Date -Format "ddMMMyy-hhmm"

$count = 0

## Getting All groups for each service account
$ServiceAccounts | ForEach-Object {
    ## Getting values
    $dn = (Get-ADUser $_).DistinguishedName
    $groups = Get-ADGroup -LDAPFilter ("(member:1.2.840.113556.1.4.1941:={0})" -f $dn) | select -expand Name | sort Name
    $count += 1

    ## Custom PS Object
    $groupsgroups = [pscustomobject]@{
    groups = (@($groups) -join ',')
    user = $_
    }
        $groupsgroups | Export-Csv C:\InfoSec_Audit_Scripts\ServiceAccountGroups-$date.csv -NoClobber -NoTypeInformation -Append -Force
}

## Writing host to where its exporting
Write-Host "Exporting files to C:\InfoSec_Audit_Scripts\ with count of $count rows"
