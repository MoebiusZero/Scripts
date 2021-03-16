Clear

Write-host "_______________Windows Migration Script___Version 1.0___________________________"
Write-Host "Before proceeding, make sure the following things have been setup and prepared:"
Write-Host "- Let the user log in once on the new system, this is to create the necessary 
  user folders"
Write-Host "- Both computers have to be online for the migration"
Write-Host "- The user has his own personal network folder on their respective file server 
  (user_home and PST_files), remember to set the correct rights!"
Write-Host "- The script is being run locally on the NEW machine"
Write-Host "- Outlook has to be closed on the old machine to ensure successfull copy 
  of outlook files"
Write-Host "- The ecosetup local admin account should have been created before starting 
  this script"
Write-Host "- Startup Outlook at least once to let the system automatically create the 
   required folders"
Write-Host 
Write-Host "If any of the above conditions are not met, please do so now and then continue 
this script" -ForegroundColor Yellow -BackgroundColor Black
Write-host "________________________________________________________________________________"

#Let user read and wait for user input
cmd /c pause
Clear

#set variables
##User Migration information
Do {
Write-host "__________Windows Migration Script - Select Computers and User Fase_____________"
Do {
$copyfrom = Read-Host 'From which computer should the data be copied from?'
}
 While (!$copyfrom)
Do {
$copyto = Read-Host 'To which computer should the data be copied to?'
}
 While (!$copyto)
 Do {
$copyuserfrom = Read-Host 'Enter userfoldername of the user on the old system (See C:\Users)'
}
 While (!$copyuserfrom)
  Do {
$copyuserto = Read-Host 'Enter userfoldername of the user on the new system (See C:\Users)'
}
 While (!$copyuserto)

#Confirm user input
$title = "Confirm Input"
$message = "Copy data from user $copyuserfrom on $copyfrom to $copyuserto on $copyto ?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "By selecting yes, the script will proceed as planned."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "By selecting no, you will be forced to enter the computernames and user again."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {"Continuing Migration..."}
        1 {
            Clear
            Write-Warning "Please enter computer names again."
          }
    }
}
Until ($result -eq 0)

####################Start Migration#########################
#Start with Desktop
Clear
Do {
Write-host "__________________Windows Migration Script - Migration Fase____________________"
Write-Host "Start Migrating 'Desktop'..." -ForegroundColor "DarkGreen"
$desktoppathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Desktop"
 if ($desktoppathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Desktop\*" -Destination "\\$copyto\C$\Users\$copyuserto\Desktop" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'Desktop' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $deskcopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($deskcopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'Desktop'..."}
                    }
         }
         }
Until ($desktoppathto -eq "True" -Or $deskcopy -eq 1) 
          
                        
#Start with My Documents
Write-Host
Write-host "______________________________________________________________________________"
 $title = "User Documents"
                $message = "Are the user documents still stored locally or are they on a network drive?"
                    $Locally = New-Object System.Management.Automation.Host.ChoiceDescription "&Locally", `
                        "If the documents are stored locally, the script will copy it all to a network drive."
                    $Network = New-Object System.Management.Automation.Host.ChoiceDescription "&Network", `
                        "If the documents are stored on the network, then there is no need to copy files."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($Locally, $Network)
                $doccopy = $host.ui.PromptForChoice($title, $message, $options, 1) 

                switch ($doccopy)
                    {
                        0 { Do {
                                 Write-Host "Start Migrating 'My Documents'..." -ForegroundColor "DarkGreen"
                                 $docpathto = Test-Path "\\$copyto\C$\Users\$copyuserto\documents"
                                 if ($docpathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Documents\*" -Destination "\\server\user_home\$copyuserto" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Will now link the documents folder to the network..."
                                          Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name Personal -Value "\\server\User_home\$copyuserto"
                                          Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Personal -Value "\\server\User_home\$copyuserto"
                          Write-Host "Migration of 'My Documents' complete" -ForegroundColor "DarkGreen" 
                              } 
                        Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $doccopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($doccopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'My Documents'..."}
                    }
         }
         }
                Until ($docpathto -eq "True" -Or $doccopy -eq 1) 
                            }
                        1 { 
                            Write-Host "No Local files to copy... Linking Documents to Network drive."
                            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name Personal -Value "\\server\User_home\$copyuserto"
                            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Personal -Value "\\server\User_home\$copyuserto"
                            Write-Host "Link Complete" -ForegroundColor "DarkGreen" 
                          }
                    }

