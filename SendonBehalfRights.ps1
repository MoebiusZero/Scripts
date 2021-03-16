#Check if the necessary tools have been installed
$checkinstall = Get-Module -ListAvailable -name Microsoft.Powershell.Management

    if ($checkinstall -ne $null) {
        Write-Host "Module found, proceeding..."
    }
    elseif ($checkinstall -eq $null) {
        Write-Host "Module not found, installing..."
        Install-module -name ExchangeOnlineManagement
    }

#Import Exchange Online Module
Import-Module ExchangeOnlineManagement

#Set credentials for Exchange Online
$username = "(Username)"
$password = Read-Host "Enter password for your account" -AsSecureString
$credentials = New-Object System.Management.Automation.PsCredential($username, $password)

#Connect to Exchange Online
Connect-ExchangeOnline -Credential $credentials -ShowBanner:$false

Do {    
    #mailbox to apply send-on-behalf rights
    $mailbox = Read-Host "What is e-mailaddress of the mailbox you want Send-On-Behalf rights applied to?"
    $confirmmailbox = Read-Host "Is $mailbox correct? (y/n)"    
} Until ($confirmmailbox -eq 'y')

cls
#Getting list of current rights
Write-Host "Hold on, getting list of currently applied rights. Mayby the user already has been added..." -BackgroundColor Black -ForegroundColor Green
Write-Host "==========================================================" 
Get-Mailbox $mailbox | % {$_.GrantSendOnBehalfto} | ft Name
Write-Host "=========================================================="

Write-Host "You have a list now, do you still need to add people?" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host "Anwser the next few questions to determine which user to give the rights to, use their primary e-mail addresses!" -BackgroundColor Black -ForegroundColor DarkGreen

#Get the emails of the users that need the rights applied
Do { 
$singlemulti = Read-Host "Do you need to enter a single or many users? (s/m)?"
} until ($singlemulti -eq 's' -or $singlemulti -eq 'm') 

    if ($singlemulti -eq 's') {        
        Do {
        $email = Read-Host "Enter e-mailaddress here: "
        $confirmemail = Read-Host "Is $email correct? (y/n)"
        } Until ($confirmemail -eq 'y')

        } elseif ($singlemulti -eq 'm') {      
        Do {
          $email = @()
            Do {        
            $emailinput = Read-Host "Enter e-mailaddress here: "
            $email += $emailinput
            $moremail = Read-Host "Enter more e-mails? (y/n)"
            } Until ($moremail -eq 'n') 
            
            Write-Host "These are the users you have entered:"
            Foreach ($user in $email) {
                Write-Host "- $user"
            }                   
            $confirmusers = Read-Host "Are these correct? (y/n)"                         
        } Until ($confirmusers -eq 'y') 
 }

#Add user(s) to the send-on-behalf list for the given mailbox
if ($singlemulti -eq 's') {
    Get-Mailbox -Identity $mailbox -resultsize unlimited | set-mailbox -GrantSendOnBehalfto @{Add="$email"}
    Write-Host "$email has been added to $mailbox!"
} elseif ($singlemulti -eq 'm') {
    $userlist = $email.Split("`n")
    foreach ($usermail in $userlist) { 
        Get-Mailbox -Identity $mailbox -resultsize unlimited | set-mailbox -GrantSendOnBehalfto @{Add="$usermail"}
        Write-Host "$usermail have been added to $mailbox!"
    }
}

#Disconnect from the session
Disconnect-ExchangeOnline -Confirm:$false

cmd /c pause

