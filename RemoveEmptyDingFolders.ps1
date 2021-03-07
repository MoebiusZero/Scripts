#Get all empty folders
$emptyfolders = Get-ChildItem -Directory E:\RingSecurity\Ding | Where-Object {$_.GetFileSystemInfos().Count -eq 0}

#Delete all folders that are empty
foreach ($emptyfolder in $emptyfolders) { 
    Remove-Item E:\RingSecurity\Ding\$emptyfolder
}