#Script to list the contents of the FTP sites and delete the items older than 14 days

@"
===============================================================================
Title: 			FTP_Backup_Consolidation_v2.ps1
Description: 	Delete files on the FTP location beyond certain age i.e. 14 days
Requirements: 	Windows Powershell and the Netapp Powershell Toolkit
Author: 		Anirban Dutta Gupta
Developed For: NetApp GSSC MS Team
Disclaimer: This is a scheduled run time task being executed. Please refer to the generated log files for details
Log Files: USERPROFILE\FTPServer_Files_<FTP_Server_IP>.txt, USERPROFILE\ErrorLog_<datetimestamp>, USERPROFILE\FTPServer_Deleted-Files_<FTP_Server_IP>.txt
===============================================================================
"@

Import-Module -Name PSFTP
Remove-Item -Path "$env:USERPROFILE\FTPServer_Deleted-Files*"
$ceiling_date = 14
$ftp_server = Get-Content -Path "$env:USERPROFILE\FTPSERVER.txt"
$retention_date  = $(Get-Date).AddDays(-$ceiling_date).ToString("MM-dd-yyyy HH-mm tt")

#Network Test module: Checking connectivity to FTP port:21
foreach ($ftp_servers1 in $ftp_server){
    if ($(Test-NetConnection -ComputerName $ftp_servers1 -Port 21).Tcptestsucceeded -eq $false) {
        Write-Output "The FTP server $ftp_servers1 is not reachable." | Out-File -FilePath "$env:USERPROFILE\FTPServer_Files_$ftp_servers1.txt"
        continue
    }
    else {
        $temp_var1 = Test-Path -Path "$env:USERPROFILE\MyCreds.xml"
        if ($temp_var1 -eq $false) {
    Write-Output "The MyCreds.xml file is missing and needs to be created." | Out-File -FilePath "$env:USERPROFILE\ErrorLog_$(Get-Date -Format dd-MM-yyyy_hh-mm-ss)"
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}

$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop
if ($credentials.Password -eq $null -or $credentials.UserName -eq $null) {
    $user_name = Read-Host "Please enter the username to connect to FTP server"
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}
if ($credentials.Password.Length -eq 0 -or $credentials.UserName.Length -eq 0) {
    Write-Host "Password is mandatory to connect to FTP server. Please specify the password to connect in the Login prompt" -ForegroundColor Red
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}
    Set-FTPConnection -Credentials $credentials -Server "ftp://$ftp_servers1"  -Session FTPSession -ignoreCert -ErrorAction Continue -KeepAlive -Verbose | Format-Table
    $temp_var = Get-FTPChildItem -Path "ftp://$ftp_servers1" -Session FTPSession | Where-Object{$_.ModifiedDate -lt $retention_date}

    foreach ($remove_item in $temp_var.Name) {
        Remove-FTPItem -Path "ftp://$ftp_servers1/$remove_item" -Session FTPSession
        Write-Output "File $remove_item is deleted at $(Get-Date -Format dd-MM-yyyy_hh-mm-ss) " | Out-File -FilePath "$env:USERPROFILE\FTPServer_Deleted-Files_$ftp_servers1.txt" -Append
}
    Get-FTPChildItem -Path "ftp://$ftp_servers1" -Session FTPSession | Select-Object Name,ModifiedDate | Sort-Object ModifiedDate | Out-File -FilePath "$env:USERPROFILE\FTPServer_Files_$ftp_servers1.txt"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop

#Email Module

#Send-MailMessage -Subject "TestFTP Results" -BodyAsHtml true -Body "The automated FTP cleanup job has been run. Please check the attachments for more information" -Attachments "$env:USERPROFILE\FTPServer_Deleted-Files*", "$env:USERPROFILE\FTPServer_Files*" 
}
}