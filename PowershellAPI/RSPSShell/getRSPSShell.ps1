

cls

$dplyRSPSShell 	= "deployrsps.ps1"
$dplyRSPSShellManifest = "manifest.rspsshell.xml"

#https://mrp-us-bucket.s3.amazonaws.com/rs-psshell/DeployRSPSshell.ps1?Signature=s2YenSZCAyDpX%2FSKzFj5v3pJIwE%3D&Expires=1363789242&AWSAccessKeyId=068S8XY7J4FFK4111Y02
$srcDply			= "https://mrp-us-bucket.s3.amazonaws.com/rs-psshell/$dplyRSPSShell"
$srcDplyManifest	= "https://mrp-us-bucket.s3.amazonaws.com/rs-psshell/$dplyRSPSShellManifest"

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
