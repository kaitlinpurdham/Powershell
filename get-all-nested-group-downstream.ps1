function Show-ADGroupTreeViewMembers {

[CmdletBinding(SupportsShouldProcess=$True,
    ConfirmImpact='Medium',
    HelpURI='http://vcloud-lab.com')]
Param
(
    [parameter(Position=0, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, HelpMessage='Type valid AD Group')]
    [alias('Group')]
    [String]$GroupName = 'Domain Admins',
    [parameter(DontShow=$True)]
    [alias('U')]
    $UpperValue = [System.Int32]::MaxValue,
    [parameter(DontShow=$True)]
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
        try {
            $Group =  Get-ADGroup $GroupName -Properties members -ErrorAction Stop 
            $Members = $Group | Select-Object -ExpandProperty members 
            $rootname = $Group.Name
        }
        catch {
            Write-Host -Object "`'$GroupName`' groupname doesn't exist in Active Directory, Please try again." -BackgroundColor DarkRed
            $result = 'Break'
            Break
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
            foreach ($member in $Members) {
                try {
                    $UpperGroup = Get-ADGroup $member -Properties Members, Memberof -ErrorAction Stop
                }
                catch {
                    Continue
                }
                #$LowerGroup = $UpperGroup |
                $LowerGroup = $UpperGroup | Get-ADGroupMember
                $LoopCheck = $UpperGroup.memberof | ForEach-Object {$_ -contains $lowerGroup.distinguishedName}
                if ($LoopCheck -Contains $True) {
                    $rootname = $UpperGroup.Name
                    Write-Host "Loop found on $($UpperGroup.Name), Skipping..." -BackgroundColor DarkRed
                    Continue
                }
                #"xxx $($LowerGroup.name)"
                #$Member
                #"--- $($UpperGroup.Name) `n"
                Show-ADGroupTreeViewMembers -GroupName $member -LowerValue $LowerValue -UpperValue $UpperValue
            } #foreach ($member in $MemberOf) {
        }
    } #Process
}

  Show-ADGroupTreeViewMembers -GroupName Administrators