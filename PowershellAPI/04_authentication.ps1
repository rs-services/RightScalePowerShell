$email = ""    # The Email Address for your RightScale User in the Dashboard
$passwd = ""   # Your User's password
$account = ""  # Account ID, Easily Obtained from navigation in the Dashboard

$postURL = "https://my.rightscale.com/api/session"
$stringToPost = "email=$email&password=$passwd&account_href=/api/accounts/$account"
$bytesToPost = [System.Text.Encoding]::UTF8.GetBytes($stringToPost)
$cookieContainer = New-object System.Net.CookieContainer

$webRequest = [System.Net.WebRequest]::Create($postURL)
$webRequest.Method = "POST"
$webRequest.ContentType = "application/x-www-form-urlencoded"
$webRequest.Headers.Add("X_API_VERSION","1.5")
$webRequest.ContentLength = $bytesToPost.Length
$webRequest.PreAuthenticate = $false;
$webRequest.ServicePoint.Expect100Continue = $false
$webRequest.CookieContainer = $cookieContainer

$requestStream = $webRequest.GetRequestStream()
$requestStream.Write($bytesToPost, 0, $bytesToPost.Length)
$requestStream.Close()

[System.Net.WebResponse]$response = $webRequest.GetResponse()
$responseStream = $response.GetResponseStream()
$responseStreamReader = New-Object System.IO.StreamReader -ArgumentList $responseStream
[string]$responseString = $responseStreamReader.ReadToEnd()

#this is the cookie container for subsequent requests: $cookieContainer