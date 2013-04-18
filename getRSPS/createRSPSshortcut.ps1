
#create desktop short cut for RS PS session

#link props
$psPath 	= 'c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$startFolder	= "c:\RSTools\RSPosh"
$iconLocation 	= "c:\RSTools\RSPosh\RSPS.ico"
$args 		=  '-noexit -file c:\RSTools\RSPosh\rsps_profile.ps1'
$shortCutName 	= "RSPosh.lnk"
$linkPath       = Join-Path ([Environment]::GetFolderPath("Desktop")) $shortCutName
$description 	= "RightScale Powershell session"


#create the link
$link            = (New-Object -ComObject WScript.Shell).CreateShortcut($linkPath)

$link.WorkingDirectory = $startFolder
$link.Description = $description
$link.Arguments = $args
$link.IconLocation = $iconLocation
$link.TargetPath = $psPath

$link.Save()