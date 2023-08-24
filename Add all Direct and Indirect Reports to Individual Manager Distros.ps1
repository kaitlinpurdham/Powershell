#Created 12/3/2021 by Kaitlin Purdham
#If adding a new manager, first create a new distro in the same name schema.
#Then copy a line from the 'Gather DN's' and 'direc/indirect reports' sections, and replace with new manager's information. Then do the same for the call functions at the bottom.

Clear-Content c:\users\luna\desktop\powershell\ManagementDistro-ActionLog.txt
#Connect Exchange Online
connect-exchangeonline -CertificateThumbprint "" -AppID "" -Organization ""

#Gather DN's
$jimcox = (get-aduser -identity username ).distinguishedname
$jamesprice = (get-aduser -identity username ).distinguishedname
$gayatriraman = (get-aduser -identity username ).distinguishedname
$jodykochanksi = (get-aduser -identity username ).distinguishedname
$subisethi = (get-aduser -identity username ).distinguishedname
$scotterickson = (get-aduser -identity username ).distinguishedname
$cindyblendu = (get-aduser -identity username ).distinguishedname
$anuragsingh = (get-aduser -identity username ).distinguishedname
$susanganeshan = (get-aduser -identity username ).distinguishedname
$joshsullivan = (get-aduser -identity username ).distinguishedname
$souvikdas = (get-aduser -identity username ).distinguishedname

#Gather Direct and Indirect Reports
$JC_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$JC_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$jimcox)").samaccountname

$JP_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$JP_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$jamesprice)").samaccountname

$GR_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$GR_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$gayatriraman)").samaccountname

$JK_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$JK_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$jodykochanksi)").samaccountname

$SS_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$SS_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$subisethi)").samaccountname

$SE_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$SE_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$scotterickson)").samaccountname

$CB_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$CB_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$cindyblendu)").samaccountname

$AS_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$AS_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$anuragsingh)").samaccountname

$SG_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$SG_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$susanganeshan)").samaccountname

$JS_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$JS_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$joshsullivan)").samaccountname

$SD_Direct = (get-aduser -ldapfilter "(manager=$username)").samaccountname
$SD_Indirect = (get-aduser -ldapfilter "(manager:1.2.840.113556.1.4.1941:=$souvikdas)").samaccountname

#Main Function
$groupList = ""
clear-content -path c:\users\luna\desktop\powershell\errorlog.txt
clear-content -path c:\users\luna\desktop\powershell\Actionlog.txt
$errorCatch
$actionLog
function updateMembership($groupname, $direct, $indirect){
    foreach ($report in $direct){
        $ADAccount = get-aduser $report 
        #check if user is disabled
        if ($adaccount.Enabled -Eq $true){
            #convert variables to O365 objects
            try{
                $recipient = get-recipient $report -erroraction stop
                $group = get-group $groupname
                #check if user is already a member of group
                if ($group.Members -notcontains $adaccount.Name){
                    #Remove user from old distos if applicable
                    foreach ($gr in $groupList){
                        $gr=get-group $gr
                        if($gr.Members -contains $adaccount.Name){
                            try{remove-DistributionGroupMember $gr -member $adaccount.userprincipalname -erroraction stop -confirm:$false
                            $actionLog = $actionLog+"`nRemoved "+$report+" from "+$gr}
                            catch{$errorCatch = $errorCatch+"`nFailed to Remove "+$report+" from "+$gr}
                        }
                    }
                    #Add user to new distro
                    Add-DistributionGroupMember $groupname -member $report -erroraction stop
                    $actionLog = $actionLog+"`nAdded "+$report+" to "+$group
                }
            }
            catch{
                $errorCatch = $errorCatch+"`nFailed to add " +$report+" to "+$groupname
            }
        }
    } 
    foreach ($report in $indirect){
        $ADAccount = get-aduser $report 
        #check if user is disabled
        if ($adaccount.Enabled -Eq $true){
            #convert variables to O365 objects
            try{
                $recipient = get-recipient $report -erroraction stop
                $group = get-group $groupname
                #check if user is already a member of group
                if ($group.Members -notcontains $adaccount.Name){
                    #Remove user from old distos if applicable
                    foreach ($gr in $groupList){
                        $gr=get-group $gr
                        if($gr.Members -contains $adaccount.Name){
                            try{remove-DistributionGroupMember $gr -member $adaccount.userprincipalname -erroraction stop -confirm:$false
                            $actionLog = $actionLog+"`nRemoved "+$report+" from "+$gr}
                            catch{$errorCatch = $errorCatch+"`nFailed to Remove "+$report+" from "+$gr}
                        }
                    }
                    #Add user to new distro
                    Add-DistributionGroupMember $groupname -member $report -erroraction stop
                    $actionLog = $actionLog+"`nAdded "+$report+" to "+$group
                }
            }
            catch{
                $errorCatch = $errorCatch+"`nFailed to add " +$report+" to "+$groupname
            }
        }
    } 
    #Send to txt file
    $errorCatch | out-file c:\users\luna\desktop\powershell\errorlog.txt -append
    $actionLog | out-file c:\users\luna\desktop\powershell\ActionLog.txt -append
   
}



#Call Functions For Each Manager
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect
updateMembership username_allreports_dist $username_Direct $username_Indirect

#Send Action Log Email
$date = get-date
    $MailArgs = @{
        'To'          = 'kpurdham@company.com'
        'From'        = 'kpurdham@company.com'
        'Subject'     = "Management Distro List Error Log $date"
        'Attachments' = 'c:\users\luna\desktop\powershell\errorlog.txt','c:\users\luna\desktop\powershell\Actionlog.txt'
        'Body'        = "Error log for $date"

        'SmtpServer'  = 'server.com'
        'Port'        = 25
    }
    Send-MailMessage @MailArgs