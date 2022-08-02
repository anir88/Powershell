#Script to consolidate the backups in FTP location

Import-Module -Name PSFTP
#$ftp_server = Read-Host "Please provide the FTP server IP or FQDN"
$ftp_server = Get-Content -Path "$env:USERPROFILE\FTPSERVER.txt"
$retention_date  = $(Get-Date).AddDays(-14)
$temp_var1 = Test-Path -Path "$env:USERPROFILE\MyCreds.xml"
if ($temp_var1 -eq $false) {
    Write-Output "The MyCreds.xml file is missing and needs to be created." | Out-File -FilePath "$env:USERPROFILE\ErrorLog_$(Get-Date -Format dd-MM-yyyy_hh-mm-ss)"
    #Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    #$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop
}
$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop
if ($credentials.Password -eq $null -or $credentials.UserName -eq $null) {
    $user_name = Read-Host "Please enter the username to connect to FTP server"
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}

Set-FTPConnection -Credentials $credentials -Server "ftp://$ftp_server"  -Session FTPSession -UsePassive -ignoreCert | Format-Table
#Remove-FTPItem -Path "ftp://$ftp_server/*" -Session FTPSession | Where-Object {$_.ModifiedDate -lt $retention_date }
$temp_var = Get-FTPChildItem -Path "ftp://$ftp_server" -Session FTPSession | Where-Object {$_.ModifiedDate -lt $retention_date } | Select-Object Name,ModifiedDate | Sort-Object ModifiedDate
foreach ($remove_item in $temp_var.Name) {
    Remove-FTPItem -Path "ftp://$ftp_server/$remove_item" -Session FTPSession | Out-File -FilePath "$env:USERPROFILE\FTPServer_Deleted-Files" -Append
}
Get-FTPChildItem -Path "ftp://$ftp_server" -Session FTPSession | Select-Object Name,ModifiedDate | Sort-Object ModifiedDate | Out-File -FilePath "$env:USERPROFILE\FTPServer_Files"
$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop