$list = import-csv "<csv path>"

foreach ($group in $list){
    disable-distributiongroup $group.email -confirm:$false
}