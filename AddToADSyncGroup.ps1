###Adds users to the AD Sync Group so they will be replicated###


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