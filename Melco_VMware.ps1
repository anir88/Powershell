start-transcript -path "C:\scripts\Vmware\transcript.txt"
Import-Module VMware.VimAutomation.Core

###########################################################################################
# Title:  VMware health check 
# Filename:        VCheck.ps1       
# Created by:     Jai Waghela                                    
# Date:                15-08-2019                                                    
# Version       1.3                                                                                      
###########################################################################################
# Description:    Scripts that checks the status of a VMware      
# enviroment on the following point:
###########################################################################################

                             
####### css ###################
$css = '
table {
  border-collapse: separate;
  border-spacing: 0;
  color: #4a4a4d;
  font: 14px/1.4 "Helvetica Neue", Helvetica, Arial, sans-serif;
  layout : auto
}
th,
td {
  padding: 10px 15px;
  vertical-align: middle;
}
thead {
  background: #2F82F4;
  color: #fff;
  font-size: 11px;
  text-transform: uppercase;
}
th:first-child {
  border-top-left-radius: 5px;
  text-align: left;
}
th:last-child {
  border-top-right-radius: 5px;
}
tbody tr:nth-child(even) {
  background: #f0f0f2;
}
td {
  border-bottom: 1px solid #cecfd5;
  border-right: 1px solid #cecfd5;
}
td:first-child {
  border-left: 1px solid #cecfd5;
}
.book-title {
  color: #395870;
  display: block;
}
.text-offset {
  color: #7c7c80;
  font-size: 12px;
}
.item-stock,
.item-qty {
  text-align: center;
}
.item-price {
  text-align: right;
}
.item-multiple {
  display: block;
}
tfoot {
  text-align: right;
}
tfoot tr:last-child {
  background: #f0f0f2;
  color: #395870;
  font-weight: bold;
}
tfoot tr:last-child td:first-child {
  border-bottom-left-radius: 5px;
}
tfoot tr:last-child td:last-child {
  border-bottom-right-radius: 5px;
}

table
{
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
  table-layout: auto;
}

{
  border: 1px solid #ddd;
  padding: 0px;
}