#Start with My Pictures
Write-Host
Do {
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating 'My Pictures'..." -ForegroundColor "DarkGreen"
$picturepathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Pictures"
 if ($picturepathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Pictures\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Pictures" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'My Pictures' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $piccopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($piccopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'My Pictures'..."}
                    }
         }
         }
Until ($picturepathto -eq "True" -Or $piccopy -eq 1) 
         
#Start with My Music
Write-Host
Do {
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating 'My Music'..." -ForegroundColor "DarkGreen"
$musicpathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Music"
 if ($musicpathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Music\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Music" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'My Music' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $musiccopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($musiccopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'My Pictures'..."}
                    }
         }
         }
Until ($musicpathto -eq "True" -Or $musiccopy -eq 1) 
         
#Start with My Video's
Write-Host
Do {
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating 'My Videos'..." -ForegroundColor "DarkGreen"
$videopathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Videos"
 if ($videopathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Videos\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Videos" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'My Videos' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $videocopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($videocopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'My Videos'..."}
                    }
         }
         }
Until ($videopathto -eq "True" -Or $videocopy -eq 1) 

#Start with Downloads
Write-Host
Do {
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating 'My Downloads'..." -ForegroundColor "DarkGreen"
$downloadpathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Downloads"
 if ($downloadpathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Downloads\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Downloads" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'Downloads' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $downcopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($downcopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'My Downloads'..."}
                    }
         }
         }
Until ($downloadpathto -eq "True" -Or $downcopy -eq 1) 

#Start with Signatures
Write-Host
Write-host "______________________________________________________________________________"
Write-Host "This migrates the users from Outlook 2007 to 2010" -ForegroundColor DarkGreen
 $title = "User Outlook Signatures"
                $message = "Is the user using Outlook 2007 or 2010?"
                    $2007 = New-Object System.Management.Automation.Host.ChoiceDescription "&Microsoft Outlook 2007", `
                        "User is using 2007, script will follow 2007 paths."
                    $2010 = New-Object System.Management.Automation.Host.ChoiceDescription "&Outlook 2010", `
                        "User is using 2010, script will follow 2010 paths."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($2007, $2010)
                $whichversion = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($whichversion)
                    {
                        0 {
                        Write-Host "Start Migrating Outlook 2007 Send History'..." -ForegroundColor "DarkGreen"
                                 $sendhis7path = Test-Path "\\$copyto\C$\Users\$copyuserto\AppData\Roaming\Microsoft\Outlook\outlook.nk2"
                                 if ($sendhis7path -eq "False") {Write-Host "Could not find path"}
                            Else                                 
                                {
                          $sendhischeck7path = Test-Path "\\$copyfrom\C$\Users\$copyuserfrom\Appdata\Roaming\Microsoft\Outlook"
                              If ($sendhischeck7path -eq "False") { mkdir "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Outlook" }
                              Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Outlook\outlook.nk2" -Destination "\\$copyto\\C$\Users\$copyuserto\AppData\Roaming\Microsoft\Outlook" -Recurse -PassThru -ErrorAction INQUIRE
                              Write-Host "Copy of Send History complete, Starting Outlook to import history..."
                              Write-Host "Please do not close Outlook!"
                              Start outlook.exe /importNK2
                              Sleep 20 
                              Stop-Process -Processname Outlook
                              Write-Host "Outlook closed, Import completed, Proceeding with import of Signatures"
                                $sig7pathEN = Test-Path "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Signatures"
                                if ($sig7pathEN -eq "True") {
                              mkdir "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" 2> $NUL
                              Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Signatures\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" -Recurse -PassThru -ErrorAction INQUIRE
                              Write-host "Signature Copy Completed"
                                }
                                Else
                                {
                              $sig7pathNL = Test-Path "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Handtekeningen"
                              if ($sig7pathNL -eq "True") {
                              mkdir "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Handtekeningen" 2> $NUL
                              Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Handtekeningen\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Handtekeningen" -Recurse -PassThru -ErrorAction INQUIRE
                              Write-host "Signature Copy Completed"
                                 }
                         } } }
                        1 { 
                            Write-Host "Start Migrating Outlook 2010 Signatures'..." -ForegroundColor "DarkGreen"
                                $sig10pathEN = Test-Path "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Signatures"
                                if ($sig10pathEN -eq "True") {
                              mkdir "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" 2> $NUL
                              Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Signatures\*" -Destination "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" -Recurse -PassThru -ErrorAction INQUIRE
                              Write-host "Signature Copy Completed"
                          } 
                          Else
                                {
                              $sig10pathNL = Test-Path "\\$copyfrom\C$\Users\$copyuser\AppData\Roaming\Microsoft\Handtekeningen"
                              if ($sig7pathNL -eq "True") {
                              mkdir "\\$copyto\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" 2> $NUL
                              Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\AppData\Roaming\Microsoft\Handtekeningen\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Appdata\Roaming\Microsoft\Signatures" -Recurse -PassThru -ErrorAction INQUIRE
                              Write-host "Signature Copy Completed"

}
                          } 
                          } 
                          }        
                                       
