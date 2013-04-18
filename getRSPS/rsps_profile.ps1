
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

 $host.UI.RawUI.BufferSize = $bufferSize

 $size = $Host.UI.RawUI.WindowSize 
 $size.Width = 150
 $size.Height = 50

 $Host.UI.RawUI.WindowSize = $size

}

Set-Location c:\RSTools\RSPS

$localRSToolsDir = "c:\RSTools\RSPS"
$rsDLLPath = $localRSToolsDir + "\" + "RightScale.netClient.Powershell.dll"

#RS console settings
set-RSConsole

# Load RSPosh DLL
Write-Host "Loading RSPS DLL - $rsDLLPath"

try
{
  Import-Module $rsDLLPath -ErrorAction SilentlyContinue
  
  if(!$?)
  {
    Write-Host "Could not load RSPS DLL - $rsDLLPath" -ForegroundColor red
	Write-Host $error[0]
	
	exit
  }
}
catch
{
  Write-Host "Could not load RSPS DLL - $rsDLLPath" -ForegroundColor red
  Write-Host "Verify path file exists - $rsDLLPath" -ForegroundColor Red
  Write-Host $_ -ForegroundColor Red
  exit
}


$version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($rsDLLPath).FileVersion

cls

$colwidth = 80
$spc = " "
	
Write-Host ("*" * ($colwidth + 4))
WriteConsHeader "RightScale PowerShell - RightScale .netClient Version $version"
WriteConsHeader ""
WriteConsHeader "To get started with RightScale Powershell Commands`:"
WriteConsHeader "Connect to RightScale using connect-RightScale -username -password -acctid"
WriteConsHeader ""
WriteConsHeader "To list available commands use`:"
writeConsHeader "get-command -Module RSPS"
Write-Host ("*" * ($colwidth + 4))
Write-Host ""
Write-Host ""