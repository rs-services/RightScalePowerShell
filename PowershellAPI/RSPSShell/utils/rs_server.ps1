function get-RSServer
{

<#
.SYNOPSIS
	Gets the Servers for the authenticated account
.DESCRIPTION
	Before using this you must be connected and authenticated to RightScale
.PARAMETER $filter
    Filter to limit Servers returned
.PARAMETER $view
	View to be returned, default view is "default"
.EXAMPLE
	get-RSServer
.EXAMPLE
	get-RSServer -view $view
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
			[RightScale.netClient.Server]::index($view)
		}
		else
		{
			[RightScale.netClient.Server]::index($filter,$view)
		}
	}
	catch
	{
		Write-Host $_
	}
}
