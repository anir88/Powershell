$user1 = Read-Host "Enter the username to connect to cluster"
$creds1 = Get-Credential -Credential $user1
Connect-NcController -Name HC1PRODSANCL1 -Credential $creds1
$names1 = Get-Content -Path 'C:\Users\AnirbanD\Desktop\Vol move HC1PROD.txt'
foreach($names2 in $names1)
{
    Get-NcVol -Name $names2 | select Name, Aggregate | Format-Table | Out-File -FilePath C:\Users\AnirbanD\Desktop\vol_move-report.csv -Append
}