#Start with Internet Explorer Favorites
Write-Host
Do {
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating 'Favorites'..." -ForegroundColor "DarkGreen"
$favoritespathto = Test-Path "\\$copyto\C$\Users\$copyuserto\Favorites"
 if ($favoritespathto -eq "True") {
                          Copy-Item "\\$copyfrom\C$\Users\$copyuserfrom\Favorites\*" -Destination "\\$copyto\\C$\Users\$copyuserto\Favorites" -Recurse -PassThru -ErrorAction INQUIRE
                          Write-Host "Migration of 'Favorites' complete" -ForegroundColor "DarkGreen" 
                              } 
Else {                                                  
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If there is no need or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $favcopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($favcopy)
                    {
                        0 {Write-Warning "Retrying..."}
                        1 {"Skipping migration of 'Favorites'..."}
                    }
         }
         }
Until ($favoritespathto -eq "True" -Or $favcopy -eq 1) 

#Local PST Files
Do {
Write-Host
Write-host "______________________________________________________________________________"
Write-Host "Start Migrating Local PST Files" -ForegroundColor "DarkGreen"
Write-Warning "If the PST files are stored on the user's M:/ drive, there is no need to migrate, type in SKIP when being prompted for a path"
$PSTPath = Read-Host "Where is the PST file located? (Local or UNC paths acceptable)"
    if ($PSTPath -eq "skip") {Write-Host "Skipping Local PST File Migration..."}
        else {
        $PSTDestination = Read-Host "Where should the PST file be stored?"
        $x = Copy-Item "$PSTPath" -Destination "$PSTDestination" -PassThru -ErrorAction INQUIRE
    if ($x) {
             $x
             Write-Host "Migration of Local PST Files complete" -ForegroundColor "DarkGreen"
            }
    else {
                Write-Warning "Copy Failed, check user and computer names and network connections."
                $title = "Retry?"
                $message = "If you changed your mind or if you prefer to do it manually, select No to Skip this part"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the script will retry the copy."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, you will skip this fase and move on to the next one."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $pstcopy = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($pstcopy)
                    {
                        0 {"Retrying..."}
                        1 {"Skipping migration of Local PST Files..."}
                    }
         }}
}
                While ($pstcopy -eq 0)

Clear
Write-host "_____________Windows Migration Script - System Configuration Fase_____________"
Write-Host "Migration of Files has been completed. "
Write-Host "This script will now start system configuration for the user"
Write-host "______________________________________________________________________________"
Write-Host

