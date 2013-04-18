cls

[xml]$xmlConfig = gc .\manifest.RSPS.xml

$lstRepos = $xmlConfig.RSPOSH.REPOSITORIES.REPOSITORY
$localRSToolsDir = "c:\RSTools\RSPS"

if(!$(Test-Path $localRSToolsDir)){New-Item -Path $localRSToolsDir -ItemType directory}

#---------------------
$wc = New-Object system.Net.WebClient

foreach($repo in $lstRepos)
{
	$srcReposName = $repo.NAME
	$srcReposPath = $repo.PATH
	
	Write-Host "DPLYRSPS`: Repository - $srcReposName"
	Write-Host "DPLYRSPS`: Repository path - $srcReposPath"
	
	$files = $repo.files

	foreach($file in $files.file)
	{	
	  $srcFileName  = $file.NAME	
	  $thisFileSrcPath = $srcReposPath + "/" + $srcFileName
	
  	  Write-Host "DPLYRSPS`: Src File - $srcFileName"
	  Write-Host "DPLYRSPS`: Src File URL - $thisFileSrcPath"		

	  $destFilePath = $localRSToolsDir + "\" + $srcFileName.Replace("/","\") 
		
	  if($srcFileName -match "/")
	  {
	
		$destFolderPath = $destFilePath.Substring(0,($destFilePath.LastIndexOf("\")))

		Write-Host "DPLYRSPS`: Checking if destination folder exists - $destFolderPath"
		if(!(test-path $destFolderPath)){New-Item -Path $destFolderPath -ItemType directory}
	}
	 else
	 {
	 	$destFolderPath = $localRSToolsDir
		$destFilePath	= $localRSToolsDir + "\" + $srcFileName	
	 }
	
	Write-Host "DPLYRSPS`: Destination folder - $destFolderPath"
	Write-Host "DPLYRSPS`: Destination file path - $destFilePath"
	
	try
	{
		Write-Host "DPLYRSPS`: Getting source - $srcFileName"
		Write-Host "DPLYRSPS`: Destination - $destfilepath"
		
		$wc.downloadfile($thisFileSrcPath,$destfilepath)
	}
	catch [System.Net.WebException]
	{
		if($_.Exception.InnerException)
		{
			Write-Error "DPLYRSPS`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Error "DPLYRSPS`: Error downloading source - $_"
		}
	
	}
	catch
	{
		Write-Host "DPLYRSPS`: Error downloading source - $_"
	}
  }
}

Set-Location $localRSToolsDir

#set env variable for RSPosh path
Write-Host "DPLYRSPS`: Adding ENV variable - RSPSPath - $localRSToolsDir"
[Environment]::SetEnvironmentVariable("RSPSPath", $localRSToolsDir, "Machine")


write-host "DPLYRSPS`: Creating shortcut"
. ".\createRSPSshortcut.ps1"

write-host "DPLYRSPS`: Finished"