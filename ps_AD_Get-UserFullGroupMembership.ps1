########################################
# Active Directory user group enumerator
# MVogwell - 29-05-18
# Version 1.1
#
# This script requires a user to inputted then it returns all groups of which that user is a member including nested groups
#
# ########################################

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$UserName,
    [Parameter(Mandatory=$False)][bool]$ShowNestedGroups = $True
)

Function GetADGroupMembers {
    param ( 
        [string]$GroupName,
        [int]$iNested,
        [ref]$arrResults,
        [bool]$ShowNestedGroups
    )

    $RootGroup = Get-ADGroup -Identity $GroupName -Properties MemberOf
    if($RootGroup.GroupCategory -eq "Security") { 

        $objResults = New-Object -TypeName PSCustomObject
        $objResults | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $RootGroup.Name
        $objResults | Add-Member -MemberType NoteProperty -Name "NestedLevel" -Value $iNested
        $objResults | Add-Member -MemberType NoteProperty -Name "GroupScope" -Value $RootGroup.GroupScope

        $arrResults.value += $objResults

        if($ShowNestedGroups) {
            Foreach ($objADGroupMember in $RootGroup.MemberOf) {
                GetADGroupMembers -GroupName $($objADGroupMember) -iNested ($iNested + 1) -arrResults $arrResults -ShowNestedGroups $True

            }
        }
    }
}

#@# Main

$ErrorActionPreference = "Stop"
$bErrorLoadingADModule = $False

write-host "`n`n########################################" -fore green
write-host "Active Directory user group enumerator" -fore green
write-host "MVogwell - 29-05-18" -fore green
write-host "########################################`n" -fore green

Try { import-module "ActiveDirectory" } catch { $bErrorLoadingADModule = $True ; write-host "Powershell AD Module already imported`n`n" }


If($bErrorLoadingADModule -eq $False) {
    $arrResults = @()
    
    $bGetUserSuccess = $True
    
    Try {
        $objUser = Get-ADUser $UserName -Properties MemberOf
    }
    Catch {
        $bGetUserSuccess = $False
        write-host "$($Error[0].Message)"
    }

    if ($bGetUserSuccess) {
        write-host "`nFull group membership (including nested) for the user: " -NoNewline
        write-host "$($objUser.Name)`n" -fore cyan

        foreach ($objGroup in $($objUser.MemberOf)) {
            GetADGroupMembers -GroupName $objGroup -iNested 1 -arrResults ([ref]$arrResults) -ShowNestedGroups $ShowNestedGroups
        }
    }

    Write-Output $arrResults | ft -auto

    write-host "`nFinished" -fore green
}
