param(
	[Parameter(Mandatory=$true)]$accountID,
	[Parameter(Mandatory=$true)]$username,
	[Parameter(Mandatory=$true)][Security.SecureString]$password,
    [Parameter(Mandatory=$true)]$namefilter
)


cls

Write-Host "Loading RightScale cmdlets"

$rsPSDllPath = 'c:\RSTools\RSPS\RightScale.netClient.Powershell.dll'

import-module $rsPSDllPath

Write-Host "Logging in to RightScale account - $accountID"
$session = New-RSSession -username $username -password $password -accountid $accountID

if($session -match "Connected")
{
	Write-Host "Connected to RightScale"
	
	Write-Host "Getting Deployments"
	try
	{
	  $deploys  = get-RSDeployments
    }
	catch
	{
	  Write-Host "Error getting deployments - $_"
	}
    $dplysFiltered = @($deploys | ?{$_.name -match $namefilter} )
    
    write-host "Found $($dplysFiltered.count) Deployment(s) matching - $($namefilter)"
    write-host "-----------------------------------------------"
	
	if($dplysFiltered.count -lt 1)
	{
	  Write-Host ""
	  Write-Host "No Deployments found matching - $($namefilter)"
	  exit	
	}
	
    $dplysFiltered | %{
      $dplyServers = $_.servers | select name,state,id
	  
      write-host "Deployment`: $($_.name)" -foregroundcolor yellow
	  
	  if($dplyServers)
	  {
        write-host "Servers`:"
        write-output $dplyServers | ft -hide
        write-host ""
	  }
	  else
	  {
	    Write-Host "No Servers"
		Write-Host ""
	  }
    }
    
    #Confirm destroying
    $choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes"
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No"
    $title = "Confirm destroying Deployment(s)"
    $caption = ""
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
    
	$doDestroy = $host.ui.PromptForChoice($title, $message, $options, 1)
    
    if($doDestroy -eq 1)
    {
        write-host "Not Destroying - Quitting"
        exit
    }
    else
    {    
	   Write-Host "Destroying Deployment(s) matching - $namefilter"
       foreach($dply in $dplysFiltered)
       {
         Write-Host "Destroying $($dply.name)"
         $srvrs = $dply.servers
         $operSrvrs = @($srvrs | ?{$_.state -notmatch "inactive"})
         
         if($operSrvrs)
         {
           Write-Host "Deployment - $($dply.name) has $($operSrvrs.count) Server(s) not in inactive state" -foregroundcolor red
           Write-Output $operSrvrs | select name,state,id
           write-host ""
           Write-Host "Servers need to be terminated before destroying Deployment"
           $title = "Confirm Terminating Deployment Servers"
           $caption = ""
	       $options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
    
	       $doTermSrv = $host.ui.PromptForChoice($title, $message, $options, 1)
           
           if($doTermSrv -eq 0)
           {
             foreach($srv in $operSrvrs)
             {
               write-host "Terminating Server - $($srv.name)"
               Terminate-RSServer -serverID $srv.id               
               
               $i = 0
               Do
               {
		              $i++
		
		              #Get the Sever Current State
                      $curServer = get-RSServer -serverID $srv.id
		              $curState = $curServer.state

                      if($i -gt 100){$i -eq 100}
		              write-progress -activity "Terminating Server..." -status "Waiting...$i" -percentcomplete $i
		              Start-Sleep -s 2
		      }
			  while ($curState -notmatch "inactive" -or $i -gt 300)
             

            }
           }
           else
           {
             continue
           }
           
         
         }
       
         Destroy-RSDeployment $dply.id


       }
	   
    }
    
       Write-Host ""
	   Write-Host "Finished Destroying Deployments"
}
else
{
  Write-Host "Error connecting to RightScale"
  exit 1
}