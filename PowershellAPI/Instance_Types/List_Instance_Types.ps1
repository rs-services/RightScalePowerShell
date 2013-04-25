#get cookie container from authentication $cookieContainer

$cloudID = "2175"

write-host "cookie $cookieContainer"

$listInstanceTypesRequest = [System.Net.WebRequest]::Create("https://my.rightscale.com/api/clouds/$cloudID/instance_types.xml")
$listInstanceTypesRequest.Method = "GET"
$listInstanceTypesRequest.CookieContainer = $cookieContainer
$listInstanceTypesRequest.Headers.Add("X_API_VERSION", "1.5");

[System.Net.WebResponse] $listInstanceTypesResponse = $listInstanceTypesRequest.GetResponse()
$listInstanceTypesResponseStream = $listInstanceTypesResponse.GetResponseStream()
$listInstanceTypesResponseStreamReader = New-Object System.IO.StreamReader -argumentList $listInstanceTypesResponseStream
[string]$listInstanceTypesResponseString = $listInstanceTypesResponseStreamReader.ReadToEnd()
write-host $listInstanceTypesResponseString

#response same as curl response
