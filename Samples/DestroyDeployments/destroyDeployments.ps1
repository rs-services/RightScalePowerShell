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
	$deploys  = get-RSDeployments
    
    $dplysFiltered = $deploys | ?{$_.name -match "Model"} 
    
    write-host "Found $($dplysFiltered.count) Deployments"
    write-host "-----------------------------------------------"
    $dplysFiltered | %{
      write-host "Deployment`: $($_.name)"
      write-host "`t($_.servers | select name,state)"
    }
    
    #Confirm destroying
    $choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes"
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No"
    $title = "Confirm destroying Deployments"
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
	   Write-Host "Destroying Deployments matching - $filter"
	   $deploys | ?{$_.name -match "Model"} | select id  | %{Remove-RSDeployment $_.id}

       Write-Host ""
	   Write-Host "Finished Destroying Deployments"
    }
}
else
{
  Write-Host "Error connecting to RightScale"
  exit 1
}