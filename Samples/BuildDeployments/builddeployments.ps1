
Set-Location 'C:\Users\michael\Documents\GitHub\RightScaleNetAPI\RightScale.netClient\Samples\BuildDeployments'
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

$rsPoshDllPath = 'C:\Users\michael\Documents\GitHub\RightScaleNetAPI\RightScale.netClient\RSPosh\bin\Debug\RSPosh.dll'

import-module $rsPoshDllPath

$rsModelFile = "deploymentModels.xml"

[xml]$mdlBuild  = gc .\$rsModelFile
if(!$mdlBuild){Write-Host "Error loading model file - $rsModelFIle";exit 1}

#get rs creds
$rsAccountID = $mdlBuild.RSMODEL.RIGHTSCALE.Account
$rsAccountUserName = $mdlBuild.RSMODEL.RIGHTSCALE.Username
$rsAccountPwd = $mdlBuild.RSMODEL.RIGHTSCALE.password

#arrays to hold tag values
$hshInputs = @{}
$hshDplyTags = @{}
$hshSrvTags = @{}

#get default inputs
$rsDefInputs = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.INPUTS.INPUT
$rsDefDplyTags = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.TAGS.TAG | ?{$_.scope -eq "DEPLOYMENT"}
$rsDefSrvTags = $mdlBuild.RSMODEL.DEPLOYMENTS.DEFAULTS.TAGS.TAG | ?{$_.scope -eq "SERVER"}

#get credentials if not in xml file
if([String]::IsNullOrEmpty($rsAccountID)){$rsAccountID = Read-Host "RightScale Account"}
if([String]::IsNullOrEmpty($rsAccountUserName)){$rsAccountUserName = Read-Host "RightScale Username"}
if([String]::IsNullOrEmpty($rsAccountPwd)){$rsAccountPwd = Read-Host "RightScale Password" -AsSecureString}

#add default inputs and tags
if($rsDefInputs){$rsDefInputs | %{$hshInputs.add($_.name,$_.value)}}
if($rsDefDplyTags){$rsDefDplyTags | %{$hshDplyTags.add(($_.prefix + "`:" + $_.tagname),$_.value)}}
if($rsDefSrvTags){$rsDefSrvTags | %{$hshSrvTags.add(($_.prefix + "`:" + $_.tagname),$_.value)}}

Write-Host "Logging in to RightScale account - $rsAccountID"
$session = New-RSSession -username $rsAccountUserName -password (ConvertFrom-SecureToPlain $rsAccountPwd) -accountid $rsAccountID

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
		
   		#add / update tag and input list
		if($dplyInputs){$dplyInputs | %{if($hshInputs.Contains($_.name)){$hshInputs.Remove($_.name)}; $hshInputs.Add($_.name,$_.value)}}
		
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
		$arrDplyInputs = @()
        $hshInputs.getenumerator() | %{$_} | ?{$_.name} | %{$val = $_.name + ":" + $_.value;$arrDplyInputs += $val}

		#set deployments inputs
		Write-Host "Setting server input values"
		if($arrDplyInputs){$resSetInputs = Set-RSServerInputs -serverid $newDplyID -inputs $arrDplyInputs}
		
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
			
			#add / update inputs and tags
			#if($srvInputs.count -gt 0){$srvInputs | %{if($hshInputs.Contains($_.name)){$hshInputs.Remove($_.name)}; $hshInputs.Add($_.name,$_.value)}}
            if($srvInputs.count -gt 0){$srvInputs | %{$srvInputs.Add($_.name,$_.value)}}
            
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

		try
		{
		
      		$newServersObj = new-rsserver -servername $newServerName -deploymentid $newDplyID -servertemplate $serverTemplate -cloudid  $dplyCloudID
	    
			$newServerID = $newServersObj.ServerID
			
			#get new server object
			$newServer = get-RSServer -serverid $newServerID			
			$newServerHref = $newServer.Href
			
			Write-Host "New Server ID - $newServerID"
		
	    	#add obj to use later
			$newServerIDs += $newServerObj
		
			#build string array of input values
			if($srvInputs)
            {
              $arrSrvInputs = @()
              $srvInputs.getenumerator() | %{$_} | ?{$_.name} | %{            
            	$val = $_.name + ":" + $_.value	
				$arrSrvInputs += $val            
               }
               
              #set inputs
			  Write-Host "Setting server input values"
			  if($arrSrvInputs){$rsSetInputs = Set-RSServerInputs -serverid $newServerID -inputs $arrSrvInputs}  
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
		  	Write-Host "Launching server"
		  	$resLaunch = launch-RSServer -serverID $newServerID
		  
		  	Write-Host $resLaunch.Message
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
}
else
{
  Write-Host "Error connecting to RightScale"
  exit 1
}

