param(
  [Parameter(Mandatory=$false)]$appendToName = $null
)

Set-Location "C:\Users\michael\Documents\GitHub\RightScalePowerShell\Samples\BuildDeployments"
#-------------------------------------------------------------
#FUNCTONS
#-------------------------------------------------------------
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

#-------------------------------------------------------------------


cls

Write-Host "Loading RightScale cmdlets"

$rsPoshDllPath = 'c:\RSTools\RSPS\RightScale.netClient.Powershell.dll'

import-module $rsPoshDllPath

$rsModelFile = "deploymentModels.xml"

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
			  Start-Job -Name $jobNameLaunchServer -ScriptBlock {new-rssession -username $args[0] -password $args[1] -accountid $args[2];launch-RSServer -serverID $args[3]} -InitializationScript {Import-Module c:\rstools\rsps\rightscale.netclient.powershell} -ArgumentList @($rsAccountUserName,$rsAccountPwd,$rsAccountID,$newServerID)
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

