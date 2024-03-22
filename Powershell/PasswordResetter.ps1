#Check if the module is installed
$checkmodule = Get-Module -Name ActiveDirectory
if ($checkmodule -ne $null) {
    Write-Host "Module installed, continuing..." 
} else {
    Write-Host "This Module requires the ActiveDirectory module to get AD users and change passwords, please install it first or run this on a jump server with the Active Directory module" 
} 

#Get all accounts
$accounts = Get-ADUser -filter "samaccountname -like '<accountname>.*'"

#Change these parameters to alter the sender/recipients/contents of the E-mail
$from = 'Password Resetter <itsme@hello.com>'

#Loop through each account and change the password
foreach ($account in $accounts) { 
    
    #Generate a new password
    $number = Get-Random -Minimum 1000 -Maximum 9999
    $password = "Highdidleydoo$number!" 

    #Set the password
    Set-ADAccountPassword -Identity $account.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)   

    #Set the To, CC and BCC for each  account
    switch ($account.name) {
        "Account 1" { 
			#"<e-mail>" for single addresses, @("<email 1>", "<email 2>") for multiple
            $to = "<e-mail>"
            $cc = @("<e-mail>")
            $bcc = @("<e-mail>")
        }           
         default { 
            $to = "<e-mail>"
            $cc = @("<e-mail>")
            $bcc = @("<e-mail>")
         }
    }
    
    #Set the e-mail subject for this account    
    $subject = $Account.name + " password has been reset" 
    $body = "<h2>Password has been reset for " + $account.name + "</h2><br><b>Username: </b>" + $account.samaccountname + "<br><b>Password: </b>$password<br><br>With regards,<br>Your Friendly Neighbourhood IT Department"
    Send-MailMessage -to $to -cc $cc -bcc $bcc -Subject $subject -from $from -Body $body -SmtpServer "<mail-server>" -BodyAsHtml
} 