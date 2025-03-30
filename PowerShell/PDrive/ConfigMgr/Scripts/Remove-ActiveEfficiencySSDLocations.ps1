# Deletes all rows from the Active Efficiency locations table
# Params : none
# Return : $result(empty)

function DeleteAllLocations()
{
    $webRequest = [System.Net.WebRequest]::Create($url)
    $webRequest.ContentType = "application/json"
    $webRequest.Accept = "application/json"
    $webrequest.ContentLength = $postStr.Length
    $webRequest.ServicePoint.Expect100Continue = $false

    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "DELETE"

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
#        throw $_.Exception

    }

    return $result;

}

# optional will delete all existing entries 
#DeleteAllLocations