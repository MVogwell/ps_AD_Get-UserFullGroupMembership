## ps_AD_Get-UserFullGroupMembership.ps1

## What it does...

This script will enumerate the group membership for a selected user including nested groups. It will return a table that displays the group name, nested level (1 is groups directly listed in Active Directory Users and Computers for the selected user, 2 is for groups nested in level 1 groups,3 is for groups nested in level 2 groups and so on) and the group scope (Global, Domain Local, etc).

Note: This will only display Active Directory Security Groups (i.e. it won't display Exchange Distribution Group membership)

## Usage

.\ps_AD_Get-UserFullGroupMembership.ps1 -UserName <Active Directory User Name>

<Active Directory User Name> = A valid Active DIrectory username

## Example 

.\ps_AD_Get-UserFullGroupMembership.ps1 -UserName mvogwell