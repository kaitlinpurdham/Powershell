#Kaitlin Purdham 2/26/18

#Query by hostname and return IP
function returnIP{
    while($true){
        $hostname = Read-Host -Prompt 'Enter the hostname: '
        try{
            $ip = [system.net.dns]::GetHostAddresses($hostname)
            $recordType = Resolve-DnsName -name $hostname 
            Write-Host "The associated IP address with $hostname is $ip"
            $recordType
            Qcontinue
        }
        catch [System.Exception]{
            $errorInput = read-host -prompt 'Error. Would you like to continue? [y/n]'
            if ($errorInput -eq "y"){
                returnIP
            }
            else{
                exit
            }
        }
    }
}
#Query by IP and return hostname
function returnName{
    while($true){
        $ip = Read-Host -Prompt 'Enter the IP Address: '
        try{
            $hostname = [system.net.dns]::GetHostByAddress($ip).hostname 
            $recordType = Resolve-DnsName -name $hostname 
            Write-Host "The associated hostname with $ip is $hostname"
            $recordType
            Qcontinue
        }
        catch [System.Exception]{
            $errorInput = read-host -prompt 'Error. Would you like to continue? [y/n]'
            if ($errorInput -eq "y"){
                returnName
            }
            else{
                exit
            }
        }
    }
}
function Qcontinue{
    $continueInput = read-host -prompt 'Would you like to continue? [y/n]'
    if ($continueInput -eq "y"){
        main
    }
    else{
        exit
    }
}
function main{ 
    $userInput = read-host -prompt 'Would you like to search by IP or hostname?'
    if ($userInput -eq "ip"){
     returnName
     }
     if ($userInput -eq "hostname"){
     returnIP
     }
     else{
         $errorInput = read-host -prompt 'Error reading input. Would you like to continue? [y/n]'
         if ($errorInput -eq "y"){
             main
         }
         else{
             exit
         }
         
     }
 }
$host.ui.RawUI.WindowTitle = "Query DNS"
main