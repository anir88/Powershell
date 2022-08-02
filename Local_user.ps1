#Script to create local user

$temp_creds = Read-Host "Enter the default password for all the users" -AsSecureString
$uname1 = Get-Content -Path C:\Users\anirban1\Desktop\Login_id.txt
#$full_name = Get-Content -Path C:\Users\anirban1\Desktop\Full-names.txt
try {
    foreach ($user_name in $uname1) {
        New-LocalUser -Name $user_name -FullName $user_name -Password $temp_creds -PasswordNeverExpires -AccountNeverExpires
            
        }
    
}
catch {
        Write-Host "Cannot create user" -ForegroundColor Red
}