
#
function Get-ADGroupTreeViewMemberOf {

[CmdletBinding(SupportsShouldProcess=$True,
    ConfirmImpact='Medium',
    HelpURI='http://vcloud-lab.com',
    DefaultParameterSetName='User')]
Param
(
    [parameter(ParameterSetName = 'User',Position=0, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, HelpMessage='Type valid AD username')]
    [alias('User')]
    [String]$UserName = 'Administrator',
    [parameter(ParameterSetName = 'Group',Position=0, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, HelpMessage='Type valid AD Group')]
    [alias('Group')]
    [String]$GroupName = 'Domain Admins',
    [parameter(ParameterSetName = 'Group', DontShow=$True)]
    [parameter(ParameterSetName = 'User', DontShow=$True)]
    [alias('U')]
    $UpperValue = [System.Int32]::MaxValue,
    [parameter(ParameterSetName = 'Group', DontShow=$True)]
    [parameter(ParameterSetName = 'User', DontShow=$True)]
    [alias('L')]
    $LowerValue = 2
)
    begin {
        if (!(Get-Module Activedirectory)) {
            try {
                Import-Module ActiveDirectory -ErrorAction Stop 
            }
            catch {
                Write-Host -Object "ActiveDirectory Module didn't find, Please install it and try again" -BackgroundColor DarkRed
                Break
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'Group' {
                try {
                    $Group =  Get-ADGroup $GroupName -Properties Memberof -ErrorAction Stop 
                    $MemberOf = $Group | Select-Object -ExpandProperty Memberof 
                    $rootname = $Group.Name
                }
                catch {
                    Write-Host -Object "`'$GroupName`' groupname doesn't exist in Active Directory, Please try again." -BackgroundColor DarkRed
                    $result = 'Break'
                    Break
                }
                break            
            }
            'User' {
                try {
                    $User = Get-ADUser $UserName -Properties Memberof -ErrorAction Stop
                    $MemberOf = $User | Select-Object -ExpandProperty Memberof -ErrorAction Stop
                    $rootname = $User.Name
                    
                }
                catch {
                    Write-Host -Object "`'$($User.Name)`' username doesn't exist in Active Directory, Please try again." -BackgroundColor DarkRed
                    $result = 'Break'
                    Break
                }
                Break
            }
        }
    }
    Process {
        $Minus = $LowerValue - 2
        $Spaces = " " * $Minus
        $Lines = "__"
        "{0}{1}{2}{3}" -f $Spaces, '|', $Lines, $rootname        
        $LowerValue++
        $LowerValue++
        if ($LowerValue -le $UpperValue) {
            foreach ($member in $MemberOf) {
                $UpperGroup = Get-ADGroup $member -Properties Memberof
                $LowerGroup = $UpperGroup | Get-ADGroupMember
                $LoopCheck = $UpperGroup.MemberOf | ForEach-Object {$lowerGroup.distinguishedName -contains $_}
            
                if ($LoopCheck -Contains $True) {
                    $rootname = $UpperGroup.Name
                    Write-Host "Loop found on $($UpperGroup.Name), Skipping..." -BackgroundColor DarkRed
                    Continue
                }
                #"xxx $($LowerGroup.name)"
                #$Member
                #"--- $($UpperGroup.Name) `n"
                Get-ADGroupTreeViewMemberOf -GroupName $member -LowerValue $LowerValue -UpperValue $UpperValue
            } #foreach ($member in $MemberOf) {
        }
    } #Process
}
#Get-ADGroupTreeViewMemberOf -groupname a1
#Get-ADGroupTreeViewMemberOf -UserName user2
#Get-ADGroupTreeViewMemberOf -UserName user1