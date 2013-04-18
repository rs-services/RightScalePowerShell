cls

$gitURL = "https://raw.github.com/patrickmcclory/RightScalePowerShell/master/getRSPosh"
$dplyRSPosh 	= "deployRSPosh.ps1"
$dplyRSPoshManifest = "manifest.rsposh.xml"

$srcDply			= $gitURL + "/" + $dplyRSPS
$srcDplyManifest	= $gitURL + "/" + $dplyRSPSManifest
$destFolder   		= "c:\RSTools\RSPS"
$destDplyFile 		= "$destFolder\$dplyRSPS"
$destMfstFile 		= "$destFolder\$dplyRSPSManifest"


if(!(Test-Path $destFolder)){New-Item -Path $destFolder -ItemType directory -Force}

$webclient = New-Object system.Net.WebClient

try
{
	write-host "GETRSPOSH`: Downloading deploy RSPS script - $dplyRSPosh"
    write-host "GETRSPOSH`: Source path - $srcDply"
	write-host "GETRSPOSH`: Destination path - $destDplyFile"
	
	$webclient.downloadfile($srcDply,$destDplyFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPOSH`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPOSH`: Error downloading source - $_"
		}
	
}

try
{
		write-host "GETRSPOSH`: Downloading RSPS manifest - $dplyRSPoshManifest"
        write-host "GETRSPOSH`: Source path - $srcDplyManifest"
		write-host "GETRSPOSH`: Destination path - $destMfstFile"

		$webclient.downloadfile($srcDplyManifest,$destMfstFile)
}
catch [System.Net.WebException]
{
		if($_.Exception.InnerException)
		{
			Write-Host "GETRSPOSH`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "GETRSPOSH`: Error downloading source - $_"
		}
	
}


set-location $destFolder
. .\$dplyRSPS