tr:nth-child(even){background-color: #f2f2f2;}

tr:hover {background-color: #ddd;}

th {
  padding-top: 4px;
  padding-bottom: 4px;
  text-align: left;
  background-color: #4CAF50;
  color: white;
  
}
'


###########################################

####################################
# VMware VirtualCenter server name #
####################################
$vcserver= @("CODVPVMWVCS10.mpel.com")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##################
# Add VI-toolkit #
##################
Get-Module -Name VMware* -ListAvailable | Import-Module
#Add-PSsnapin -Name VMware.VimAutomation.Sdk
#Add-PSsnapin -Name VMware.VimAutomation.Core
#set-PowerCLIConfiguration -InvalidCertificationAction Ignore
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
connect-VIServer $vcserver -User "opsrampuser@vsphere.local" -Password "P@ssw0rdMelco"

#############
# Variables #
#############
$path = "C:\scripts\Vmware"
<#if(-Not(Test-Path  "$path\Temp"))
{new-item -type directory -path $path\Temp | Out-Null}#>
if(Test-Path  "C:\scripts\Vmware\healthcheck.htm")
{
Remove-Item -path "C:\scripts\Vmware\healthcheck.htm" -Force
}
$filelocation="C:\scripts\Vmware\healthcheck.htm"
$vcversion = get-view serviceinstance
$date=get-date

##################
# Mail variables #
##################
$enablemail="yes"

#############################
# Add Text to the HTML file #
#############################
ConvertTo-Html -body "<img src = 'data:image/png;base64,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' align ='left' height ='80px' weidth ='80px'></img>"| Out-File $filelocation
#ConvertTo-Html  -body "<H2 style ='font-family: Trebuchet MS; color : #34AD43'>Health Report</H2>"| Out-File -Append $filelocation
ConvertTo-Html -body "<H4 style ='font-family: Trebuchet MS; color : #4CAF50'>Melco - $date </H4>"| Out-File -Append $filelocation

##########
# Legend #
##########
ConvertTo-Html  -body "<H5 style ='font-family: Trebuchet MS; color : #464A46;font-size : 14px'>Note : This report is for past 24hrs </H5>"| Out-File -Append $filelocation
ConvertTo-Html  -body "<H4 style ='font-family: Trebuchet MS; color : #464A46;font-size : 21px'>Legend </H4>"| Out-File -Append $filelocation
ConvertTo-Html  -body "<table style = 'width:7px'><tr><td bgcolor=#FA8074>Red</td><td>Critical</td><td bgcolor=#EFF613>Yellow</td><td>Warnings</td><td bgcolor=#33FFBB>Green</td><td>OK</td></tr></table>"| Out-File -Append $filelocation


#######################
# VMware ESX hardware #
#######################

$Reportesx = @()
$HTMLesx = "<style> $css </style>"

    #$HTML += "<HTML><BODY><Table border=1 cellpadding=0 cellspacing=0 id=Header><caption><font size=3 color=blue><h3 align=""left"">$vcserver-ESX Report</h3></font>
    $HTMLesx += "<HTML><head><style></style></head><BODY><font><h2 style ='font-family: Trebuchet MS; color : #464A46; font-size : 21px' align=""left"">ESXi Host Report</h2></font><Table>

    </caption>
               
            <TR>
                  <TH><B>VCenter</B></TH>
                  <TH><B>ESX</B></TH>
                  <TH><B>OverallStatus</B></TH>
                  <TH><B>Connection State</B></TH>
                  <TH><B>Config Issues</B></TH>
                  <TH><B>CPU Usage</B></TH>
                  <TH><B>CPU Max</B></TH>
                  <TH><B>Memory usage</B></TH>
                  <TH><B>Memory Max</B></TH>
                                      
  
           </TR>"

foreach($vcnt in $vcserver)
{
#######################
#$esx = Get-VMHost | Get-View | ForEach-Object { $_.Summary.Hardware } | Select-object Vendor, Model, MemorySize, CpuModel, CpuMhz, NumCpuPkgs, NumCpuCores, NumCpuThreads, NumNics, NumHBAs | ConvertTo-Html –title "VMware ESX server Hardware configuration" –body "<H2>VMware ESX server Hardware configuration.</H2>" -head "<link rel='stylesheet' href='style.css' type='text/css' />" | Out-File -Append $filelocation
$esx = Get-VMHost -Server $vcnt

foreach ($e in $esx)
{
$allinfo = ''|select-Object VCenter, Esx, OverallStatus, Connection_State, Config_issues, CPU_Utilization,CPU_Max,CPU_Min, Memory_Utilization, Mem_Max, Mem_Min
$ev = $e.ExtensionData 
$esxinfoconstat = (Get-Vmhost -Name $e).ConnectionState
$esxstats = Get-Vmhost -Name $e | Get-Stat -Cpu -Memory -MaxSamples 1 -ErrorAction SilentlyContinue
$esxstatscpu = $esxstats[0].value
$esxstatsmem = $esxstats[2].value
$allinfo.VCenter = $vcnt
$allinfo.Esx = $ev.name
$allinfo.OverallStatus = $ev.Summary.OverallStatus
$allinfo.Connection_State = $esxinfoconstat
$allinfo.Config_issues = $ev.configissue.FullFormattedMessage
if($esxstatscpu -ne '')
{$allinfo.CPU_Utilization = $esxstatscpu}
if($esxstatsmem -ne '')
{$allinfo.Memory_Utilization = $esxstatsmem}

$statsesx = Get-Stat -Entity $e -start (get-date).AddDays(-1) -Finish (Get-Date) -MaxSamples 1000 -stat "cpu.usage.average","mem.usage.average"  
$statsesx | Group-Object -Property Entity | %{
  
  
 
  $cpuesx = $_.Group | where {$_.MetricId -eq "cpu.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
  $memesx = $_.Group | where {$_.MetricId -eq "mem.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum

  $allinfo.CPU_Max = [int]$cpuesx.Maximum
  #$vmstat.CPUAvg = [int]$cpu.Average
  $allinfo.CPU_Min = [int]$cpuesx.Minimum
  $allinfo.Mem_Max = [int]$memesx.Maximum
  #$vmstat.MemAvg = [int]$mem.Average
  $allinfo.Mem_Min = [int]$memesx.Minimum  

}

$Reportesx +=$allinfo
}

}


           Foreach($Entry in $Reportesx)
    {
    
    
     
              
     $HTMLesx += "<TR>"

           
                                   $HTMLesx +=  "<TD>$($Entry.VCenter)</TD>"
                                   $HTMLesx +=  "<TD>$($Entry.Esx)</TD>"
                                   if($Entry.OverallStatus -eq "green")
                                      {
                                        $HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.OverallStatus)</TD>"
                                      }
                                    elseif($Entry.OverallStatus -eq "yellow")
                                    {
                                        $HTMLesx += "<TD bgcolor=#EFF613>$($Entry.OverallStatus)</TD>"
                                      }
                                    else{  $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.OverallStatus)</TD> "} 
                                   if($Entry.Connection_State -ne "connected")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.Connection_State)</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.Connection_State)</TD>"}

                                     if($Entry.Config_issues -ne $null)
                                     {
                                     $HTMLesx += "<TD bgcolor=#EFF613>$($Entry.Config_issues)</TD>"
                                     }
                                     else
                                     {
                                     $HTMLesx += "<TD bgcolor=#33FFBB>NA</TD>"
                                     }

                                     if($Entry.CPU_Utilization -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.CPU_Utilization)%</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.CPU_Utilization)%</TD>"}
                                      
                                      if($Entry.CPU_Max -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.CPU_Max)%</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.CPU_Max)%</TD>"}

                                    <# if($Entry.CPU_Min -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.CPU_Min)%</TD>"
                                    }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.CPU_Min)%</TD>"}#>

                                     if($Entry.Memory_Utilization -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.Memory_Utilization)%</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.Memory_Utilization)%</TD>"}
                                     
                                     if($Entry.Mem_Max -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.Mem_Max)%</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.Mem_Max)%</TD>"}
                                     
                                     <# if($Entry.Mem_Min -ge "90")
                                   {
                                     $HTMLesx += "<TD bgcolor=#FA8074>$($Entry.Mem_Min)%</TD>"
                                     }
                                     else {$HTMLesx += "<TD bgcolor=#33FFBB>$($Entry.Mem_Min)%</TD>"}#>
                                     
                                     
                                 
         $HTMLesx += "</TR>"
                          

                            }
   
    $HTMLesx += "</Table></BODY></HTML>"

    $HTMLesx | Out-File -Append $filelocation



