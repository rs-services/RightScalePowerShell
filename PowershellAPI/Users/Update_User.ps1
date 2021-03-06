$USER=""
$postURL = "https://my.rightscale.com/api/users/$USER"
$stringToPost = "user[email]=gregdoe@example.com&"+
"user[password]=NewPasswordd&"+
"user[company]=RightDoe&"+
"user[phone]=8051234567&"+
"user[first_name]=Greg&"+
"user[last_name]=Doe"
$bytesToPost = [System.Text.Encoding]::UTF8.GetBytes($stringToPost)

$webRequest = [System.Net.WebRequest]::Create($postURL)
$webRequest.Method = "PUT"
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