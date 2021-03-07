#Variables for ease of use
$logpath = "E:\Unit4toKing\Logs"
$xmlfiles = "E:\Unit4toKing\XML"
$transformpath = "E:\Unit4toKing\Transform"
$transformweek = "E:\Unit4toKing\Transform\Week"
$transformmonth = "E:\Unit4toKing\Transform\Month"
$transformperiodic = "E:\Unit4toKing\Transform\Periodic"
$importfiles = "\\server\shares\Data\finance\importfiles"
$date = (Get-Date).AddDays(-10).ToString("yyyy-MM-dd")
$currentyear = Get-Date -Format yyyy
$datetoday = Get-Date -Format yyyyMMdd
$importlogfolder = "\\server\shares\Data\finance\importfiles"
$kingjobapp = "C:\Program Files (x86)\King\KingJob.exe"

#Copy .ACS files to log
$testfolderthisyear = Test-Path "$importlogfolder\$currentyear"
$testimportfolder = Test-Path "$importlogfolder\$currentyear\$datetoday Import LJP"

if ($testfolderthisyear -eq $false) {
    New-Item -ItemType "directory" -Path $importlogfolder
}

if ($testimportfolder -eq $false) {
    New-Item -ItemType "directory" -Path "$importlogfolder\$currentyear\$datetoday Import LJP"
}

Copy-Item $importfiles\*.ASC -Destination "$importlogfolder\$currentyear\$datetoday Import LJP"

#Checking if there are UNIT4 week files
$u4weekfiles = Get-ChildItem -Path $importfiles\IJP*W*.ASC

