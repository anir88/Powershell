#Script to create snaphots on list of volumes
 
Import-Module DataONTAP
$User_Path = "$pwd"
$dateandtime = get-date -Format dd-MM-yyyy_HH_mm
#$creds1 = Get-Credential
do {
        Write-Host "Please enter the username and password to continue" -BackgroundColor Red
        $creds1 = Get-Credential
    
} while ($creds1.Password.Length -eq 0)

$cluster_name = Read-Host "Please specify the name of the cluster "
Connect-NcController -Name  $cluster_name -Credential $creds1 -ErrorAction Stop
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
           Get-NcSnapshot -Snapshot $snapshot_name | select Name, Vserver, Volume, Created | Format-Table
   }
   else{
   Write-Host "Terminating the program!! Good day!!" -ForegroundColor Cyan
   #$user_inp1 = Read-Host "Proceed with the snapshot request(y/n) "
}
 
 
 

