param(
  [Parameter(Mandatory=$false)]$appendToName = $null
)

#------------------------------------------------------
#TODO:  
#------------------------------------------------------
#Server count for multiple servers of same settings
#get dll path to load dynamically,  if .net installed
#param for model file path / name to process
#delay in launching for rs to catchup,  server failed to launch right away but then launched fine
#dependencies for launching
#scriptblock for launch job

#-------------------------------------------------------------
#FUNCTONS
#-------------------------------------------------------------
#----------------------------------------------------------------------------------
#Util Globals
#----------------------------------------------------------------------------------
$script:scriptfullname 		= $MyInvocation.scriptname
$script:scriptname 			= Split-Path $scriptfullname -Leaf
$script:scriptpath			= Split-Path $scriptfullname -Parent
$script:dt_logfile			= get-date -format "yyyyMMdd_hhmm"
$script:logpath				= $scriptpath + "\" + "Logs"
$script:logfile				= "$logpath`\$scriptname" + "_" + $dt_logfile + ".log"
$script:iLogWrite			= $false
$script:hshErrs				= @{}
#$script:evtlogname			= "RSScriptQA"
#$script:evtlogsource		= "RSScriptQA"

#----------------------------------------------------------------------------------
#FUNCTION BEGIN:  LogEntry
#DESCRIPTION:  Write-Host add log enteries after log file is created
#TODO:  add event log and write to that also
#PARAMS: $scriptlocation $msg $msgLevel $evt $evtNum
#----------------------------------------------------------------------------------
function LogEntry
  {
    param([string]$scriptlocation = "NULL", [string]$msg, [string]$msgLevel = "INFO", $evt = $null, $evtNum = $null)

	$functionName	= "LOGENTRY"	
	$script:now 	= get-date -format "yyyyMMdd:hh:mm"
	$msg			= $msg.substring(0, [System.Math]::Min($msg.Length, 5000))
	$logmsg			= $now + ': ' + $scriptlocation + " - " + $msg

	
	switch($msgLevel)
	  {
	    "INFO"
			{$foregroundcolor	= "white"
			 $infoevent	= [System.Diagnostics.EventLogEntryType]::Information
			}
	    "WARNING"
			{$foregroundcolor	= "yellow"
			 $infoevent	= [System.Diagnostics.EventLogEntryType]::Warning
			}
	    "ERROR"
			{$foregroundcolor	= "red"
			 $infoevent	= [System.Diagnostics.EventLogEntryType]::Error
			}
	    "DEBUG"
			{$foregroundcolor	= "green"
			 $infoevent	= [System.Diagnostics.EventLogEntryType]::Information
			}
	  }

	if(!$foregroundcolor){$foregroundcolor = "cyan"}

	write-host $logmsg -foregroundcolor $foregroundcolor

	if($iLogWrite)
	{
	  add-content $logfile $logmsg
	}
	
	if($msgLevel -ieq "ERROR")
	{
	  $thisErrMsg = $scriptlocation + "`: " + $msg	# + "-" + $global:errnum
	  
	  if(!$hshErrs.containsvalue($thisErrMsg))
	    {
		  $hshErrs.add($script:errnum, $thisErrMsg)		  
		  $script:errnum = $script:errnum + 1	
		}
	}
	
	if($evt)
	{	
		if(![System.Diagnostics.EventLog]::SourceExists($evtlogname))
		{		  
		  #-----Create Event Log and set props
		  New-EventLog -LogName $evtlogname -Source $evtlogname		  
		  $thisevtlog = New-Object system.Diagnostics.EventLog($evtlogname)
		  $thisevtlog.ModifyOverflowPolicy([System.Diagnostics.OverflowAction]::OverwriteAsNeeded,0)
		  $thisevtlog.MaximumKilobytes = 2194240
		  
		  LogEntry -scriptlocation "CREATEEVENTLOG" -msg "Created event log - $evtlogname" -msgLevel "INFO" -evt $true -evtNum 250
		}
		
		$evtentry			= new-object System.Diagnostics.EventLog($evtlogname)
		$evtentry.Source	= $evtlogsource	
		

		$evtentry.WriteEntry($logmsg, $infoevent, $evtNum, 2)
		
		$msg = $null
	}
  }
