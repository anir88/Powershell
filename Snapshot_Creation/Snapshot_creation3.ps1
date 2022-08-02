#Script to create snaphots on list of volumes
 
@"
===================================================================================================
Title: snapshotcreation_script.ps1
Description: Create snapshots on a list of given volumes in a cluster
Requirements: Windows Powershell and the Netapp Powershell Toolkit
Author: Anirban Dutta Gupta
Created For: NetApp GSSC MS Team
Disclaimers : Read the following lines mentioning about the different error symptoms
1) When the password field is empty: The credential promp re-appears and asks to re-enter the creds
2) When the cluster name is incorrect/not-reachable : "No such host is known" is displayed
3) When the username and/or password entered is incorrect: The program auto-exits without any output
===================================================================================================
"@
Import-Module DataONTAP
$User_Path = "$env:USERPROFILE"
$dateandtime = get-date -Format dd-MM-yyyy_HH_mm
#$creds1 = Get-Credential
do {
       Write-Host "Please enter the username and password to continue" -BackgroundColor Red
       $creds1 = Get-Credential
   
} while ($creds1.Password.Length -eq 0)
 
$cluster_name = Read-Host "Please specify the name of the cluster "
$cluster_connection_var1 = (Connect-NcController -Name  $cluster_name -Credential $creds1 -ErrorAction Stop)
$globalcluster_var = $global:CurrentNcController
if ($globalcluster_var -eq $null) {
   Write-Error -Message "$cluster_connection_var1"
   function pause{ $null = Read-Host 'Press Enter to exit the program...' }
   pause
   exit
   
}
else {
$user_inp1 = Read-Host "Proceed with the snapshot request(y/n) "
 
if ($user_inp1 -eq "y") {
  $volume_list = $null
  $volume_list = Get-Content -Path "$User_Path\Vol_list.txt"
  $snapshot_name = Read-Host "Please specify the common name of the snapshots "
  $comments = Read-Host "Please specify the comment(if any,using parenthesis) "
  foreach ($vol_name in $volume_list){
      $vserver1 = Get-NcVol -Name $vol_name| foreach {$_. Vserver}
      if ($vserver1 -ne $null) {
          $var1 = New-NcSnapshot -Volume $vol_name -Snapshot $snapshot_name -Comment $comments -VserverContext $vserver1 -ErrorAction Stop | Out-Null
          Write-Host "Snapshot $snapshot_name in volume $vol_name  and SVM: $vserver1 with comment: $comments created successfully!!" -ForegroundColor Green 
          }
      else{
          Write-Host "Snapshot creation failed as vserver context for the volume: $vol_name is not found in the cluster: $cluster_name" -ForegroundColor Red
          Out-File -FilePath $User_Path\"Snapshot_create_error_log_$dateandtime" -InputObject "Snapshot creation failed as vserver context for the volume: $vol_name is not found in the cluster: $cluster_name. Please check the output log file created" -Append -NoClobber
          }
          }
          $snap_create_list = Get-NcSnapshot -Snapshot $snapshot_name | select Name, Vserver, Volume, Created | Format-Table
          echo $snap_create_list
          echo $snap_create_list | Out-File -FilePath "$User_Path\Snapshot_Creation_Log_$(Get-Date -Format dd-MM-yyyy_hh_mm).txt" -Append
          function pause{ $null = Read-Host 'Press Enter to exit the program...' }
          pause
  }
  else{
  Write-Host "Terminating the program!! Good day!!" -ForegroundColor Cyan
  function pause{ $null = Read-Host 'Press Enter to exit the program...' }
  pause
  #$user_inp1 = Read-Host "Proceed with the snapshot request(y/n) "
}
}
 

