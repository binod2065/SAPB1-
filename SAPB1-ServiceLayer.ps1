

Function PostWebRequest([String] $url, [String] $data , [string]$method,[string] $cookies)
{   

     if ($url -ne "/Login" -and [string]::IsNullOrEmpty($cookies)){
        Write-Host ("No cookies. ")
        return
    } 
    [string]$baseUrl = "https://192.168.0.100:50000/b1s/v2"
    [String]$fullUrl = $baseUrl+$url
        
    [System.Net.HttpWebRequest] $webRequest = [System.Net.WebRequest]::Create($fullUrl)
    $webRequest.ServerCertificateValidationCallback =  {$true}
    #$webRequest.Timeout = $timeout
    $webRequest.Method = $method
    $webRequest.ContentType = "application/Json"
    
    if($url -ne "/Login"){
    $webRequest.Headers.Add("Cookie", $cookies)
    }

    if ($method -ne "GET"){
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($data)
    $webRequest.ContentLength = $buffer.Length;
    $requestStream = $webRequest.GetRequestStream()
    $requestStream.Write($buffer, 0, $buffer.Length)
    $requestStream.Flush()
    $requestStream.Close()

    }
    try{

    [System.Net.HttpWebResponse] $webResponse = $webRequest.GetResponse()
    } 
    catch{
    Write-Host ("Error on $fullUrl Error :$_")
    $error[0].exception.innerexception
     return 
    }

    if($url -ne '/Login'){
    $streamReader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
    $result = $streamReader.ReadToEnd()
    $streamReader.Dispose()
    return $result 
    } 
    else {
    $reHead = $webResponse.Headers["Set-Cookie"]
    return $reHead
    }
 }

$body= '{
    "CompanyDB" : "<CompanyDB>",
    "UserName" : "<User>",
    "Password: "<Password>"
  }'

# Loging to the Service layer With creadentials and Company
$cookies  = PostWebRequest -url "/Login" -data $body -method "POST"


## Start Your logic 


$body = '{
"ItemPrices" :[{"PriceList" :1, "Price" : 400 }]
}'

$slResponse = PostWebRequest -url "/Items('Testing_From_SL1')" -cookies $cookies -method "PATCH" -data $body

#End Logout after finisng the task

PostWebRequest -url "/Logout" -cookies $cookies -method "POST"

Clear-Variable body
Clear-Variable cookies
Clear-Variable slResponse


[System.GC]::Collect()
