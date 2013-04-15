cls
#---START:  FUNCTIONS-------------------

function Registry
{
param(
		$path,
		$name,
		$value
	  )

  Set-ItemProperty -Path $path -Name $name -Value $value



}

#---END: FUNCTIONS-----------------------

#TODO:  set path to shell download

[xml]$xmlConfig = gc .\manifest.RSPOSH.xml

$lstRepos = $xmlConfig.RSPOSH.REPOSITORIES.REPOSITORY
$localRSToolsDir = "c:\RSTools\RSPosh"

if(!$(Test-Path $localRSToolsDir)){New-Item -Path $localRSToolsDir -ItemType directory}

#---------------------
$wc = New-Object system.Net.WebClient

foreach($repo in $lstRepos)
{
	$srcReposName = $repo.NAME
	$srcReposPath = $repo.PATH
	
	Write-Host "DPLYRSPOSH`: Repository - $srcReposName"
	Write-Host "DPLYRSPOSH`: Repository path - $srcReposPath"
	
	$files = $repo.files

	foreach($file in $files.file)
	{	
	  $srcFileName  = $file.NAME	
	  $thisFileSrcPath = $srcReposPath + "/" + $srcFileName
	
  	  Write-Host "DPLYRSPOSH`: Src File - $srcFileName"
	  Write-Host "DPLYRSPOSH`: Src File URL - $thisFileSrcPath"		

	  $destFilePath = $localRSToolsDir + "\" + $srcFileName.Replace("/","\") 
		
	  if($srcFileName -match "/")
	  {
	
		$destFolderPath = $destFilePath.Substring(0,($destFilePath.LastIndexOf("\")))

		Write-Host "DPLYRSPOSH`: Checking if destination folder exists - $destFolderPath"
		if(!(test-path $destFolderPath)){New-Item -Path $destFolderPath -ItemType directory}
	}
	 else
	 {
	 	$destFolderPath = $localRSToolsDir
		$destFilePath	= $localRSToolsDir + "\" + $srcFileName	
	 }
	
	Write-Host "DPLYRSPOSH`: Destination folder - $destFolderPath"
	Write-Host "DPLYRSPOSH`: Destination file path - $destFilePath"
	
	try
	{
		Write-Host "DPLYRSPOSH`: Getting source - $srcFileName"
		Write-Host "DPLYRSPOSH`: Destination - $destfilepath"
		
		$wc.downloadfile($thisFileSrcPath,$destfilepath)
	}
	catch [System.Net.WebException]
	{
		if($_.Exception.InnerException)
		{
			Write-Host "DPLYRSPOSH`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "DPLYRSPOSH`: Error downloading source - $_"
		}
	
	}
	catch
	{
		Write-Host "DPLYRSPOSH`: Error downloading source - $_"
	}
  }
}

Set-Location $localRSToolsDir

write-host "DPLYRSPOSH`:  Creating shortcut"
. ".\create_RSPS_shortcut.ps1"

write-host "DPLYRSPOSH`:  Finished"