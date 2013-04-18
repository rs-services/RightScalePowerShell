cls

$gitURL = "https://raw.github.com/patrickmcclory/RightScalePowerShell/master/getRSPS"
$dplyRSPS 	= "deployRSPS.ps1"
$dplyRSPSManifest = "manifest.rsps.xml"

$srcDply			= $gitURL + "/" + $dplyRSPS
$srcDplyManifest	= $gitURL + "/" + $dplyRSPSManifest
$destFolder   		= "c:\RSTools\RSPS"
$destDplyFile 		= "$destFolder\$dplyRSPS"
$destMfstFile 		= "$destFolder\$dplyRSPSManifest"


if(!(Test-Path $destFolder)){New-Item -Path $destFolder -ItemType directory -Force}

$webclient = New-Object system.Net.WebClient

try
{
	write-host "GETRSPS`: Downloading deploy RSPS script - $dplyRSPS"
    write-host "GETRSPS`: Source path - $srcDply"
	write-host "GETRSPS`: Destination path - $destDplyFile"
	
	$webclient.downloadfile($srcDply,$destDplyFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPS`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPS`: Error downloading source - $_"
		}
	
}

try
{
		write-host "GETRSPS`: Downloading RSPS manifest - $dplyRSPoshManifest"
        write-host "GETRSPS`: Source path - $srcDplyManifest"
		write-host "GETRSPS`: Destination path - $destMfstFile"

		$webclient.downloadfile($srcDplyManifest,$destMfstFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPS`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPS`: Error downloading source - $_"
		}
	
}


set-location $destFolder
. .\$dplyRSPS
