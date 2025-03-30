# Adds a new entry into the Active Efficiency locations table
# Params : site		- [String] containing the site name
#	 : subnet	- [string] containing the ipv4subnet in CIDR notation
# Return : $result	- newly created location object of the form
#			  {"Id":"efa19226-266f-4bd0-8a9d-94fa5ac1b773","Site":"HOMER.SIMPSON.Springfield","Subnet":"192.148.226.0/24"}

param(
[string] $site = $null,
[string] $subnet = $null
)

$post = '{"Site":"' + $site + '","Subnet":"' + $subnet + '"}'

$webRequest = [System.Net.WebRequest]::Create($url)
$webRequest.ContentType = "application/json"
$webRequest.Accept = "application/json"
$postStr = [System.Text.Encoding]::UTF8.GetBytes($post)
$webrequest.ContentLength = $postStr.Length
$webRequest.ServicePoint.Expect100Continue = $false

$webRequest.PreAuthenticate = $true
$webRequest.Method = "POST"

$requestStream = $webRequest.GetRequestStream()

try
{
    $requestStream.Write($postStr, 0,$postStr.length)
}
finally
{
    $requestStream.Close()
}

[string] $result;

[System.Net.WebResponse] $response;
try
{
    $response = $webRequest.GetResponse();
    $rs = $response.GetResponseStream();
    [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
    $result = $sr.ReadToEnd();
}
catch [System.Net.WebException]
{
$_.Exception
#throw $_.Exception

}

return $result;

# $url should reflect the actual Active Efficiency server if executing remotely
$url = "http://ActiveEfficiency.humana.com/ActiveEfficiency/Locations"

# sample adding 3 locations using the AddLocation function
# duplicate entires will report an error: (409) conflict
#AddLocation "GRB" "32.32.49.0/24"
#AddLocation "GRB" "32.32.90.0/24"
#AddLocation "GRB" "32.32.91.0/24"