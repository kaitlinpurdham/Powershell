##FUNCTIONS DECLARED FIRST



# Main menu, allowing user selection
function Show-Menu
        {
          param (
                [string]$Title = 'What would you like to do?'
          )
          
          Write-Host "`n`n`n`n================ $Title ================"
            
         Write-Host "1: Press '1' to log off user's TS sessions"
         Write-Host "2: Press '2' to log off user and unmount user's disk"
         Write-Host "3: Press '3' to log off user, unmount disk, and delete disk - WARNING: deletion cannot be undone"
         Write-Host "Q: Press 'Q' to quit."
         }

function Clear-Variables
    {
    $Global:User=$null
    $Global:UserSID=$null
    $DeletePrompt = $null
    $UnmountPrompt = $null
    $DeleteDisk = $null
    $UnmountDisk = $null
    $ChosenUser = $null
    $ChosenServer = $null
    Write-Host "variables cleared"
    }




function Get-Username
#Prompts for input of username
    {
    $global:User = Read-Host "Enter the username"
    }




function Get-UserSID
#Gathers SID for username entered previously
            {
           # Write-Host ("$ User set to $Global:User")
            $Global:UserSID = (get-aduser $Global:User | foreach { $_.SID.value})
           # Write-Host ("$ UserSID set to $Global:UserSID")
            }


function Unmount-Disk
#Opens a remote PowerShell session on TS-Storage1 and unmounts the user's profile disk from any sessions.
    {
    #Open PS Session on ts-storage1
    $s = (New-PSSession -ComputerName ts-storage1)

    #Unmount profile disk
    Invoke-Command -Session $s -ScriptBlock {
                                            (get-smbopenfile | Where-Object -Property ShareRelativePath -like "UVHD-$Using:UserSID.VHDX" | Close-SmbOpenFile)
                                            }
    }

function Delete-ProfileDisk
#Opens a remote PowerShell session on TS-Storage1 again and COMPLETELY DELETES user's profile disk
#Note - this function can only be used AFTER Unmount-Disk
    {
    #Open PS Session on ts-storage1
    $s = (New-PSSession -ComputerName ts-storage1)
    
    #Delete Profile Disk
    Invoke-Command -Session $s -ScriptBlock {
                                             (remove-item -Path "E:\UVHD-$Using:UserSID.VHDX")
                                            }
    }

function Logoff-User
#Logs off any active TS sessions for user - necessary before any changes can be made to profile disks
    {
    $ServerList = ('ts1-1','ts1-2','ts1-3','ts1-4','ts1-5','ts1-6','ts1-7','ts1-8','ts1-9','ts1-10','ts1-11','ts1-12','ts1-13','ts1-14','ts1-15','ts1-16','ts1-17','ts1-18','ts1-19','ts1-21','ts1-22','ts1-24','ts1-25', 'ts0-1', 'ts0-2', 'ts0-3', 'ts0-4', 'ts0-5', 'ts0-6', 'ts0-7', 'ts0-8', 'ts0-9')

    foreach ($Server in $ServerList) 
        {
         write-host "Checking $Server..."
         $sessionID = Get-LoggedInUser -ComputerName $Server | where { $_.username -eq $Global:User } | select-object -ExpandProperty id
         If ($sessionID) 
            {
		    Write-Host "$Global:User is logged on $($Server) with ID: $($sessionID)" -ForegroundColor Yellow
            $ChosenUser = $sessionID
            $ChosenServer=$Server
            }
        }
     If ($ChosenUser -ne $null)
        {
            $LogoffConfirm = Read-Host "Confirmation - are you sure you want to log off $Global:User with ID $ChosenUser from server $ChosenServer ? (Y/N)"
                   write-host $LogoffConfirm
                   If ($LogoffConfirm -eq 'Y'){
                                            Write-Host "Logging off user $Global:User with ID $ChosenUser from server $ChosenServer now."
                                            logoff $chosenuser /server:$chosenServer
                                            }
                   Else{
                        Write-Host "Cancelling - No actions performed."
                        }
        }
    Else
        {
        Write-Host "No sessions found for $Global:User."
        }
    }