#Rename the week files
    foreach ($u4weekfile in $u4weekfiles) {
        #Get Administration number from the file
        $adminnumber = $u4weekfile.Name.Substring(3,3)

        #Check if the transformation folder for the administration exists
        $transformfolder = Test-Path $transformweek\$adminnumber
        if ($transformfolder -eq $false) {
           New-Item -ItemType "directory" -Path $transformweek\$adminnumber
        }

        $newweekfilename = ("$transformweek\$adminnumber\" + $u4weekfile.BaseName + ".week")
        Move-Item $u4weekfile ($newweekfilename)
    }

#Checking if there are UNIT4 month files
$u4monthfiles = Get-ChildItem -Path $importfiles\IJP*M*.ASC

    #Rename the week files
    foreach ($u4monthfile in $u4monthfiles) {
        Write-Host "renaming month files" 
        #Get Administration number from the file
        $adminnumber = $u4monthfile.Name.Substring(3,3)

        #Check if the transformation folder for the administration exists
        $transformfolder = Test-Path $transformmonth\$adminnumber
        if ($transformfolder -eq $false) {
           New-Item -ItemType "directory" -Path $transformmonth\$adminnumber
        }

        $newmonthfilename = ("$transformmonth\$adminnumber\" + $u4monthfile.BaseName + ".month")
        Move-Item $u4monthfile ($newmonthfilename)
    }

#Checking if there are UNIT4 periodic files
$u4periodicfiles = Get-ChildItem -Path $importfiles\IJP*P*.ASC

#Rename the week files
foreach ($u4periodicfile in $u4periodicfiles) {
    #Get Administration number from the file
    $adminnumber = $u4periodicfile.Name.Substring(3,3)

    #Check if the transformation folder for the administration exists
    $transformfolder = Test-Path $transformperiodic\$adminnumber
    if ($transformfolder -eq $false) {
       New-Item -ItemType "directory" -Path $transformperiodic\$adminnumber
    }

    $newperiodicfilename = ("$transformperiodic\$adminnumber\" + $u4periodicfile.BaseName + ".periodic")
    Move-Item $u4periodicfile ($newperiodicfilename)
}

#Convert all files to XML
$transformedfiles = Get-ChildItem -Path $transformpath -Include *.week, *.month, *.periodic -Recurse

#Convert to XML
foreach ($transformedfile in $transformedfiles) {   
    $volgnummerint = 0
    $adminnumber = $transformedfile.Name.Substring(3,3)   
    
    if ($transformedfile.Name -like "*.week") {
        $XMLpath = switch ($adminnumber) {
                "120" {"$xmlfiles\500-W.xml"; break}
                "160" {"$xmlfiles\510-W.xml"; break}
                "262" {"$xmlfiles\260-W.xml"; break}
                "270" {"$xmlfiles\270-W.xml"; break}
                "280" {"$xmlfiles\280-W.xml"; break}
                "291" {"$xmlfiles\290-W.xml"; break}
                "191" {"$xmlfiles\191-W.xml"; break}
                "231" {"$xmlfiles\231-W.xml"; break}
                "271" {"$xmlfiles\271-W.xml"; break}
                "540" {"$xmlfiles\540-W.xml"; break}
                "550" {"$xmlfiles\550-W.xml"; break}
                "551" {"$xmlfiles\550-W.xml"; break}
                "570" {"$xmlfiles\570-W.xml"; break}
                "571" {"$xmlfiles\570-W.xml"; break}
                "241" {"$xmlfiles\572-W.xml"; break}
                "560" {"$xmlfiles\560-W.xml"; break}
        }
    }

    if ($transformedfile.Name -like "*.month") {
        $XMLpath = switch ($adminnumber) {
                "120" {"$xmlfiles\500-M.xml"; break}
                "160" {"$xmlfiles\510-M.xml"; break}
                "262" {"$xmlfiles\260-M.xml"; break}
                "270" {"$xmlfiles\270-M.xml"; break}
                "280" {"$xmlfiles\280-M.xml"; break}
                "291" {"$xmlfiles\290-M.xml"; break}
                "191" {"$xmlfiles\191-M.xml"; break}
                "231" {"$xmlfiles\231-M.xml"; break}
                "271" {"$xmlfiles\271-M.xml"; break}
                "540" {"$xmlfiles\540-M.xml"; break}
                "550" {"$xmlfiles\550-M.xml"; break}
                "551" {"$xmlfiles\550-M.xml"; break}
                "570" {"$xmlfiles\570-M.xml"; break}
                "571" {"$xmlfiles\570-M.xml"; break}
                "241" {"$xmlfiles\572-M.xml"; break}
                "560" {"$xmlfiles\560-M.xml"; break}
        }
    }

    if ($transformedfile.Name -like "*.periodic") {
        $XMLpath = switch ($adminnumber) {
                "120" {"$xmlfiles\500-P.xml"; break}
                "160" {"$xmlfiles\510-P.xml"; break}
                "262" {"$xmlfiles\260-P.xml"; break}
                "270" {"$xmlfiles\270-P.xml"; break}
                "280" {"$xmlfiles\280-P.xml"; break}
                "291" {"$xmlfiles\290-P.xml"; break}
                "191" {"$xmlfiles\191-P.xml"; break}
                "231" {"$xmlfiles\231-P.xml"; break}
                "271" {"$xmlfiles\271-P.xml"; break}
                "540" {"$xmlfiles\540-P.xml"; break}
                "550" {"$xmlfiles\550-P.xml"; break}
                "551" {"$xmlfiles\550-P.xml"; break}
                "570" {"$xmlfiles\570-P.xml"; break}
                "571" {"$xmlfiles\570-P.xml"; break}
                "241" {"$xmlfiles\572-P.xml"; break}
                "560" {"$xmlfiles\560-P.xml"; break}
        }
    }
            
    #Start Conversion here
    Import-Csv $transformedfile -Header Rekeningnummer,Empty1,Beschrijving,Empty2,Empty3,Valutabedrag,boekzijde | Select-Object -Skip 1 | ForEach-Object {
    #Check if file exists 
    $existingfile = Test-Path $XMLpath -ErrorAction SilentlyContinue
              
    #Increment the Volgnummer   
    $volgnummer = $volgnummerint++ | % tostring 000 

    #Set Boekzijde to correct value
    $boekzijde = Switch ($_.boekzijde)
    {
        C {"CRED"; break}
        D {"DEB"; break}
    }
        
        if ($existingfile -eq $false) {
            #Create a new XML
            $xmlWriter = New-Object System.XMl.XmlTextWriter($XMLpath,$Null)
            $xmlWriter.Formatting = 'Indented'
            $xmlWriter.Indentation = 1
            $XmlWriter.IndentChar = "`t"
            
            $xmlWriter.WriteStartDocument()
            $xmlWriter.WriteComment('Journaalpost Unit4')
            $xmlWriter.WriteStartElement('KING_JOURNAAL')
            $XmlWriter.WriteStartElement('BOEKINGSGANGEN')
            $XmlWriter.WriteStartElement('BOEKINGSGANG')
            $xmlWriter.WriteElementString('BG_OMSCHRIJVING', $_.Beschrijving)
            $xmlWriter.WriteElementString('BG_DEFINITIEF',0)
            $XmlWriter.WriteStartElement('JOURNAALPOSTEN')
            $XmlWriter.WriteStartElement('JOURNAALPOST')
            $xmlWriter.WriteElementString('JP_DAGBOEKCODE','Memo')
            $xmlWriter.WriteElementString('JP_BOEKDATUM', $date)
            $xmlWriter.WriteElementString('JP_OMSCHRIJVING', $_.Beschrijving)
            $XmlWriter.WriteStartElement('JOURNAALREGELS')
            $XmlWriter.WriteStartElement('JOURNAALREGEL')
            $xmlWriter.WriteElementString('JR_VOLGNUMMER', $volgnummer )
            $xmlWriter.WriteElementString('JR_REKENINGNUMMER',$_.Rekeningnummer)
            $xmlWriter.WriteElementString('JR_BOEKZIJDE',$boekzijde)
            $xmlWriter.WriteElementString('JR_VALUTACODE','EUR')
            $xmlWriter.WriteElementString('JR_VALUTABEDRAG',$_.Valutabedrag)
            $xmlWriter.WriteElementString('JR_OMSCHRIJVING', $_.Beschrijving)

            #close all elements
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
                
            #Flush the cache and close writer
            $xmlWriter.Flush()
            $xmlWriter.Close()
        }
        elseif ($appendxml = $true) {
            Rename-Item $xmlpath $xmlpath -ErrorVariable errs -ErrorAction SilentlyContinue
            $inuse = ($errs.Count -ne 0)

            DO {
                Rename-Item $xmlpath $xmlpath -ErrorVariable errs -ErrorAction SilentlyContinue
                $inuse = ($errs.Count -ne 0)
            }
            Until ($inuse -eq $false)
            #Append data to the existing XML
            $xmlDoc = [xml](Get-Content $XMLpath)
            $newNode = $xmlDoc.CreateElement('JOURNAALREGEL')
            $newvolgnr = $xmldoc.CreateElement('JR_VOLGNUMMER')
            $newvolgnr.InnerText = ($volgnummer)
            $newnode.AppendChild($newvolgnr)
            $newrek = $xmldoc.CreateElement('JR_REKENINGNUMMER')
            $newrek.InnerText = ($_.Rekeningnummer)
            $newnode.AppendChild($newrek)
            $newboek = $xmldoc.CreateElement('JR_BOEKZIJDE')
            $newboek.InnerText = ($boekzijde)
            $newnode.AppendChild($newboek)
            $newvalutacode = $xmldoc.CreateElement('JR_VALUTACODE')
            $newvalutacode.InnerText = ('EUR')
            $newnode.AppendChild($newvalutacode)
            $newvalutabedrag = $xmldoc.CreateElement('JR_VALUTABEDRAG')
            $newvalutabedrag.InnerText = ($_.Valutabedrag)
            $newnode.AppendChild($newvalutabedrag)
            $newbeschrijving = $xmldoc.CreateElement('JR_OMSCHRIJVING')
            $newbeschrijving.InnerText = ($_.Beschrijving)
            $newnode.AppendChild($newbeschrijving)
            $xmldoc.KING_JOURNAAL.BOEKINGSGANGEN.BOEKINGSGANG.JOURNAALPOSTEN.JOURNAALPOST.JOURNAALREGELS.AppendChild($newNode)

            $xmlDoc.Save($XMLpath)
        }  
    }
} 

#Start importing into King
#Get all the XML files
$need2import = Get-ChildItem -Path $xmlfiles\*.xml

#Start importing XML's into specific administrations in King
foreach ($importxml in $need2import) {
    $adminnumber = $importxml.BaseName.Substring(0,3)
    $periodtype = $importxml.BaseName.Substring(4,1)

     switch ($periodtype) {
        #If the file is a week file        
        "W" {
                Start-Process $kingjobapp -Argumentlist "EA $adminnumber JOB 10 RUN" -wait
        }    
        #if the file is a month file
        "M" {
                Start-Process $kingjobapp -Argumentlist "EA $adminnumber JOB 11 RUN" -wait
        }
        #if the file is a periodic file
        "P" {
                Start-Process $kingjobapp -Argumentlist "EA $adminnumber JOB 12 RUN" -wait
        }
    }
}

#Check for log files and send e-mail report
  $logpath = Get-ChildItem -path "E:\Unit4toKing\Logs\"
    
#Create the body email
     ForEach ($logfile in $logpath) {
        $filename = $logfile.BaseName
         $logtitle = switch -Wildcard ($filename) {
        "500-W" {"True Title"; break}
        "510-W" {"True Title"; break}
        "260-W" {"True Title"; break}
        "260-M" {"True Title"; break}
        "262-P" {"True Title"; break}
        "270-W" {"True Title"; break}
        "270-M" {"True Title"; break}
        "270-P" {"True Title"; break}
        "280-W" {"True Title"; break}
        "280-M" {"True Title"; break}
        "280-P" {"True Title"; break}
        "290-W" {"True Title"; break}
        "290-M" {"True Title"; break}
        "290-P" {"True Title"; break}
        "191-W" {"True Title"; break}
        "191-W" {"True Title"; break}
        "191-M" {"True Title"; break}
        "231-W" {"True Title"; break}
        "231*M" {"True Title"; break}
        "231*P" {"True Title"; break}
        "271-W" {"True Title"; break}
        "271-M" {"True Title"; break}
        "271-P" {"True Title"; break}
        "540-W" {"True Title"; break}
        "540-M" {"True Title"; break}
        "540-P" {"True Title"; break}
        "550-W" {"True Title"; break}      
        "570-W" {"True Title"; break}
        "570-M" {"True Title"; break}
        "570-P" {"True Title"; break}
        "572-W" {"True Title"; break}
        "572-M" {"True Title"; break}
        "572-P" {"True Title"; break}
        "560-W" {"True Title"; break}
        "560-M" {"True Title"; break} 
        "560-P" {"True Title"; break}


    }        
        $body = $body + "</br><b>$logtitle</b> </br>"
        $logcontent =  (Get-Content $logfile.fullname) -join '<BR>'
        $body = $body + "$logcontent </br>"
        $body = $body + "________________________________________ </br>"
    }

    #Send the mail
    $mailParams = @{ 
    smtpserver       = "(SMTP Server)" 
    Port             = "25"
    UseSSL           = $true
    From             = "(fromemail)" 
    To               = "(toemail)"
    Subject          = "(enter the subject mayby?)" 
    Body             = $body  
    BodyAsHtml       = $true
}

Send-MailMessage @mailParams

#Cleanup
Remove-Item $transformweek\* -Recurse -Force
Remove-Item $transformmonth\* -Recurse -Force
Remove-Item $transformperiodic\* -Recurse -Force
Remove-Item $xmlfiles\* -Recurse -Force
Remove-Item $logpath\* -Recurse -Force