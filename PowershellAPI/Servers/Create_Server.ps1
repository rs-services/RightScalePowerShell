$DEPLOYMENT=""  # Deployment to add Server to
$CLOUD=""            # Specify Cloud to add Server to
$ST=""          # Set the ServerTemplate the Server will be based on
$SG=""      # Set the Security Group
$MCI=""         # Set MultiCloud Image (MCI)
$ITYPE=""   # Set the Instance Type for this Sever, this cloud, ...

$postURL = "https://my.rightscale.com/api/servers"
$stringToPost = "server[name]=my_app_server&"+
"server[description]=my_app_server_description&"+
"server[deployment_href]=/api/deployments/$DEPLOYMENT&"+
"server[instance][cloud_href]=/api/clouds/$CLOUD&"+
"server[instance][server_template_href]=/api/server_templates/$ST&"+
"server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI&"+
"server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE&"+
"server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG"
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