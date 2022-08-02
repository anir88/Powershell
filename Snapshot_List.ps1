#Script to get the list of snapshots in HC1PRODSANCL1, vserver: hc1prodsan1

$user1 = Get-Credential -Credential AnirbanD

Connect-NaController -Credential $user1 -Name 10.128.113.101

$list_var1 = Get-Content -Path "C:\Users\AnirbanD\Desktop\4325-Vol_list.txt"

foreach ($list_var2 in $list_var1) {
    Get-NcSnapshot -Volume $list_var2 | Select-Object Name,Vserver,Busy,Created,ExpiryTime,Comment,Volume | Format-Table | Out-File -FilePath  "C:\Users\AnirbanD\Desktop\4325-Snap_list_output.xlsx" -Append -ErrorAction Stop
    
}