
function WriteConsHeader
{
  param($msg)
  
  	$retMsg = "*  " + $msg + ($spc * ($colwidth - $msg.length)) + "*"
	
	return $retMsg

}

Function Set-RSConsole 
{ 


 $Host.UI.RawUI.WindowTitle = "RIGHTSCALE - " +  $Host.UI.RawUI.WindowTitle

 $host.ui.RawUI.ForegroundColor = "White" 
 $host.ui.RawUI.BackgroundColor = "DarkBlue" 
 $host.PrivateData.ErrorBackgroundColor = "DarkBlue" 
 $Host.PrivateData.WarningBackgroundColor = "DarkBlue" 
 $Host.PrivateData.VerboseBackgroundColor = "DarkBlue" 
 $host.PrivateData.ErrorForegroundColor = "red" 
 $host.PrivateData.WarningForegroundColor = "DarkGreen" 
 $host.PrivateData.VerboseForegroundColor = "Yellow" 
 
 $bufferSize = new-object System.Management.Automation.Host.Size 300,500
 #$windowsize = new-object System.Management.Automation.Host.Size 300,80

 $host.UI.RawUI.BufferSize = $bufferSize

 $size = $Host.UI.RawUI.WindowSize 
 $size.Width = 150
 $size.Height = 50

 $Host.UI.RawUI.WindowSize = $size

}

Set-Location c:\RSTools\RSPSShell

$localRSToolsDir = "c:\RSTools\RSPSshell"
$rsDLLPath = $localRSToolsDir + "\resources\" + "RightScale.netClient.dll"
#RS console settings
set-RSConsole

# Load RS NET Client
Add-Type -Path $rsDLLPath

$version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($rsDLLPath).FileVersion



#import modules
[string]$utils = get-childItem -path .\utils -exclude loadutils.ps1,list.ps1

$utillist = $utils.split(" ") 

foreach($util in $utillist) 
  { 
    . $util
  } 



$colwidth = 80
$spc = " "
	
Write-Host ("*" * ($colwidth + 4))
WriteConsHeader "RightScale PowerShell - RightScale .netClient Version $version"
WriteConsHeader ""
WriteConsHeader "To get started with RightScale Powershell Commands"
WriteConsHeader "Connect to RightScale using connect-RightScale -username -password -acctid"
Write-Host ("*" * ($colwidth + 4))
Write-Host ""
Write-Host ""