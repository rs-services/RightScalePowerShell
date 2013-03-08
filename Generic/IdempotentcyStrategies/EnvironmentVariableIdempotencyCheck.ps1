$installEnvVar = "unique_install_name_goes_here"
$installEnvVarScope = "Machine"
 
$installFlag = [Environment]::GetEnvironmentVariable($installEnvVar, $installEnvVarScope)
 
try {
    if (!$installFlag) 
    {   
        #CUSTOM CODE START
 
        #CUSTOM CODE END
 
        $installEnvVarValue = Get-Date
    
        Write-Host "Setting Environment variable $installEnvVar at scope $installEnvVarScope to value $installEnvVarValue"
        [Environment]::SetEnvironmentVariable($installEnvVar, $installEnvVarValue, $installEnvVarScope)
        Write-host "Setting local copy of install env var to $installEnvVarValue"
    }
    else 
    {
        Write-Host "$instalEnvVar was installed at $installFlag.  This process will exit without performing any action and without error."
        exit 0
    }
}
catch 
{
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.StackTrace
    exit 1
}
