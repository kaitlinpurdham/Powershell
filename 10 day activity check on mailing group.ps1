import-module psexcel
import-module exchangeonlinemanagement
#connect-exchangeonline 
$path = "<xlsx path>"
$doc = import-xlsx $path -header groupscope, mail, name, lastemailtimestamp, senderaddress, subject, status
add-content -path "<xlsx path>" -Value '"Scope","mail","name","last_email_timestamp","sender_address","subject","status"'


$out = foreach ($group in $doc.mail){
    $scope = $doc.group
    $mail = $doc.mail
    $name = $doc.name
    $lastEmail = get-messagetrace -recipientaddress $group -start "2/18/2022" -end "2/28/2022" | select -First 1
    if ($lastEmail){
        $results = @(
            [pscustomobject]@{
            Scope = $scope
            Mail = $mail
            Name = $name
            last_email_timestamp = $lastemail.received
            sender_address = $lastEmail.senderaddress
            subject = $lastEmail.subject
            status = $lastEmail.status
            }
        )
        $results | export-csv -path <xlsx path> -Append -Notypeinformation
       
    }
    else{
        $results = @(
            [pscustomobject]@{
            Scope = $scope
            Mail = $mail
            Name = $name
            last_email_timestamp = "No email received in last 10 days"
            sender_address = ""
            subject = ""
            status = ""
            }
        )
        $results | export-csv -path <csv path> -Append -Notypeinformation
    }
} 



