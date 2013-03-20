cls

$gitURL = "https://github.com/patrickmcclory/RightScalePowerShell/blob/master/PowershellAPI/RSPSShell""
$dplyRSPSShell 	= "deployrsps.ps1"
$dplyRSPSShellManifest = "manifest.rspsshell.xml"



$srcDply		= $gitURL + "/" + $dplyRSPSShell"
$srcDplyManifest	= $gitURL + "/" + $dplyRSPSShellManifest"

$destFolder 	= "c:\RSTools\RSPSShell"

$destDplyFile 		= "$destFolder\$dplyRSPSShell"
$destMfstFile 		= "$destFolder\$dplyRSPSShellManifest"


if(!(Test-Path $destFolder)){New-Item -Path $destFolder -ItemType directory -Force}

$webclient = New-Object system.Net.WebClient

try
{
		write-host "GETRSPSSHELL`: Downloading file - $dplyRSPSShell"
		$webclient.downloadfile($srcDply,$destDplyFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPSSHELL`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPSSHELL`: Error downloading source - $_"
		}
	
}

try
{
		write-host "GETRSPSSHELL`: Downloading file - $dplyRSPSShellManifest"
		$webclient.downloadfile($srcDplyManifest,$destMfstFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPSSHELL`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPSSHELL`: Error downloading source - $_"
		}
	
}


set-location $destFolder
. .\$dplyRSPSShell
. ".\create_RSPS_shortcut.ps1"
