#Script to add LocalUsrers of COS team to Users group

$uname2 = Get-Content -Path C:\Users\anirban1\Desktop\Login_id.txt
try {
    foreach ($user_name1 in $uname2) {
        Add-LocalGroupMember -Group Users -Member $user_name1
        }
    
}
catch {
        Write-Host "Cannot add user" -ForegroundColor Red
}