############ alarms ########################

  $HTMLalarms += "<HTML><head><style>$style</style></head><BODY><font><h2 style ='font-family: Trebuchet MS; color : #464A46; font-size : 21px' align=""left"">Alarms</h2></font><Table>

    
               
            <TR>
                  <TH><B>VCenter</B></TH>
                  <TH><B>Status</B></TD>
                  <TH><B>Alarm</B></TH>
                  <TH><B>Entity</B></TD>
                  <TH><B>EntityType</B></TH>
                  <TH><B>Time</B></TH>
                  <TH><B>Acknowledged</B></TH>
                  <TH><B>AckBy</B></TH>
                  <TH><B>AckTime</B></TH>
                  
  
  
           </TR>"

Function Get-TriggeredAlarms {
param (
                             $vc
                             
              )

     $rootFolder = Get-Folder -Server $vc "Datacenters"  
     


  foreach($ta in $rootFolder.ExtensionData.TriggeredAlarmState) {
                             $alarm = "" | Select-Object VC, EntityType, Alarm, Entity, Status, Time, Acknowledged, AckBy, AckTime
                             $alarm.VC = $vc
                             $alarm.Alarm = (Get-View -Server $vc $ta.Alarm).Info.Name
                             $entity = Get-View -Server $vc $ta.Entity
                             $alarm.Entity = (Get-View -Server $vc $ta.Entity).Name
                             $alarm.EntityType = (Get-View -Server $vc $ta.Entity).GetType().Name
                             $alarm.Status = $ta.OverallStatus
                             $alarm.Time = $ta.Time
                             $alarm.Acknowledged = $ta.Acknowledged
                             $alarm.AckBy = $ta.AcknowledgedByUser
                             $alarm.AckTime = $ta.AcknowledgedTime
                             $alarm
              }
  
  }
  

# Write-Host ("Getting the alarms from vCenters." -f $vcserver.Length)

  $alarms = @()

  foreach ($vCenter in $vcserver) {
  #          Write-Host "Getting alarms from $vcserver."
              $alarms += Get-TriggeredAlarms $vCenter
  }

  #$alarms | Out-GridView -Title "Triggered Alarms"
  #$alarms | ConvertTo-Html –title "Active alarms" –body "<H2 style ='font-family: Trebuchet MS; color : #244664'>Alarms</H2>"| Out-File -Append $filelocation


           Foreach($Entry in $alarms)
    {
    
    
     
              
     $HTMLalarms += "<TR>"

           
                                   $HTMLalarms +=  "<TD>$($Entry.VC)</TD>"
                                   
                                    if($Entry.Status -eq "yellow")
                                      {
                                        $HTMLalarms += "<TD bgcolor=#EFF613>$($Entry.Status)</TD>"
                                      }
                                    elseif ($Entry.Status -eq "red")
                                    {
                                        $HTMLalarms += "<TD bgcolor=#FA8074>$($Entry.Status)</TD>"
                                      }
                                    else
                                    {  $HTMLalarms += "<TD>$($Entry.Status)<TD> "} 
                                    $HTMLalarms +=  "<TD>$($Entry.Alarm)</TD>"
                                   
                                     $HTMLalarms += "<TD>$($Entry.Entity)</TD>"
                                     $HTMLalarms += "<TD>$($Entry.EntityType)</TD>"
                                     $HTMLalarms += "<TD>$($Entry.Time)</TD>"
                                     $HTMLalarms += "<TD>$($Entry.Acknowledged)</TD>"
                                     $HTMLalarms += "<TD>$($Entry.AckBy)</TD>"
                                     $HTMLalarms += "<TD>$($Entry.AckTime)</TD>"
                                 
                                 
         $HTMLalarms += "</TR>"
                          

                            }
   
    $HTMLalarms += "</Table></BODY></HTML>"

    if($alarms -ne '')
    {

    $HTMLalarms | Out-File -Append $filelocation
    }
    else
    {
        ConvertTo-Html  -body "<H2 style ='font-family: Trebuchet MS; color : #464A46; font-size : 21px'>Alarms</H2>"| Out-File -Append $filelocation

    }

