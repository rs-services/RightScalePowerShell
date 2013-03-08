#get cookie container from authentication $cookieContainer

$listCloudsRequest = [System.Net.WebRequest]::Create("https://my.rightscale.com/api/clouds.xml")
$listCloudsRequest.Method = "GET"
$listCloudsRequest.CookieContainer = $cookieContainer
$listCloudsRequest.Headers.Add("X_API_VERSION", "1.5");

[System.Net.WebResponse] $listCloudsResponse = $listCloudsRequest.GetResponse()
$listCloudsResponseStream = $listCloudsResponse.GetResponseStream()
$listCloudsResponseStreamReader = New-Object System.IO.StreamReader -argumentList $listCloudsResponseStream
[string]$listCloudsResponseString = $listCloudsResponseStreamReader.ReadToEnd()
write-host $listCloudsResponseString
