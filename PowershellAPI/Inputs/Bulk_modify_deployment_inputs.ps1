$deploymentID = "deploymentID"   # ID of the deployment to be modified

$stringToPut =  "inputs[][name]=APPLICATION_LISTENER_PORT&"
$stringToPut += "inputs[][value]=text:80&"
$stringToPut += "inputs[][name]=ZIP_FILE_NAME&"
$stringToPut += "inputs[][value]=text:thisisazipfile.zip&"
$stringToPut += "inputs[][name]=OPT_APP_POOL_NAME&"
$stringToPut += "inputs[][value]=text:ASP.NET v4.0"

$inputWebRequest = [System.Net.WebRequest]::Create("https://my.rightscale.com/api/deployments/$deploymentID/inputs/multi_update?$stringToPut")
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