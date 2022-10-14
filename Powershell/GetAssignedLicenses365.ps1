#Check if the necessary tools have been installed
$checkinstall = Get-Module -ListAvailable -name MSOnline

 

    if ($checkinstall -ne $null) {
        Write-Host "Module found, proceeding..."
    }
    elseif ($checkinstall -eq $null) {
        Write-Host "Module not found, installing..."
        Install-module -name MSonline
    }

#Import the module
Import-Module MSonline

 

#Get all the users and export to an Excel file
$users = Get-MsolUser -All | Where-Object { $_.isLicensed -eq ”TRUE”}
$users | Foreach-Object{
  $licenseDetail = ''
  $licenses=''

  if($_.licenses -ne $null) {
      ForEach ($license in $_.licenses) {
        switch -wildcard ($($license.Accountskuid.tostring())) {
               '*ENTERPRISEPACK' { $licName = 'MS 365 E3' }
               '*STANDARDPACK' { $licName = 'MS 365 E1' }
               default { $licName = $license.Accountskuid.tostring() } 
  }             

  if($licenses){  $licenses = ($licenses + ',' + $licName) } else { $licenses = $licName}
}}

 

New-Object -TypeName PSObject -Property @{   
    UserName=$_.DisplayName 
    IsLicensed=$_.IsLicensed
    Licenses=$licenses
    LicenseDetails=$licenseDetail }
}  | Select UserName,IsLicensed,Licenses,LicenseDetails |

Export-CSV "C:\Licenses.csv" -NoTypeInformation -Encoding UTF8 
