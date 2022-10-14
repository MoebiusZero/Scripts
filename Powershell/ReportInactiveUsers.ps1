#Clear the old files
Remove-Item "C:\Scripts\tempinactief.csv"
Remove-Item "C:\Scripts\inactief.csv"

#Import AD module
Import-Module ActiveDirectory

#Get current month and year
$monthnumber = Get-date -UFormat "%m"
$year = Get-date -UFormat "%Y"
$monthname = (Get-Culture).DateTimeFormat.GetMonthName(06)

#Load required Assemblies
Add-Type -AssemblyName System.web

#Set date variable to check against LastLogon
$lastdays = (get-date).adddays(-30)

#Set file path/name
$file = "C:\Scripts\tempinactief.csv"

#Get list of AD user
Get-ADUser -properties * -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $lastdays) -AND (name -notlike "Exclaimer") -AND (passwordlastset -le $lastdays) -AND (enabled -eq $True) -and (PasswordNeverExpires -eq $false) -and (whencreated -le $lastdays)}| select-object name, SAMaccountname, passwordExpired, @{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv $file

#Create new file
Add-Content -Path "C:\Scripts\inactief.csv" -Value '"Gebruiker","Gebruikersnaam","Laatst Ingelogd"'
$newfile = "C:\Scripts\inactief.csv"

#Create a new list of disabled users and their new passwords
$users = Import-csv $file  | foreach {
    $user = $_.name
    $username = $_.SAMaccountname
    $Lastlogon = $_.LastLogon
    #Generate a random password here
    do {
        $randompass = [System.Web.Security.Membership]::GeneratePassword(8,1)
      } until ($randompass -match '\d')
    $securepass = ConvertTo-SecureString $randompass -AsPlainText -Force

        #Change the user password here
        Set-ADAccountPassword $username -NewPassword $securepass -Reset
        Disable-ADAccount -Identity $username

        $notloggedin = @(
        "$user,$username,$Lastlogon"
        ) 
    Add-Content -Path $newfile -Value $notloggedin
    } 

#Change these parameters to alter the sender/recipients/contents of the E-mail
$to = 'toemail'
$cc = 'ccemail'
$from = 'fromemail'
$subject = "Inactive users"

#Change these parameters to alter table/colors 
$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:RoyalBlue}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:white}"
$a = $a + "</style>"

#DO NOT CHANGE THESE PARAMETERS! Lest thou wantz to break the mail...
##Check if the file is empty or not, send appropiate response mail
Get-ChildItem $newfile | ForEach {

    $check = Import-Csv $_

    If ($check) {
                    $csv = Import-Csv $newfile | Select "Gebruiker","Gebruikersnaam","Laatst Ingelogd" | ConvertTo-Html -head $a -Body "<H2>Inactive users</H2>Users below have not logged in for more than 30 days and have been disabled.<br>De Wachtwoorden zijn gereset en accounts uitgeschakeld.<br>"
                    $emailbody = "$csv"
                    Send-MailMessage -to $to -subject  "Inactieve Gebruikers $monthname $year" -from $from -body $emailbody  -smtpserver (SMTPSERVER) -BodyAsHTML

              }
    Else { 
        $text = ConvertTo-Html -Body "<H2>Inactive users</H2>No inactive users this month"
        $emailbody = "$text"
        Send-MailMessage -to $to -subject -cc $cc "Inactieve Gebruikers $monthname $year" -from $from -body $emailbody  -smtpserver (SMTPSERVER) -BodyAsHTML
        }
} 
