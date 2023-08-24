$User = Read-Host "Enter the username"
$ServerList = ('ts1-1','ts1-2','ts1-3','ts1-4','ts1-5','ts1-6','ts1-7','ts1-8','ts1-9','ts1-10','ts1-11','ts1-12','ts1-13','ts1-14','ts1-15','ts1-16','ts1-17','ts1-18','ts1-19','ts1-20','ts1-21','ts1-22','ts1-24','ts1-25', 'ts0-1', 'ts0-2', 'ts0-3', 'ts0-4', 'ts0-5', 'ts0-6', 'ts0-7', 'ts0-8', 'ts0-9')

foreach ($Server in $ServerList) 
{
    $sessionID = ((query user /server:$Server | ? { $_ -match $User }) -split ' +')[3]
        If ($sessionID) 
        {
			Write-Host "$User is logged on $($Server) with ID: $($sessionID)" -ForegroundColor Yellow
        }
        
}
Read-Host "Press ENTER to quit..."