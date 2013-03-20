
#TODO:  Add header descripton block

function get-RSDeployments
{

<#
.SYNOPSIS
	Gets the Deployments for the authenticated account
.DESCRIPTION
	Before using this you must be connected and authenticated to RightScale
.PARAMETER $filter
    Filter to limit Deployments returned
.PARAMETER $view
	View to be returned, default view is "default"
.EXAMPLE
	get-RSSDeployments
.EXAMPLE
	get-RSDeployments -view $view
#>

[CmdletBinding()]
	param
	(
		[string]$filter=$null, [string]$view="default"
	)

	try
	{
		if(!$filter)
		{
			[RightScale.netClient.Deployment]::index()
		}
		else
		{
			[RightScale.netClient.ServerTemplate]::index($filter,$view)
		}
	}
	catch
	{
		Write-Host $_
	}
}
