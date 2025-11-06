#Get the current system local
$locale = Get-WinSystemLocale

#Set language variables based on detected system local
Switch ($locale) {
    "nl-NL" {$sleepafter = "Slaapstand na" 
             $turnoffdisplay = "Beeldscherm uitschakelen na"
            }

    "en-US" {$sleepafter = "Sleep after" 
             $turnoffdisplay = "Turn off display"
            }

    "pl-PL" {$sleepafter = "Upij po" 
             $turnoffdisplay = "WyĄcz ekran po"
            }

    "de-DE" {$sleepafter = "Deaktivierung nach" 
             $turnoffdisplay = "Bildschirm ausschalten nach"
            }

    "cs-CZ" {$sleepafter = "Re§im sp nku za" 
             $turnoffdisplay = "Vypnout obrazovku po"
            }
} 

#Get the display power settings
$querydisplaysettings = powercfg -q | Select-String -context 0,7 $turnoffdisplay
$stringdisplaysettings = $querydisplaysettings.toString()

#Get the device sleep setting
$querysleepsettings = powercfg -q | Select-String -context 0,7 $sleepafter
$stringsleepsettings = $querydisplaysettings.toString()

#Split the data into multiple lines and put it in a array
[array]$displaysettingsarray = $stringdisplaysettings.Split("`n") | Where-Object {$_.Trim("")}
[array]$sleepsettingsarray = $stringsleepsettings.Split("`n") | Where-Object {$_.Trim("")}

#Display Settings
Foreach ($displaysetting in $displaysettingsarray) { 
    switch -Wildcard ($displaysetting) { 
        "*Current AC Power Setting Index: 0x0000012c*" { powercfg /change monitor-timeout-ac 30 }
        "*Current DC Power Setting Index: 0x000000b4*" { powercfg /change monitor-timeout-dc 15 }  
    } 
} 

#Sleep Settings
Foreach ($sleepsetting in $sleepsettingsarray) { 
    switch -Wildcard ($sleepsetting) { 
       "*Current AC Power Setting Index: 0x0000012c*"  { powercfg /change standby-timeout-ac 0 }
       "*Current DC Power Setting Index: 0x000000b4*"  { powercfg /change standby-timeout-dc 30 }    
    } 
} 

#Change Lid Close Action
#Pressing the power button 
powercfg -SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg -SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3

#Pressing the sleep button
powercfg -SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 1
powercfg -SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 1

#Close Lid
powercfg -SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
