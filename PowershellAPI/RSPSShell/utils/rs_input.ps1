


function get-RSInputs
{

<#
.SYNOPSIS
	Gets the Inputs for ServerTemplate or Deployment
.DESCRIPTION
	Returns the Inputs for ServerTemplate or Deployment. Before using this you must be connected and authenticated to RightScale
.PARAMETER $id
	id of either a ServerTemplate or Deployment
.PARAMETER $type
	Type of object to get iputs for - either servertemplate or deployment
.EXAMPLE
	get-RSInputs -id 375398001 -type deployment
.EXAMPLE
	get-RSInput -type $type -id
#>

[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)][string]$id, 
		[parameter(Mandatory = $true)][string]$type,
		[parameter(Mandatory = $false)][string]$view="default"
	)
	
	if($type -ne "deployment" -and $type -ne "servertemplate"){throw """Type"" parameter must be servertemplate or deployment"}


	try
	{		
			switch($type)
			{
				"servertemplate"
				{
					[RightScale.netClient.Input]::index_servertemplate($id,$view)
				}
				"deployment"
				{
					[RightScale.netClient.Input]::index_deployment($id,$view)
				}
			
			}
	}
	catch	
	{
		if($e.Exception.InnerException.ErrorData){Write-Host $e.Exception.InnerException.ErrorData}
		Write-Host $_
	}
}