$testFilePath = "file_or_directory_to_test"
 
try 
{
    if (!(test-path $testFilePath))    
    {
        Write-Host "Run elevated privelages process here"
   
        #CUSTOM CODE START
 
        #CUSTOM CODE END
        #Assumed that the custom code will create the file at $testFilePath via install or config
    
    }
    else 
    {
        Write-Host "This process was previously run at and the test file ($testFilePath) was present indiciating that this process does not need to run.  This process will exit without performing any action and without error."
        exit 0
    }
}
catch 
{
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.StackTrace
    exit 1
}
