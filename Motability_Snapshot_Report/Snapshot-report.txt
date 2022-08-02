@"
===============================================================================
Title: 			Netapp Snapshot Report.ps1
Description: 	List snapshots over a certain age on all Netapp filers.
Requirements: 	Windows Powershell and the Netapp Powershell Toolkit
Author: 		Anirban Dutta Gupta
Created For: NetApp GSSC Team 
===============================================================================
"@


Import-module DataOnTap

# Defining the clusters
$netapp_clusters = ("cluster1")

#Accepting user input

Write-Host "Welcome to the NetApp Snapshot Reporting Utility"
write-host "Please choose the appropriate option to continue:"
Write-Host "1. List the manually created snapshots" -ForegroundColor Cyan
Write-Host "2. List the system-generated snapshots" -ForegroundColor Yellow
Write-Host "3. Exit the program" -ForegroundColor Red

$user_inp1 = Read-Host "Please enter the appropriate choice to continue"

#Getting the date
$now = get-date

#Connecting to the clusters

$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop
if ($credentials.Password -eq $null -or $credentials.UserName -eq $null -or $(Test-Path -Path "$env:USERPROFILE\MyCreds.xml") -eq $false) {
    $user_name = Read-Host "Please enter the username to connect to clusters"
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}
foreach ($clusters1 in $netapp_clusters) {
    connect-nccontroller -Name $clusters1 -Credential $credentials
    if ($user_inp1 -eq "1") {
        get-ncsnapshot -SnapName SRQ* -Attributes @{"Name" = ""; "Vserver" = ""; "Volume" = ""; "AccessTime" = ""; "Comment" = ""} | select-object Name, Volume,Vserver,Created,Comment | Where-Object {$_. Created -le $now.AddDays(-31)} | Sort-Object -Property Created -Descending | Format-Table | ConvertTo-Csv | Out-File -FilePath "$env:USERPROFILE\Desktop\$($clusters1)_Manual_Snapshot_Report_$(Get-Date -Format dd-MM-yyyy_hh-mm-ss).csv" -Append -NoClobber
        }
    elseif ($user_inp1 -eq "2") {
        get-ncsnapshot -SnapName !SRQ* -Attributes @{"Name" = ""; "Vserver" = ""; "Volume" = ""; "AccessTime" = ""; "Comment" = ""} | select-object Name, Volume,Vserver,Created,Comment | Where-Object {$_. Created -le $now.AddDays(-14)} | Sort-Object -Property Created -Descending | Format-Table | ConvertTo-Csv | Out-File -FilePath "$env:USERPROFILE\Desktop\$($clusters1)_System_Generated_Snapshot_Report_$(Get-Date -Format dd-MM-yyyy_hh-mm-ss).csv" -Append -NoClobber
        }
    elseif ($user_inp1 -eq "3") {
        Write-Host "Terminating the program"
        exit
        
    }

    }

# Zipping all the reports into a sinngle compresed archive for easy storage and export and removing redundant files

Compress-Archive -Path "$env:USERPROFILE\Desktop\*_$(Get-Date -Format dd-MM-yyyy_hh-mm).csv" -CompressionLevel Fastest -DestinationPath "$env:USERPROFILE\Desktop\Snapshot_Reports_$(Get-Date -Format dd-MM-yyyy_hh-mm).zip"
Remove-Item -Path  "$env:USERPROFILE\Desktop\*_$(Get-Date -Format dd-MM-yyyy_hh-mm).csv" 
