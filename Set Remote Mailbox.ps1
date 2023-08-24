$Uname = Read-Host "Please enter username: "

function Set_Remote_Mailbox {
## Getting Exchange credentials
$godCredentials = Get-Credential -Message "Please supply god credentials:"
function checkmailarbfund{
    try{$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri <value> -Authentication Kerberos -Credential $godCredentials
        Import-PSSession $Session -errorAction stop -AllowClobber}
    catch{$godCredentials = Get-Credential
          checkmailarbfund}
}
checkmailarbfund

## Sets the mailbox to remote
Enable-RemoteMailbox $Uname -RemoteRoutingAddress "$Uname@company.com"
Set-RemoteMailbox $Uname -ExchangeGuid (get-remotemailbox $Uname).exchangeguid
}

Set_Remote_Mailbox