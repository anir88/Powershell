#Powershell tool to calculate the actual volume size for volume cration with snapshot reserve
Write-Host "Welcome to the Effective Volume Size Calculation tool" -ForegroundColor white -BackgroundColor Blue
while ($true) {
$inp1 = Read-Host "PLease enter the snapshot reserve percentage(without the % symbol)"
$inp2 = [float] $inp1/100
[int]$desired_size = Read-Host "Enter the desired size of the volume in GB"
$effective_size = [int]$desired_size + ($desired_size*$inp2)+0.5
Write-Host "The effective-size is $effective_size GB" -ForegroundColor DarkGreen
}




