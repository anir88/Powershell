@"
===============================================================================
Title: 			Netapp Snap notifications.ps1
Description: 	List snapshots over a certain age on all Netapp filers.
Requirements: 	Windows Powershell and the Netapp Powershell Toolkit
Author: 		Ed Grigson
Modified By: Anirban Dutta Gupta
Created For: NetApp GSSC Team 
===============================================================================
"@

Import-module DataOnTap

#Age of snapshot (in days) before it's included in the report
$WarningDays = 14										
#List the filers you want to scan
$NetappList=("dcr-sto-clus01.channel4.local","cft-sto-clus01.channel4.local")
#List of email recipients
$emailNotifications=("is_database_team@channel4.co.uk","is_oracle_dbas@channel4.co.uk","cfgcomputesupport@channel4.co.uk","cfgstoragesupport@channel4.co.uk")
#List of email Cc recipients
$emailCcNotifications=("ng-Channel4-MSOps@netapp.com","MBasso@Channel4.co.uk","JTMahoney@Channel4.co.uk","JJulyan@channel4.co.uk","TWhite@Channel4.co.uk","JReichmann@Channel4.co.uk")	
#SMTP server - replace with your SMTP relay below
$emailServer="smtp.channel4.local"
$Now=Get-Date
$credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml" -ErrorAction Stop
if ($credentials.Password -eq $null -or $credentials.UserName -eq $null) {
    $user_name = Read-Host "Please enter the username to connect to clusters"
    Get-Credential -Credential $user_name  | Export-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
    $credentials = Import-Clixml -Path "$env:USERPROFILE\MyCreds.xml"
}

#Generate HTML output that uses CSS for style formatting.
$emailContent =		"<html><head><title></title><style type=""text/css"">
.Error {color:#FF0000;font-weight: bold;}
.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;}
.Normal {}
table, th, td {
    border: 1px solid black;
}
</style></head><body>"
$emailContent +=	"<p>Please find the list below for snapshots created and let us know if we need to remove those which are no longer needed - they're listed by clusters with the oldest snapshots at the top. As a general rule a snapshot should not be kept for more than two weeks."
$emailContent +=	"<p>To raise a snapshot delete request please send an email to this DL ng-channel4-msops@netapp.com with the list of snapshot names to be deleted."
$emailContent +=	"<p>Only snapshots over $WarningDays days old are shown."

foreach ($netapp in $NetappList) {	
	$emailContent +=	"<h2>$Netapp</h2>"
	$emailContent +=	"<table><tr class='Title'><td colspan='5'>NetApp Snapshot Report</td></tr><tr class='Title'><td>Parent Volume</td><td>Snapshot Name</td><td width='150px'>Date Created</td><td>Snapshot size</td><td>Snapshot Age</tr>"
 	$Report =@()
 	Connect-nccontroller $netapp -Credential $credentials | select Name,Address
	get-ncvol | foreach-object {
		$ParentName=$_.Name
		$Snap = get-ncsnapshot $ParentName | add-member -membertype noteproperty -name ParentName -value $ParentName -passthru | select ParentName,Name,Total,@{Name="AccessTime";Expression={ConvertTo-DateTime $_.AccessTime}}
		$Report += $Snap
		}
 	Foreach ($snapshot in ($Report | Sort-Object -property AccessTime)){
		#see if the snapshot is older than the value specified in $WarningDays and if so include in report
		if ($snapshot.AccessTime -le $Now.AddDays(-$WarningDays)) {
			#Reformat the snapshot size into Gb
			$snapsize = "{0,20:n3}" -f (($snapshot.Total*1)/1GB)
			$emailContent +=	"<tr><td>$($snapshot.ParentName)</td><td>$($snapshot.Name)</td><td>$($snapshot.AccessTime)</td><td>$($snapsize)GB</td><td>$(($(get-date)-$snapshot.AccessTime).Days) days</td></tr> "
		} 
	}
	$emailContent +=	"</table></body></html>" 
}

# Generate the report and email it as a HTML body of an email
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = $emailServer  
$MailMessage = New-Object system.net.mail.mailmessage
#Change to email address you want emails to be coming from
$MailMessage.from = "snapreport@channel4.co.uk" 
foreach($email in $emailNotifications) {
	$MailMessage.To.add($email)
}
foreach($email in $emailCcNotifications) {
	$MailMessage.Cc.add($email)
}

$MailMessage.Subject = "NetApp Snapshot Report"	
$MailMessage.IsBodyHtml = 1
$MailMessage.Body = $emailContent
$SmtpClient.Send($MailMessage)