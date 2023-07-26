#Variables for the Json file
$Form = @{ 
    json = Get-Item -Path "C:\Scripts\FireFly Importer\JSON\importconfig.json"
}

#Datetime variable
$timedate = Get-Date -Format "dd/MM/yyyy hh:mm"
$beforedate = Get-Date -Format "yyyy-MM-dd"
$afterdate = (Get-Date).AddDays(-2) 
$newafterdate = Get-Date $afterdate -Format "yyyy-MM-dd"

#Update JSON with new date
$json = Get-Content "C:\Scripts\FireFly Importer\JSON\importconfig.json" -raw | ConvertFrom-Json
$json.date_not_after = $beforedate
$json.date_not_before = $newafterdate
$json | ConvertTo-Json | Set-Content  "C:\Scripts\FireFly Importer\JSON\importconfig.json"

#Webrequest to FireFly Importer
$result = Invoke-WebRequest "http://<ImporterIP:Port>/autoupload?secret=<Importer Secret>" `
-Method "POST" `
-Headers @{'Accept' = 'application/json'; 'Authorization' = 'Bearer <Auth Token>'} `
-Form $Form

#Create temporary output file
$result.Content > "C:\Scripts\FireFly Importer\output.txt"
$contents = (Get-Content "C:\Scripts\FireFly Importer\output.txt") -join '<br>'

#Send E-mail report
$MailMessage = @{
    To = <To Address> 
    From = <From Address>
    Subject = "Imported Transactions from $timedate"
    Body = "<h1>Imported data from $newafterdate to $beforedate </h1><p> $contents"
    Smtpserver = <SMTP Server>
    Port = 25
    BodyAsHtml = $true
    }
Send-MailMessage @MailMessage 

#Delete temporary output file
Remove-Item  "C:\Scripts\FireFly Importer\output.txt"