#########################
# Datastore information #
#########################

$HTMLds += "<HTML><head><style>$style</style></head><BODY><font><h2 style ='font-family: Trebuchet MS; color : #464A46; font-size : 21px' align=""left"">Datastores</h2></font><Table>

     
               
            <TR>
                  <TH><B>Vcenter</B></TH>
                  <TH><B>Datastore</B></TH>
                  <TH><B>State</B></TH>
                  <TH><B>Percenatge Free</B></TD>
                  <TH><B>UsedGB</B></TH>
                  <TH><B>FreeGB</B></TD>
                  
  
           </TR>"

function UsedSpace
{
              param($ds)
              [math]::Round(($ds.CapacityMB - $ds.FreeSpaceMB)/1024,2)
}

function FreeSpace
{
              param($ds)
              [math]::Round($ds.FreeSpaceMB/1024,2)
}

function PercFree
{
              param($ds)
              [math]::Round((100 * $ds.FreeSpaceMB / $ds.CapacityMB),0)
}

$myCol = @()
foreach($vcntds in $vcserver)
{
$Datastores = Get-Datastore -Server $vcntds
ForEach ($Datastore in $Datastores)
{
              $myObj = "" | Select-Object Vcenter, Datastore, State, UsedGB, FreeGB, PercFree
              $myObj.Datastore = $Datastore.Name
              $myObj.UsedGB = UsedSpace $Datastore
              $myObj.FreeGB = FreeSpace $Datastore
              $myObj.PercFree = PercFree $Datastore
    $myObj.State = $Datastore.State
    $myObj.Vcenter = $vcntds
              $myCol += $myObj
}
#$myCol | Sort-Object PercFree | ConvertTo-Html –title "Datastore space " –body "<H2 style ='font-family: Trebuchet MS; color : #464A46; font-size : 21px'>Datastore space available.</H2>" | Out-File -Append $filelocation
}
           Foreach($Entry in $myCol)
    {
    
    
     
              
     $HTMLds += "<TR>"

           
                                   $HTMLds +=  "<TD>$($Entry.Vcenter)</TD>"
                                   $HTMLds +=  "<TD>$($Entry.Datastore)</TD>"
                                   if($Entry.State -ne "Available")
                                      {
                                        $HTMLds += "<TD bgcolor=#EFF613>$($Entry.State)</TD>"
                                      }
                                   else
                                    {$HTMLds += "<TD bgcolor=#33FFBB>$($Entry.State)</TD>"}
                                   
                                   if($Entry.PercFree -le "10")
                                      {
                                        $HTMLds += "<TD bgcolor=#FA8074>$($Entry.PercFree)%</TD>"
                                      }
                                    elseif ($Entry.PercFree -le "20")
                                    {
                                        $HTMLds += "<TD bgcolor=#EFF613>$($Entry.PercFree)%</TD>"
                                      }
                                    else
                                    {$HTMLds += "<TD bgcolor=#33FFBB>$($Entry.PercFree)%</TD>"}
                                    
                                    $HTMLds +=  "<TD>$($Entry.UsedGB)</TD>"
                                    $HTMLds += "<TD>$($Entry.FreeGB)</TD>"
                              
                                 
                                 
         $HTMLds += "</TR>"
                          

                            }
   
    $HTMLds += "</Table></BODY></HTML>"

    $HTMLds | Sort-Object PercFree | Out-File -Append $filelocation

    

######################>
# E-mail HTML output #
######################
Stop-Transcript
if ($enablemail -match "yes") 
{ 
$mailbody = Get-Content "$path\healthcheck.htm" -Raw
$fromaddress = "dailyhealthcheck@melco-resorts.com" 
$toaddress =  "pcaas@boardware.com", "DLITInfraServer@melco-resorts.com"
$Subject = "Melco PCaaS - VMware Daily Health Check Report - $(Get-Date -Format dd-MM-yyyy)" 
$SMTPServer = "10.102.146.31"
$Attachment = "C:\scripts\Vmware\transcript.txt"
Send-MailMessage -From $fromaddress -to $toaddress  -Subject $Subject -Body $mailbody -BodyAsHtml -SmtpServer $SMTPServer -Attachments $Attachment
}

##############################
# Disconnect session from VC #
##############################

#disconnect-viserver $vcserver -confirm:$false

#####################
# End Of VCheck.ps1 #
#####################