#----------------------------------------------------------------------------------
#FUNCTION END:  LogEntry
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
#FUNCTION START:  CreateLog
#----------------------------------------------------------------------------------
function CreateLog
{
	#create log file and switch logging to write log entries
		
	LogEntry -scriptlocation "LOG" -msg "Creating new log file - $logfile" -msgLevel "INFO" -evt $true -evtNum 4000

	#check of log dir exists
	$logdir = Split-Path -Path $logfile -Parent
	if(Test-Path -Path $logdir)
	{
		LogEntry -scriptlocation "LOG" -msg "Log Directory`: Found $logdir" -msgLevel "INFO" -evt $true -evtNum 4000		
	}
	else
	{	
		LogEntry -scriptlocation "LOG" -msg "Log Directory`: $logdir not found - creating" -msgLevel "INFO" -evt $true -evtNum 4000
		New-Item $logdir -ItemType Directory
	}
	
	if(test-path $logfile)
	  {
		LogEntry "CREATELOG" "Renaming existing log file - $logfile" "INFO" $true 4101
		
		$ext = Get-Date -format 'yyyyMMddhhmmss'
		$archlogfile = $scriptname + "_" + $ext + ".log"
		
		rename-item $logfile $archlogfile
		
		LogEntry "CREATELOG" "Log file created - $logfile" "INFO" $true 4102
		
		$script:iLogWrite = $true
	  }
	else
	  {	
	  
		add-content -path $logfile "Starting new log"
		LogEntry "CREATELOG" "Log file created - $logfile" "INFO" $true 4103
		
		$script:iLogWrite = $true
		
	  }
}

#----------------------------------------------------------------------------------
#FUNCTION END:  CreateLog
#----------------------------------------------------------------------------------
function ConvertFrom-SecureToPlain {
    
    param( [Parameter(Mandatory=$true)][System.Security.SecureString] $SecurePassword)
    
    # Create a "password pointer"
    $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    
    # Get the plain text version of the password
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
    
    # Free the pointer
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
    
    # Return the plain text password
    $PlainTextPassword
    
}

#-------------------------------------------------------------

#-------------------------------------------------------------
#VARS
#-------------------------------------------------------------
$rsPoshDllPath = 'C:\Program Files (x86)\RightScale\PowerShell\RightScale.netClient.Powershell.dll'
$rsModelFile = "deploymentModels.xml"

cls

Write-Host "Loading RightScale cmdlets"


#-------------------------------------------------------------
#LOAD MODULES
#-------------------------------------------------------------
import-module $rsPoshDllPath
#-------------------------------------------------------------

#-------------------------------------------------------------
#MAIN
#-------------------------------------------------------------

[xml]$mdlBuild  = gc .\$rsModelFile
if(!$mdlBuild){Write-Host "Error loading model file - $rsModelFIle";exit 1}

#get rs creds
$rsAccountID = $mdlBuild.RSMODEL.RIGHTSCALE.Account
$rsAccountUserName = $mdlBuild.RSMODEL.RIGHTSCALE.Username
$rsAccountPwd = $mdlBuild.RSMODEL.RIGHTSCALE.password

#arrays to hold tag values
$hshDplyInputs = @{}
$hshSrvInputs = @{}
$hshDplyTags = @{}
$hshSrvTags = @{}
$scriptErrors = @()

#get default inputs
$rsDefDplyInputs = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.INPUTS.INPUT | ?{$_.scope -eq "DEPLOYMENT"}
$rsDefSrvInputs = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.INPUTS.INPUT | ?{$_.scope -eq "SERVER"}
$rsDefDplyTags = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.TAGS.TAG | ?{$_.scope -eq "DEPLOYMENT"}
$rsDefSrvTags = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.TAGS.TAG | ?{$_.scope -eq "SERVER"}