function Get-LoggedInUser
{
<#
    .SYNOPSIS
        Shows all the users currently logged in

    .DESCRIPTION
        Shows the users currently logged into the specified computernames

    .PARAMETER ComputerName
        One or more computernames

    .EXAMPLE
        PS C:\> Get-LoggedInUser
        Shows the users logged into the local system

    .EXAMPLE
        PS C:\> Get-LoggedInUser -ComputerName server1,server2,server3
        Shows the users logged into server1, server2, and server3

    .EXAMPLE
        PS C:\> Get-LoggedInUser  | where idletime -gt "1.0:0" | ft
        Get the users who have been idle for more than 1 day.  Format the output
        as a table.

        Note the "1.0:0" string - it must be either a system.timespan datatype or
        a string that can by converted to system.timespan.  Examples:
            days.hours:minutes
            hours:minutes
#>

    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )

    $out = @()

    ForEach ($computer in $ComputerName)
    {
        try { if (-not (Test-Connection -ComputerName $computer -Quiet -Count 1 -ErrorAction Stop)) { Write-Warning "Can't connect to $computer"; continue } }
        catch { Write-Warning "Can't test connect to $computer"; continue }

        $quserOut = quser.exe /SERVER:$computer 2>&1
        if ($quserOut -match "No user exists")
        { Write-Warning "No users logged in to $computer";  continue }

        $users = $quserOut -replace '\s{2,}', ',' |
        ConvertFrom-CSV -Header 'username', 'sessionname', 'id', 'state', 'idleTime', 'logonTime' |
        Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer -PassThru

        $users = $users[1..$users.count]

        for ($i = 0; $i -lt $users.count; $i++)
        {
            if ($users[$i].sessionname -match '^\d+$')
            {
                $users[$i].logonTime = $users[$i].idleTime
                $users[$i].idleTime = $users[$i].STATE
                $users[$i].STATE = $users[$i].ID
                $users[$i].ID = $users[$i].SESSIONNAME
                $users[$i].SESSIONNAME = $null
            }

            # cast the correct datatypes
            $users[$i].ID = [int]$users[$i].ID

            $idleString = $users[$i].idleTime
            if ($idleString -eq '.') { $users[$i].idleTime = 0 }

            # if it's just a number by itself, insert a '0:' in front of it. Otherwise [timespan] cast will interpret the value as days rather than minutes
            if ($idleString -match '^\d+$')
            { $users[$i].idleTime = "0:$($users[$i].idleTime)" }

            # if it has a '+', change the '+' to a colon and add ':0' to the end
            if ($idleString -match "\+")
            {
                $newIdleString = $idleString -replace "\+", ":"
                $newIdleString = $newIdleString + ':0'
                $users[$i].idleTime = $newIdleString
            }

            $users[$i].idleTime = [timespan]$users[$i].idleTime
            $users[$i].logonTime = [datetime]$users[$i].logonTime
        }
        $users = $users | Sort-Object -Property idleTime
        $out += $users
    }
    Write-Output $out
}


#SCRIPT BEGINS HERE

#Clear-Variables
Get-Username



 #Main menu loop
     do
     {
          Show-Menu
          $input = Read-Host "Please make a selection"
          switch ($input)
          {
                '1' {
                     cls
                     Write-Host 'Running "Logoff-User" function...'
                     Logoff-User

                } '2' {
                     cls
                     Write-Host 'Running "Logoff-User" function...'
                     Logoff-User
                     Write-Host 'Running "Get-UserSID" function...'
                     Get-UserSID
                     Write-Host 'Running "Unmount-Disk" function...'
                     Unmount-Disk

                } '3' {
                     cls
                     Write-Host 'Running "Logoff-User" function...'
                     Logoff-User
                     Write-Host 'Running "Get-UserSID" function...'
                     Get-UserSID
                     Write-Host 'Running "Unmount-Disk" function...'
                     Unmount-Disk
                     Write-Host 'Running "Delete-ProfileDisk" function...'
                     Delete-ProfileDisk
         
                } 'q' {
                     return
                }
          }
          pause
     }
     until ($input -eq 'q')
