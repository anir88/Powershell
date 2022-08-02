##################sf summary  
##################### CODPPHCISTC-PDC CODPPHCISTC-SDC
Import-Module SolidFire

function calb($size)
{    #VolumeName 
$org=$size 
$size = [math]::round($org/1Gb,2)  
$size = "$size"   
return $size 
} 
# $UserName ="admin" 
# $ControllerPassword =ConvertTo-SecureString 'N3t@pp123' -AsPlainText -Force
#####################SF
Out-File -FilePath C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$filers="192.168.0.105"
foreach($filer in $filers)
{ 
$ControllerCredential = Get-Credential # New-Object System.Management.Automation.PsCredential($UserName,$ControllerPassword)

Connect-SFCluster $filer -credential $ControllerCredential
if($filer -eq "192.168.0.105")
{
$Header1 = @"
<head>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
</head>
<center><h1>SolidFire NetApp HCI-cluster</h1></center><br>
<h3>Cluster capacity</h3>
"@
}
else
{$Header1 = @"
<head>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
</head>
<center><h1>SolidFire HC-EQUPPHCISTC</h1></center><br>
<h3>Cluster capacity</h3>
"@
}
#####################
$header = @"
<head>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
</head>
"@
###############
$a= get-sfclustercapacity | select -property activeBlockSpace,provisionedSpace,usedSpace,maxUsedSpace,maxProvisionedSpace,maxOverProvisionableSpace
$a.activeBlockSpace=calb($a.activeBlockSpace)
$a.maxOverProvisionableSpace=calb($a.maxOverProvisionableSpace)
$a.maxProvisionedSpace=calb($a.maxProvisionedSpace)
#$a.maxUsedMetadataSpace=calb($a.maxUsedMetadataSpace)
$a.maxUsedSpace=calb($a.maxUsedSpace)
$a.provisionedSpace=calb($a.provisionedSpace)
#$a.usedMetadataSpace=calb($a.usedMetadataSpace)
$a.usedSpace=calb($a.usedSpace)
$a|Add-Member -MemberType NoteProperty -Name availableProvisionableSpace -Value ($a.maxOverProvisionableSpace - $a.provisionedSpace)
$a|Add-Member -MemberType NoteProperty -Name availableBlockSpace -Value ($a.maxUsedSpace - $a.usedSpace)
$a
$a=$a|ConvertTo-Html -head $header1  
$a=[string]$a.Replace("ActiveBlockSpace","activeBlockSpace(Gb)")
$a=[string]$a.Replace("MaxOverProvisionableSpace","maxOverProvisionableSpace(Gb)")
#$a=[string]$a.Replace("MaxProvisionedSpace","maxProvisionedSpace(Gb)")
#$a=[string]$a.Replace("MaxUsedMetadataSpace","maxUsedMetadataSpace(Gb)")
#$a=[string]$a.Replace("MaxUsedSpace","maxUsedSpace(Gb)")
$a=[string]$a.Replace("ProvisionedSpace","provisionedSpace(Gb)")
$a=[string]$a.Replace("availableProvisionableSpace","availableProvisionableSpace(Gb)")
$a=[string]$a.Replace("availableBlockSpace","availableBlockSpace(Gb)")
 
#$a=[string]$a.Replace("maxusedMetadataSpace","maxusedMetadataSpace(Gb)") 
#$a=[string]$a.Replace("UsedMetadataSpace","usedMetadataSpace(Gb)")
$a=[string]$a.Replace("UsedSpace","usedSpace(Gb)")
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
################# 
Add-Content -value "<br><h3>Cluster Threshold</h3>" -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$a=Get-SFClusterFullThreshold | select -Property Fullness,BlockFullness,MetadataFullness|ConvertTo-Html -head $header  
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$legend="<br><p align=center><b><u>Legend</b></u></p><br><b><u>stage 1 Happy </b></u><i>- No alerts or error conditions. Corresponds to the Healthy state in the web UI.</i><br><b><u>stage 2 Aware</b></u> <i>– No alerts or error conditions. Corresponds to the Healthy state in the web UI.</i><br><b><u>stage 3 Low</b></u><i> – Your system cannot provide Double-Helix data protection from a single node failure. Corresponds to the Warning state in the web UI. You can configure this level in the web UI (by default, the system triggers this alert at a capacity of 3% below the Error state).</i><br><b><u>stage 4 Critical </b></u><i>– The system is not capable of providing Double-Helix data protection from a single node failure. No new volumes or clones can be created. Corresponds to the Error state in the web UI.</i><br><b><u>stage 5 Completely Consumed</b></u> <i>– Completely consumed. The cluster is read-only and iSCSI connections are maintained, but all writes are suspended. Corresponds to the Critical state in the web UI.</i>"
Add-Content -value $legend -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
<#
Add-Content -value "<br><h3>Cluster State</h3><br>" -path C:\Utilities\Powershell-Scripts\SolidFire.htm
$a= get-sfclusterstate |ConvertTo-Html -head $header    
Add-Content -value $a -path C:\Utilities\Powershell-Scripts\SolidFire.htm
#>
Add-Content -value "<br><h3>Solidfire Drive</h3>" -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$a= get-sfdrive | ?{$_.status -eq "available" -or $_.status -eq "failed" -or $_.status -eq "removing" }| select -Property DriveID,NodeID,Slot,Status
if($a -eq $null)

{

$a="<b>No failed drives in the cluster</b>"

}

else

{$a=$a|ConvertTo-Html -head $header    
}
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
Add-Content -value "<br><h3>Volume State</h3>" -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$a= get-sfvolume|select -property volumeid,name,status |ConvertTo-Html -head $header    
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$a= get-sfDeletedvolume|select -property volumeid,name,status |ConvertTo-Html -head $header    
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
Add-Content -value "<br><h3>Alerts</h3>" -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
$a= Get-SFClusterFault | ?{$_.Resolved -eq 0} 
if($a -eq $null)

{

$a="<b>No active alerts in the cluster</b><br>"

}

else

{$a=$a|ConvertTo-Html -head $header    
}
    
Add-Content -value $a -path C:\Users\Administrator.DEMO\Desktop\Test_Report.html
<#
Add-Content -value "<br><b><p style=font-size:30px>Cluster Pair</p></b><br>" -path C:\Utilities\Powershell-Scripts\SolidFire.htm
$a= get-sfclusterpair |ConvertTo-Html -head $header    
Add-Content -value $a -path C:\Utilities\Powershell-Scripts\SolidFire.htm
Add-Content -value "<br><b><p style=font-size:30px>Volume Pair</p></b><br>" -path C:\Utilities\Powershell-Scripts\SolidFire.htm
$a= get-sfvolumepair |select -Property VolumeID,Name,AccountID,CreateTime,Status,Access,Enable512e,Iqn|ConvertTo-Html -head $header    
Add-Content -value $a -path C:\Utilities\Powershell-Scripts\SolidFire.htm
#>
} 

<# [string]$msgbody= Get-Content -path C:\Utilities\Powershell-Scripts\SolidFire.htm
######send EMAIL##########

$date=get-date
$day=$date.Day
$month=$date.Month
$year=$date.Year
$From = "dailyhealthcheck@melco-resorts.com"
$To = "pcaas@boardware.com", "DLITInfraServer@melco-resorts.com"
$Attachment = "C:\Utilities\Powershell-Scripts\SolidFire.htm"
$Subject = "SolidFire - Melco PCaaS Daily Health Check ($day/$month/$year)"
$Body = "Summary"

$SMTPServer = "10.102.146.31"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $msgbody -BodyAsHtml -SmtpServer $SMTPServer -Attachments $Attachment

######send EMAIL##########
#>