#Setting up Network Drives
                $title = "Configure Network Drives"
                $message = "Is the user in Gotham, Central City or Metropolis?"
                    $Gotham = New-Object System.Management.Automation.Host.ChoiceDescription "&Gotham", `
                        "This will setup the default drives for Gotham Users."
                    $CCity = New-Object System.Management.Automation.Host.ChoiceDescription "&Central City", `
                        "This will setup the default drives for Central City Users"
                    $Metro = New-Object System.Management.Automation.Host.ChoiceDescription "&Metropolis", `
                        "This will setup the default drives for Metropolis Users."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($Gotham, $CentralCity, $Metropolis)
                $netdrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($netdrive)
                    {
                        0 {
                            Write-Host "Creating network drives for Gotham user..."
                            net use P: \\server\user_home\$copyuserto /persistent:yes
                            net use G: \\server\Data /persistent:yes 
                            net use M: \\server\PST_files\$copyuserto /persistent:yes
                $title = "Central City"
                $message = "Does this user need access to the Central City File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $vardrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($vardrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use V: \\server\Shares\Data /persistent:yes
                            Write-Host "Central City Drive Mapping Complete"
                          }
                        1 {"Ok, No Central City connection needed."}
                    }
                $title = "Metropolis"
                $message = "Does this user need access to the Metropolis File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $maltdrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($maltdrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use I: \\server\Data /persistent:yes
                            Write-Host "Metropolis Server Drive Mapping Complete"
                          }
                        1 {"Ok, No Metropolis connection needed, Network Drive Mapping Complete."}
                    }
                    }
                        1 {
                            Write-Host "Creating network drives for Central City user..."
                            net use P: \\server\Shares\user_home\$copyuserto /persistent:yes
                            net use V: \\server\Shares\Data /persistent:yes
                            net use M: \\server\Shares\PST_files\$copyuserto /persistent:yes
                            $title = "Gotham"
                $message = "Does this user need access to the Gotham File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $zutdrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($zutdrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use G: \\server\Data /persistent:yes
                            Write-Host "Gotham Drive Mapping Complete"
                          }
                        1 {"Ok, No Gotham connection needed."}
                    }
                    $title = "Metropolis"
                $message = "Does this user need access to the Metropolis File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $mostdrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($mostdrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use I: \\server\Data /persistent:yes
                            Write-Host "Metropolis Server Drive Mapping Complete"
                          }
                        1 {"Ok, No Metropolis connection needed, Network Drive Mapping Complete."}
                    }
                    }
                        2 {
                            Write-Host "Creating network drives for Metropolis  user..."
                            net use P: \\server\user_home\$copyuserto /persistent:yes
                            net use I: \\server\Data /persistent:yes
                            net use M: \\sever\PST_files\$copyuserto /persistent:yes
                            $title = "Gotham"
                $message = "Does this user need access to the Gotham File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $zutdrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($zutdrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use G: \\server\Data /persistent:yes
                            Write-Host "Gotham Drive Mapping Complete"
                          }
                        1 {"Ok, no Gotham connection needed."}
                    }
                            $title = "Central City"
                $message = "Does this user need access to the Central City File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $vardrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($vardrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use V: \\server\Shares\Data /persistent:yes
                            Write-Host "Central City Drive Mapping Complete"
                          }
                        1 {"Ok, no Central City connection needed."}
                    }
                    $title = "Columbus"
                $message = "Does this user need access to the Columbus File Server?"
                    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "By selecting Yes, the user will the the drive mapped."
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "By selecting no, no extra drives will be mapped."

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $coldrive = $host.ui.PromptForChoice($title, $message, $options, 0) 

                switch ($coldrive)
                    {
                        0 {
                            Write-Host "Mapping drive..."
                            net use H: \\server\Data\$copyuserto /persistent:yes
                            Write-Host "Columbus Server Drive Mapping Complete"
                          }
                        1 {"Ok, No Columbus connection needed, Network Drive Mapping Complete."}
                    }
                        }
                        }
                   
#Add Printers
Do {
Write-Host
Write-host "______________________________________________________________________________"
$title = "Add Network Printer"
$message = "Where is the printer located?"
    $Gotham = New-Object System.Management.Automation.Host.ChoiceDescription "&Gotham", `
        "Printer is located in Gotham, will connect to the Gotham print server."
    $ccity = New-Object System.Management.Automation.Host.ChoiceDescription "&Central City", `
        "Central City does not have a print server, select this option to know how to install a printer."
    $metro = New-Object System.Management.Automation.Host.ChoiceDescription "&Metropolis", `
        "Printer is located in Metropolis, will connect to the Metropolis print server."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($gotham, $ccity, $metro)
