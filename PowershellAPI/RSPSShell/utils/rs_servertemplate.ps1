function get-RSServerTemplates
{

<#
.SYNOPSIS
	Gets the Server Templates for the authenticated account
.DESCRIPTION
	Before using this you must be connected and authenticated to RightScale
.PARAMETER $filter
    Filter to limit Server Templates returned
.PARAMETER $view
	View to be returned, default view is "default"
.EXAMPLE
	get-RSServerTemplates
.EXAMPLE
	get-RSServerTemplates -view $view
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
			[RightScale.netClient.ServerTemplate]::index($view)
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
