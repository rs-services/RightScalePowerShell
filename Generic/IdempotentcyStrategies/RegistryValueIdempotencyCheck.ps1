function GetRegistryValue {
    param(
        [string]$registryKeyPath, 
        [string]$registryEntryName
    )
 
    $testEntryExists = Get-ItemProperty -path $registryKeyPath -Name $registryEntryName -ErrorAction SilentlyContinue | select -ExpandProperty $registryEntryName
    if($testEntryExists)
    {
        return $testEntryExists
    }
    else
    {
        return
    }
}
 
function SetRegistryValue {
    param (
        [string]$registryKeyPath, 
        [string]$registryEntryName, 
        [string]$registryEntryValue,
        [string]$registryEntryType = "string",
        [bool]$overwriteExisting = $true
    )
 
    $workingString = ""
    write-host "Checking registry key path to ensure it exists"
    foreach($key in $registryKeyPath.split('\')) {
        $workingString += $key + '\'
        if(!(test-path $workingString)) {
            write-host "creating $workingString"
            new-item -path $workingSTring
        }
    }
 
    $testEntryExists = GetRegistryValue -registryKeyPath $registryKeyPath -registryEntryName $registryEntryName
 
    if($testEntryExists -and $overwriteExisting) {
        Remove-ItemProperty -Path $registryKeyPath -Name $registryEntryName
        New-ItemProperty -Path $registryKeyPath -Name $registryEntryName -PropertyType $registryentrytype -Value $registryEntryValue
    }
    elseif(!$testEntryExists) {
        New-ItemProperty -Path $registryKeyPath -Name $registryEntryName -PropertyType $registryentrytype -Value $registryEntryValue
    }
    else {
        write-host "Value exists for $registryKeyPath Entry $registryEntryName and the script was configured not to overwrite the existing value.  Function exiting as successful"
    }
}
    
$fullRegistryPath = 'hklm:\SOFTWARE\RightScale\yourNameHere' #registry root for custom install info
$registryEntryName = "installValueName" #registry key to create for this installation - must be unique
 
try
{    
    if (GetRegistryValue -registryKeyPath $fullRegistryPath -registryEntryName $registryEntryName)    
    {       
    #CUSTOM CODE START
 
    #CUSTOM CODE END
        
    SetRegistryValue -registryKeyPath $fullRegistryPath -registryEntryName $registryEntryName -registryEntryValue "Installed" -registryEntryType "String" -overwriteExisting $true
      
    #CUSTOM REGISTRY KEYS START
 
    #CUSTOM REGISTRY KEYS END
    }
    else 
    {
        Write-Host "$instalIDVar was installed at $installFlag.  This process will exit without performing any action and without error."
        exit 0
    }
}
catch 
{
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.StackTrace
    exit 1
}   