#get credentials if not in xml file
if([String]::IsNullOrEmpty($rsAccountID)){$rsAccountID = Read-Host "RightScale Account"}else{Write-Host "Rightscale Account (from config file) - $rsAccountID"}
if([String]::IsNullOrEmpty($rsAccountUserName)){$rsAccountUserName = Read-Host "RightScale Username"}else{Write-Host "Rightscale User (from config file) - $rsAccountUserName"}
if([String]::IsNullOrEmpty($rsAccountPwd)){$rsAccountPwd = Read-Host "RightScale Password" -AsSecureString}

#add default inputs and tags
if($rsDefDplyInputs){$rsDefDplyInputs | %{$hshDplyInputs.add($_.name,$_.value)}}
if($rsDefSrvInputs){$rsDefSrvInputs | %{$hshSrvInputs.add($_.name,$_.value)}}
if($rsDefDplyTags){$rsDefDplyTags | %{$hshDplyTags.add(($_.prefix + "`:" + $_.tagname),$_.value)}}
if($rsDefSrvTags){$rsDefSrvTags | %{$hshSrvTags.add(($_.prefix + "`:" + $_.tagname),$_.value)}}

Write-Host "Logging in to RightScale account - $rsAccountID"
$session = New-RSSession -username $rsAccountUserName -password $rsAccountPwd -accountid $rsAccountID

Write-Host $session

