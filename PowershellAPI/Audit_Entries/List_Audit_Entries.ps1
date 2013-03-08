#get cookie container from authentication $cookieContainer

$limit = "250"
$start_date = "2013/02/01 00:00:00 %2B0000"
$end_date = "2013/02/21 00:00:00 %2B0000"

$auditEntryRequest = [System.Net.WebRequest]::Create("https://my.rightscale.com/api/audit_entries?limit=$limit&start_date=$start_date&end_date=$end_date")
$auditEntryRequest.Method = "GET"
$auditEntryRequest.CookieContainer = $cookieContainer
$auditEntryRequest.Headers.Add("X_API_VERSION", "1.5");

[System.Net.WebResponse] $auditEntryResponse = $auditEntryRequest.GetResponse()
$auditEntryResponseStream = $auditEntryResponse.GetResponseStream()
$auditEntryResponseStreamReader = New-Object System.IO.StreamReader -argumentList $auditEntryResponseStream
[string]$auditEntryResponseString = $auditEntryResponseStreamReader.ReadToEnd()
write-host $auditEntryResponseString
