###Put Exchange Servers in Maintenance mode 
###Only applicable to DAG environments!

#Add the Exchange server powershell Module
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Snapin

#Get the name of the domain 
$Getcontroller = Get-ADDomainController
$domain = $Getcontroller.Domain

#Ask for the server which is being serviced
$servicedserver = Read-Host -Prompt 'Input the servername being serviced'

#Ask for the server which will take over the transport roles
$takeoverserver = Read-Host -Prompt 'Input the servername that will take over'

Write-Host 'Enabling Maintenance Mode on' $servicedserver'...'

#Drain all remaining mails on the server
Write-Host 'Draining all mails on the server...'
Set-ServerComponentState $servicedserver -Component HubTransport -State Draining -Requester Maintenance

#Redirect all incoming mails to secondary server
Write-Host 'Redirecting mails...'
Redirect-Message -Server "$servicedserver.$domain" -Target "$takeoverserver.$domain"

#Suspend the server from the DAG
""
Write-Host 'Suspending server...'
Suspend-ClusterNode -Name "$servicedserver"

#Disable Database Copy Protection
""
Write-Host 'Disabling Database Copy Protection...'
Set-MailboxServer $servicedserver -DatabaseCopyActivationDisabledAndMoveNow $true

#Set Auto Activation policy to Blocked
""
Write-Host 'Blocking Auto Activation Policy...'
Set-MailboxServer $servicedserver -DatabaseCopyAutoActivationPolicy Blocked

#Put the server in maintenance mode
""
Write-Host 'Putting Server in maintenance...'
Set-ServerComponentState $servicedserver -Component ServerWideOffline -State InActive -Requester Maintenance
""
Write-Host 'Procedure completed!'
Write-Host 'You may proceed install any updates you may have'
Write-Host 'To disable maintenance mode, please run the proper script to disable it'
cmd /c pause