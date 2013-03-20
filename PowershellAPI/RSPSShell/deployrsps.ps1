
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

[xml]$xmlConfig = gc .\manifest.rspsshell.xml

$srcRepos	 = $xmlConfig.RSPSSHELL.REPOSITORY
$files = $xmlConfig.RSPSSHELL.FILES

$srcReposName = $srcRepos.NAME
$srcReposPath = $srcRepos.PATH

$localRSToolsDir = "c:\RSTools\RSPSshell"

Write-Host "DPLYRSPSSHELL`: Repository - $srcReposName"
Write-Host "DPLYRSPSSHELL`: Repository path - $srcReposPath"

if(!$(Test-Path $localRSToolsDir)){New-Item -Path $localRSToolsDir -ItemType directory}

#-----
$wc = New-Object system.Net.WebClient


foreach($file in $files.file)
{	
	$srcFileName  = $file.NAME	
	$thisFileSrcPath = $srcRepos.PATH + "/" + $srcFileName
	
	Write-Host "DPLYRSPSSHELL`: Src File - $srcFileName"
	Write-Host "DPLYRSPSSHELL`: Src File URL - $thisFileSrcPath"
		

	$destFilePath = $localRSToolsDir + "\" + $srcFileName.Replace("/","\") 
		
	if($srcFileName -match "/")
	{
	
		$destFolderPath = $destFilePath.Substring(0,($destFilePath.LastIndexOf("\")))

		Write-Host "DPLYRSPSSHELL`: Checking if destination folder exists - $destFolderPath"
		if(!(test-path $destFolderPath)){New-Item -Path $destFolderPath -ItemType directory}
	  

	  	#$tknsSrcFileName = $srcFileName.Split("/")	  
	  	#$len = $tknsSrcFileName.length
	  
	  	#$i = $tknsSrcFileName[$len]
	  	#$fixSrcName = $tknsSrcFileName[$i - 1]
		
		#$destFolders = $tknsSrcFileName | ?{$_ -ne $fixSrcName}
		#$destFolderPath = $destFolders -join "/"
	}
	 else
	 {
	 	$destFolderPath = $localRSToolsDir
		$destFilePath	= $localRSToolsDir + "\" + $srcFileName
	
	 }
	
	Write-Host "DPLYRSPSSHELL`: Destination folder - $destFolderPath"
	Write-Host "DPLYRSPSSHELL`: Destination file path - $destFilePath"
	
	try
	{
		Write-Host "DPLYRSPSSHELL`: Getting source - $srcFileName"
		Write-Host "DPLYRSPSSHELL`: Destination - $destfilepath"
		
		$wc.downloadfile($thisFileSrcPath,$destfilepath)
	}
	catch [System.Net.WebException]
	{
		if($_.Exception.InnerException)
		{
			Write-Host "DPLYRSPSSHELL`: Error downloading source - $($_.exception.innerexception.message)"
		}
		else
		{
			Write-Host "DPLYRSPSSHELL`: Error downloading source - $_"
		}
	
	}
	catch
	{
		Write-Host "DPLYRSPSSHELL`: Error downloading source - $_"
	}
}

write-host "DPLYRSPSSHELL`:  Creating shortcut"
. ".\create_RSPS_shortcut.ps1"

write-host "DPLYRSPSSHELL`:  Finished"