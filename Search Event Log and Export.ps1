#Kaitlin Purdham 2/23/17

#Ask for input and print results
function main {
    while ($true){
        $eventID = Read-Host -Prompt 'Input event ID: '
        $intEventID = [int]$eventID

        try{
            Get-EventLog -log system -InstanceId $intEventID -ErrorAction stop| Export-Csv -path EventLog.csv
            write-host "Event Log succesfully exported to CSV."
            $continue= read-host -prompt 'Would you like to continue? [y/n]'
            if ($continue -eq "y"){
				main
			}
			else{
				exit
			}
        }
        catch [System.Exception]{
            $errorInput = read-host -prompt 'Error: No Matches Found. Would you like to continue? [y/n]'
			if ($errorInput -eq "y"){
				main
			}
			else{
				exit
			}
        }
    }
}

#main program
$host.ui.RawUI.WindowTitle = "Event Log" 
Get-EventLog -log system -Newest 10 | Format-table TimeWritten, InstanceID, Source, Message 

main
