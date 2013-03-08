$cloudID = "cloudid"   # ID of the deployment to be modified
$instanceID = "nextinstanceid" # ID of the next instance whose next inputs are being
$port = "8080"

$stringToPut = "inputs[][name]=sys_firewall/rule/port&"
$stringToPut += "inputs[][value]=text:$port"

$inputWebRequest = [System.Net.WebRequest]::Create("https://my.rightscale.com/api/clouds/$cloudID/instances/$instanceID/inputs/multi_update")
$inputWebRequest.Method = "PUT"
$inputWebRequest.Headers.Add("X_API_VERSION","1.5")
$inputWebRequest.CookieContainer = $cookieContainer
$inputWebRequest.ServicePoint.Expect100Continue = $false
$inputRequestStream = $inputWebRequest.GetRequestStream()
$inputRequestStream.Close()

[System.Net.WebResponse]$inputResponse = $inputWebRequest.GetResponse()
$inputResponseStream = $inputResponse.GetResponseStream()
$inputResponseStreamReader = New-Object System.IO.StreamReader -ArgumentList $inputResponseStream

$inputResponse

#this is the cookie container for subsequent requests: $cookieContainer