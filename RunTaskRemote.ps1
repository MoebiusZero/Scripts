###Variables
#Prepare credentials to connect to Servers
$username = "(admin)"
$encrypted = ConvertTo-SecureString "(password)" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)

###Menu Structure
function MainMenu
{
     param (
           [string]$Title = 'Export'
     )
     cls
     Write-Host "================ $Title ================"    
     Write-Host "1: Something"
     Write-Host "2: Another thing"
     Write-Host ""
     Write-Host "Q: Quit"
     Write-Host ""
}

do
{
     MainMenu
     $input = Read-Host "Choose"
     switch ($input)
     {
           '1' {
                  cls                  
                  Invoke-Command -ComputerName '(server)' -ScriptBlock {schtasks /run /tn "(name of task)"} -credential $credential > $null
                  Do {
                    $status =  Invoke-Command -ComputerName '(server)' -ScriptBlock { ((schtasks /query /TN "(name of task")[4] -split ' +')[5] } -credential $credential                    
                  } Until ($status -eq "Ready")
                  Write-Host "DONE!" 
               }              
   
           '2' {
                cls
                $taskstatus =  Invoke-Command -ComputerName '(server)' -ScriptBlock { ((schtasks /query /TN "(name of task")[4] -split ' +')[5] } -credential $credential

                #Check if the task is running, if not run it, else stop it and run again
                If ($taskstatus -eq "Ready") {
                   Write-Host ""
                   Write-Host "Ready to begin" -ForegroundColor Green
                   Invoke-Command -ComputerName '(server)' -ScriptBlock {schtasks /run /tn "(name of task)"} -credential $credential > $null                  
                   pause
                } 
                Elseif ($taskstatus -eq "Running") {
                    Write-Host ""
                    Write-Warning "Task still running, possibly stuck"
                    Invoke-Command -ComputerName '(server)' -ScriptBlock {schtasks /End /tn "(name of task)"} -credential $credential
                    Start-Sleep -s 3
                    Invoke-Command -ComputerName '(server)' -ScriptBlock {schtasks /run /tn "(name of task)"} -credential $credential
                    Write-Host "Task has been restarted"
                    Write-Host ""
                    pause
                }
                else {
                    Write-Warning "Unknown status, please run manually"
                    Write-Host ""
                    pause
                }
     
           } 'q' {
                return
           }
     }
}
until ($input -eq 'q')


