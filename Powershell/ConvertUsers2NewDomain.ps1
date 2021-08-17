#Create log file
$datetoday = (Get-Date).ToString("dd-MM-yyyy")
$logfile = Test-Path "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
if ($logfile -eq $false) { 
    New-item "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt" -ItemType "File" 
} 

#Check if the script is being run on a Domain Controller
$getroles = Get-Wmiobject -Class ‘Win32_computersystem’ -ComputerName $env:computername 
$checkdomainrole = $getrole.domainrole

if ($checkdomainrole -eq '5' -or $checkdomainrole -eq '4') { 
    #Import the AD module
    Import-Module ActiveDirectory

    #Check if the necessary tools have been installed
    $checkinstall = Get-Module -ListAvailable -name MSOnline

    if ($checkinstall -ne $null) {
        Write-Host "Module found, proceeding..."
    }
    elseif ($checkinstall -eq $null) {
        Write-Host "Module not found, installing..."
        Install-module -name MSOnline
    }    

    #Get all users in AD
    try {
        $users = Get-ADUser -filter {enabled -eq $true} -SearchBase (OU HERE) 
    }
    catch { 
        $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
        "$datetimetoday : Unable to get the users" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
        "$datetimetoday : $error[0].Exception.Message" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
    } 

    #Change the UPN of all the users
    foreach ($user in $users) { 
        try {
            $username = $user.SamAccountName
            Set-AdUser -UserPrincipalName "$username@domain.nl" -Identity $username
            $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
            "$datetimetoday : Success! Changed UPN for $username"
        }
        catch { 
            $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
            "$datetimetoday : Unable to change $user.SamAccountName" 
            "$datetimetoday : $error[0].Exception.Message" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
        } 
    } 

    #Get the Credentials for Azure AD
    $credentials = Get-Credential 

    #Connect to Msolservice
    Connect-MsolService -Credential $credentials

    #Get all the users
    $users = Get-MsolUser | where {$_.islicensed -eq $true} 

    #Change all users to the new Domain
    foreach ($user in $users) { 
        $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
        $upn = $user.UserPrincipalName 
        $username = $upn.Split("@")[0]
        try {
            Set-MsolUserPrincipalName -UserPrincipalName $upn -NewUserPrincipalName "$username@domain.nl" 
            $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
            "$datetimetoday : $username has been changed to @domain" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
        }
        catch {
            $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
            "$datetimetoday : Unable to change user to @domain.nl!" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
            "$datetimetoday : $error[0].Exception.Message" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
        }   
    } 
} else { 
    throw "Not running on Domain Controller, is requirement" 
    $datetimetoday = (Get-Date).ToString("dd-MM-yyyy hh:mm:ss")
    "$datetimetoday : Script is not being run on a Domain Controller, Please run this on a domain controller my son" >> "C:\Users\$env:username\Desktop\Conversionlog_$datetoday.txt"
    break
} 