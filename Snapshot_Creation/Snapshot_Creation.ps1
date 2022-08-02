#Script to create snaphots on list of volumes

Import-Module DataONTAP
$User_Path = "$pwd\Desktop"
$creds1 = Get-Credential
$cluster_name = Read-Host "PLease specify the name of the cluster "
Connect-NcController -Name  $cluster_name -Credential $creds1 -ErrorAction Stop
$volume_list = Get-Content -Path $User_Path\Vol_list.txt

$user_inp1 = Read-Host "Proceed with the snapshot request(y/n) "

while ($user_inp1 -eq "y") {
    $vserver1 = Read-Host "Mention the vserver name"
    $snapshot_name = Read-Host "Please specify the common name of the snapshots "
    $comments = Read-Host "Please specify the comment(if any) "
    foreach ($vol_name in $volume_list){
        New-NcSnapshot -Volume $vol_name -Snapshot $snapshot_name -Comment $comments -VserverContext $vserver1 |  Out-File -FilePath $User_Path\"Snapshot_create_log_$dateandtime" -Append
        Write-Host "Snapshot $snapshot_name in volume $vol_name created" -ForegroundColor Green
    }
    $user_inp1 = Read-Host "Proceed with the snapshot request(y/n) "
}