$Printer = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($printer)
    {
        0 {
            Write-Host "Adding printer from the Gotham Print Server..."
            $printername = Read-host "What is the name of the printer"
            $printerpath = "\\server\$printername"
            $net = New-Object -com WScript.Network
            $net.AddWindowsPrinterConnection($PrinterPath)

            $title = "Add more?"
            $message = "$printername has been successfully added, do you want to add more ?"
                $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                    "By selecting yes, the script will proceed as planned."
                $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                    "Ok, stop adding printers."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result3 = $host.ui.PromptForChoice($title, $message, $options, 0) 

            switch ($result3)
                {
                    0 {
                         Clear
                        Write-Warning "Adding another printer..."
                       }
                    1 {"Exiting, add printer fase..."}
                }
               
           }
        1 {
            Write-Host "Adding printer from the Central City Print Server..."
            $printername = Read-host "What is the name of the printer"
            $printerpath = "\\server\$printername"
            $net = New-Object -com WScript.Network
            $net.AddWindowsPrinterConnection($PrinterPath)

            $title = "Add more?"
            $message = "$printername has been successfully added, do you want to add more ?"
                $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                    "By selecting yes, the script will proceed as planned."
                $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                    "Ok, stop adding printers."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result3 = $host.ui.PromptForChoice($title, $message, $options, 0) 

            switch ($result3)
                {
                    0 {
                         Clear
                        Write-Warning "Adding another printer..."
                       }
                    1 {"Exiting, add printer fase..."}
                }
               
           }
        2 {
        Write-Host "Adding printer from the Metropolis Print Server..."
            $printername = Read-host "What is the name of the printer"
            $printerpath = "\\server\$printername"
            $net = New-Object -com WScript.Network
            $net.AddWindowsPrinterConnection($PrinterPath)

            $title = "Add more?"
            $message = "$printername has been successfully added, do you want to add more ?"
                $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                    "By selecting yes, the script will proceed as planned."
                $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                    "Ok, stop adding printers."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result1 = $host.ui.PromptForChoice($title, $message, $options, 0) 

            switch ($result1)
                {
                    0 {
                         Clear
                        Write-Warning "Adding another printer..."
                       }
                    1 {"Exiting, add printer fase..."}
                }}
                }}
                Until ($result1 -or $result3 -eq 1)         

#Invoke config script with local admin credentials
Clear
Write-Host "Finalizing System Configuration..."

#Set Internet Explorer Homepage
Write-Host "Setting Internet Explorer Homepage..."
Write-Host "Configuring Internet Explorer..." -ForegroundColor "DarkGreen"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value 'www.google.nl'
Sleep 2
Write-Host "Internet Explorer Configuration Complete"

$passy = convertto-securestring 'password' -asplaintext -force
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $copyto\Ecosetup,$passy
$process = (Start-Process powershell.exe -ArgumentList "-file .\config-migration.ps1" -Credential $creds -passthru)
    $process.WaitforExit()
    Write-Host "Configuration Completed"
    Sleep 3


#End of Script
Clear
Write-Host "Migration of $Copyuserto to $copyto has been completed" -ForegroundColor "Yellow" -BackgroundColor "Black"
Write-Host "If you would like to migrate another user, please start this script again" -ForegroundColor "Yellow" -BackgroundColor "Black"
            $x = 10
            $length = $x / 100
            while($x -gt 0) {
            $min = [int](([string]($x/60)).split('.')[0])
            $text = " " + $min + " minutes " + ($x % 60) + " seconds left"
            Write-Progress "To complete configuration, the computer will restart in 10 seconds." -status $text -perc ($x/$length)
            start-sleep -s 1
            $x--
            }
shutdown -r -t 0