if($session -match "Connected")
{

	foreach($deployment in $mdlBuild.RSMODEL.DEPLOYMENTS.deployment)
	{
		#region deployment creation
		
  		$dplyName		= $deployment.NAME
  		$dplyDesc 		= $deployment.DESCRIPTION
	  	$dplyCloudID	= $deployment.CLOUDID
		$dplyInputs 	= $deployment.inputs.input
		$dplyTags 		= $deployment.tags.tag | ?{$_.scope -eq "DEPLOYMENT"}
		
		if($appendToName){$dplyName = $dplyName + $appendToName}
		
   		#build input hash
		if($dplyInputs.count -gt 0)
        {
          foreach($dplyInput in $dplyInputs)
          {
            if($hshDplyInputs.Contains($dplyInput.name))
            {
              $hshDplyInputs.Remove($dplyInput.name)
              $hshDplyInputs.Add($dplyInput.name,$dplyInput.value)
            }
            else
            {
              $hshDplyInputs.Add($dplyInput.name,$dplyInput.value)
            }
          }
		}
        
		#build deployment tags hash
		if($dplyTags.count -gt 0)
        {
         foreach($dplyTag in $dplyTags)
         {
           $thisKeyName = $dplyTag.prefix + "`:" + $dplyTag.tagname
                
           if($hshDplyTags.Contains($thisKeyName))
           {
             $hshDplyTags.Remove($thisKeyName)
             $hshDplyTags.Add($thisKeyName,$dplyTag.value)
           }
           else
           {
             $hshDplyTags.Add($thisKeyName,$dplyTag.value)
           }
         }		
        }

			
  		#create deployment
  		Write-Host "Create Deployment`:  $dplyName"
        Write-Host "CloudID`: $dplyCloudID"
  
	  	try
  	  	{
    		$newDplyID = new-rsdeployment -name $dplyName
			Write-Host "Deployment created"
  		}
  		catch
  		{
    		Write-Host "Error creating deployment"
			Write-Host $_
			Write-Host "$($_.Exception.APIHref)"
	
		    exit 1
  		}
		
		#get new deploymnet href
		Write-Host "Getting new Deployment"
		$newDplyID = $newDplyID.DeploymentID
		$newDply = get-RSDeployment -deploymentid $newDplyID
		$newDplyHref = $newDply.href
		
		#set deployment tags
		#--------------------------------
		Write-Host "Getting Deployment Tags"
        [string[]]$dplyTags = @()
            
        foreach($key in $hshDplyTags.keys)
        {              
          $newDplyTag = $key + "=" + $hshDplyTags[$key]
		  Write-Host "New Deployment Tag - $newDplyTag"
          $dplyTags += $newDplyTag
        }
                      
		Write-Host "Setting Deployment tags"
            
        try
        {
		  Write-Host "Setting Deployment Tags"
		  $resSetTags = Set-RSTags -href $newDplyHref -tags $dplyTags
		}
        catch
        {
        	Write-Host "Error setting Deployment Tags - $_"
        }     
        #--------------------------------
		
		#set deployment inputs
		#--------------------------------
		
		#build string array of input values
        if($hshDplyInputs)
        {
		  $arrDplyInputs = @()
          $hshDplyInputs.getenumerator() | %{$_} | ?{$_.name} | %{$val = $_.name + ":" + $_.value;$arrDplyInputs += $val}

		  #set deployments inputs
		  Write-Host "Setting server input values"
		  if($arrDplyInputs)
          {
            try
            {
              $resSetInputs = Set-RSServerInputs -serverid $newDplyID -inputs $arrDplyInputs
            }
            catch
            {
              write-host "Error setting inputs - $_"
            }
        
          }
		}
		#endregion deployment creation
		
       	#region server creation	
		#deployment servers
  		$dplyServers = $deployment.SERVERS.SERVER
 
  		$newServerIDs = @()
  
  		foreach($server in $dplyServers)
  		{    
    		$newServerName = $server.NAME
			$serverTemplate = $server.servertemplate
			$srvInputs 	= $server.inputs.input
			$srvTags 	= $server.tags.tag
	
			Write-Host "Creating Server - $newServerName" 
			Write-Host "ServerTemplate - $serverTemplate"
			Write-Host "Cloud ID - $dplyCloudID"
    
            #build server tags hash
			if($srvTags.count -gt 0)
            {
              foreach($srvTag in $srvTags)
              {
                $thisKeyName = $srvTag.prefix + "`:" + $srvTag.tagname
                
                if($hshSrvTags.Contains($thisKeyName))
                {
                  $hshSrvTags.Remove($thisKeyName)
                  $hshSrvTags.Add($thisKeyName,$srvTag.value)
                }
                else
                {
                  $hshSrvTags.Add($thisKeyName,$srvTag.value)
                }
              }		
            }
            
            #build server input hash
            if($srvInputs.count -gt 0)
            {
              foreach($srvInput in $srvInputs)
              {
                $thisKeyName = $srvInput.name
                
                if($hshSrvInputs.Contains($thisKeyName))
                {
                  $hshSrvInputs.Remove($thisKeyName)
                  $hshSrvInputs.Add($thisKeyName,$srvInput.value)
                }
                else
                {
                  $hshSrvInputs.Add($thisKeyName,$srvInput.value)
                }
              }		
            }

		try
		{
		
      		$newServersObj = new-rsserver -servername $newServerName -deploymentid $newDplyID -servertemplate $serverTemplate -cloudid  $dplyCloudID
	        
			if($newServersObj.Result -ne $true)
			{
			  Write-Host "Error Creating Server - $($newServersObj.Message)" -ForegroundColor Red
			  Write-Host "$($newServersObj.APIHref)" -ForegroundColor Red
			  
			  $errMessage = "$newServerName - Error creating server" + [System.Environment]::NewLine
			  $errMessage += "`t $($newServersObj.Message)" + [System.Environment]::NewLine
			  $errMessage += "`t $($newServersObj.ErrData)" + [System.Environment]::NewLine
			  $errMessage += "`t $($newServersObj.APIHref)" + [System.Environment]::NewLine
			  $errMessage +=  [System.Environment]::NewLine
			  
			  $scriptErrors += $errMessage
			  
			  continue
			}
			
		    Write-Host "Getting new ServerID"
			$newServerID = $newServersObj.ServerID
			
			#get new server object
			$newServer = get-RSServer -serverid $newServerID			
			$newServerHref = $newServer.Href
			
			Write-Host "New Server ID - $newServerID"
		
	    	#add obj to use later
			$newServerIDs += $newServerObj
		
			#build string array of input values
			if($hshSrvInputs)
            {
              $arrSrvInputs = @()
              $hshSrvInputs.getenumerator() | %{$_} | ?{$_.name} | %{            
            	$val = $_.name + ":" + $_.value	
				$arrSrvInputs += $val            
               }
               
              #set inputs			  
			  if($arrSrvInputs)
              {
                try
                {
                  $rsSetInputs = Set-RSServerInputs -serverid $newServerID -inputs $arrSrvInputs
                }
                catch
                {
                  write-host "Error setting inputs - $($_)"
                }
              }  
            }		
			
			
			#--------------------------------
			#set tags
			Write-Host "Getting Tags"
            [string[]]$srvAddTags = @()
            
            foreach($key in $hshSrvTags.keys)
            {              
              $newSrvTag = $key + "=" + $hshSrvTags[$key]
			  Write-Host "Add Server Tag - $newSrvTag"
              $srvAddTags += $newSrvTag
            }
            
            if($srvAddTags.count -gt 0)
            {          
			     Write-Host "Setting server tags"
            
                try
                {
			         $resSetTags = Set-RSTags -href $newServerHref -tags $srvAddTags
		         }
                catch
                {
                    Write-Error "Error setting Tags - $_"
                }     
            }
            else
            {
                Write-Host "No Tags to set"
            }
			#----------------------------
			
            
            #TODO:  Move this out of server creation time
			$shouldLaunch = $server.launch
		    
            write-host "Should launch server - $shouldLaunch"
            
			if($shouldLaunch -eq $true)
			{
		  	  Write-Host "Starting Job to launch server - $newServerName"
			  $jobNameLaunchServer = "RSLaunchServer-" + $newServerName
			  Start-Job -Name $jobNameLaunchServer -ScriptBlock {new-rssession -username $args[0] -password $args[1] -accountid $args[2];launch-RSServer -serverID $args[3]} -InitializationScript {Import-Module 'C:\Program Files (x86)\RightScale\PowerShell\RightScale.netClient.Powershell.dll'} -ArgumentList @($rsAccountUserName,$rsAccountPwd,$rsAccountID,$newServerID)

			  $jobsStarted = $true
		  	  #$resLaunch = launch-RSServer -serverID $newServerID
		  	  #Write-Host $resLaunch.Message
			}
	
		}
		catch
		{
	  		Write-Error "$_"
	  		Write-Error $_.errordata
	  		Write-Error $_.Exception.InnerException.Message
			
			$scriptErrors += "$newServerName - Error launching server - $($_.errordata)"

		}	
	
	
    }  
#endregion


  
  }
  
  if($jobsStarted)
  {
    Write-Host ""
    Write-Host "Server launch jobs - ID,Name,Status" -ForegroundColor Yellow
	Write-Host "-----------------------------------------------------" -ForegroundColor Yellow
	$jobs = get-Job RSLaunch* | select id,name,state
	$jobs | %{write-host $_.id "`t" $_.name "`t" $_.state}
	
	Write-Host""
	Write-Host "Waiting for jobs to complete" -ForegroundColor Yellow
	
	$complete = $false
	while (-not $complete)
	{
		$jobs = get-Job RSLaunch* | select id,name,state
    	$arrayJobsInProgress = $jobs | ?{ $_.State -match 'running' }
    	if (-not $arrayJobsInProgress) { "All Jobs Have Completed"; $complete = $true } 
	}
	
	$jobs = get-Job RSLaunch*
	$jobs | Receive-Job | select ServerID,Result,Message
  }
}
else
{
  Write-Host "Error connecting to RightScale"
  exit 1
}

#any errors
if($scriptErrors.count -gt 0)
{
  Write-Host ""
  Write-Host ""
  Write-Host "ERRORS`:" -ForegroundColor Yellow
  Write-Host "----------------------------------------------------------------"
  foreach($err in $scriptErrors)
  {
    Write-Host $err -ForegroundColor Yellow
  }

}
