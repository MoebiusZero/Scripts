###Adds users to the AD Sync Group so they will be replicated###

#Get the list of users that needs to be added to the group
$ous = 'LDAP Path 1','LDAP Path 2','LDAP Path 3'
$allusers = $ous | ForEach-Object {Get-ADUser -Filter 'enabled -eq $true' -SearchBase $_ -Properties SamAccountName} | Select SamAccountName

#Add the user to the group
Foreach ($user in $allusers) {
    Add-ADGroupMember -Identity "AzureAD Group" -Members $user.SamAccountName
} 

#Get a list of computers that needs to be added to the group
$allcomputers = Get-ADComputer -LDAPFilter "(name=WS*)" -Properties Name | Select SamAccountName

#Get a list of all laptops that needs to be added to the group
$alllaptops =  Get-ADComputer -LDAPFilter "(name=NB*)" -Properties Name | Select SamAccountName

#Add the systems to the group, first computers then laptops
Foreach ($computer in $allcomputers) {         
        Add-ADGroupMember -Identity "AzureAD Group" -Members $computer.SamAccountName
}

Foreach ($laptop in $alllaptops) {         
        Add-ADGroupMember -Identity "AzureAD Group" -Members $laptop.SamAccountName
}