# METHOD 1

$username = "user"
$password = "password"
$svc = New-WebServiceProxy -Uri 'http://servicedesk.humana.com/axis/services/USD_R11_WebService?wsdl'
$sid=$svc.login($username, $password)
$userhandle = $svc.getHandleForUserid($sid, $username)
$attr = "" 
$prop = ""
$requestHandle = ""
$requestNumber = ""
$attr = "validation_rule"
$attrVal = ("customer", $userhandle, "category", "pcat:400001",  "description", "PowerShell Test")
$svc.createRequest($sid, "", $attrVal, $prop, "", $attr, [ref]$requestHandle, [ref]$requestNumber)
$requestNumber
$requestHandle
$svc.logout($sid)

# METHOD 2

$xml = @{"
<?xml version = "1.0" ?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	    <soap:Body>
	        <login xmlns="http://www.ca.com/UnicenterServicePlus/ServiceDesk">
	            <username>ServiceDesk</username>
	            <password>Passwordr11</password>
            </login>
        </soap:Body>
    </soap:Envelope>
</xml>
"}


$SoapAction = New-Object "System.Collections.Generic.Dictionary''2[System.String,System.String]"
$SoapAction.Add("SOAPAction", "") 

$SoapAction 

Invoke-WebRequest http://servicedesk.humana.com:2000/axis/services/USD_R11_WebService?wsdl -Method Post -ContentType "text/xml" -Headers $SoapAction -InFile C:\Temp\soap.txt -OutFile c:\Temp\soapRes.txt

<#

<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body>
<loginResponse	xmlns="http://www.ca.com/UnicenterServicePlus/ServiceDesk"><loginReturn
xmlns="">713249330</loginReturn></loginResponse></soapenv:Body></soapenv:Envelope>

#>