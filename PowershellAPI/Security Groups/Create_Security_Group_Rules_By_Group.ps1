$cloudId=''
$sgId=""             # Set security group to which the rules should apply

$postURL = "https://my.rightscale.com/api/clouds/$cloudId/security_groups/$sgId/security_group_rules"
$stringToPost = "security_group_rule[protocol]=tcp&security_group_rule[protocol_details][start_port]=80&"+
"security_group_rule[protocol_details][end_port]=80&security_group_rule[source_type]=group&"+
"security_group_rule[group_owner]=default&security_group_rule[group_name]=SG Test"
$bytesToPost = [System.Text.Encoding]::UTF8.GetBytes($stringToPost)


$webRequest = [System.Net.WebRequest]::Create($postURL)
$webRequest.Method = "POST"
$webRequest.Headers.Add("X_API_VERSION","1.5")
$webRequest.CookieContainer = $cookieContainer # recieved from authentication.ps1


$requestStream = $webRequest.GetRequestStream()
$requestStream.Write($bytesToPost, 0, $bytesToPost.Length)
$requestStream.Close()

[System.Net.WebResponse]$response = $webRequest.GetResponse()
$responseStream = $response.GetResponseStream()
$responseStreamReader = New-Object System.IO.StreamReader -ArgumentList $responseStream
[string]$responseString = $responseStreamReader.ReadToEnd()

$responseString