


function get-RSImages
{

<#
.SYNOPSIS
	Gets the Images for the authenticated account
.DESCRIPTION
	Teturns the Images for this account. Before using this you must be connected and authenticated to RightScale
.PARAMETER $filter
    Filter to limit Server Templates returned
.PARAMETER $view
	View to be returned, default view is "default"
.EXAMPLE
	get-RSImage
.EXAMPLE
	get-RSImage -view $view -filter "description==Windows"
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
			[RightScale.netClient.Image]::index($view)
		}
		else
		{
		    Write-Host "Filter - $filter"
			[RightScale.netClient.Image]::index($filter,$view)
		}
	}
	catch
	{
		Write-Host $_
	}
}