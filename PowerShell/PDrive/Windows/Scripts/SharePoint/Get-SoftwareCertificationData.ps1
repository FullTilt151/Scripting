param(
[Parameter(Mandatory=$true)]
$CRID
)

$reportServerURI = "http://ssrs.humana.com:8081//ReportServer//ReportExecution2005.asmx?wsdl"
$RS = New-WebServiceProxy -Class 'RS' -NameSpace 'RS' -Uri $reportServerURI -UseDefaultCredential

# Set up some variables to hold referenced results from Render
$deviceInfo = "<DeviceInfo><NoHeader>True</NoHeader></DeviceInfo>"
$extension = ""
$mimeType = ""
$encoding = ""
$warnings = $null
$streamIDs = $null

$ReportPath = "/14241/SCDD/Certification Request - View"
$Report = $RS.GetType().GetMethod("LoadReport").Invoke($RS, @($reportPath, $null))

# Report parameters are handled by creating an array of ParameterValue objects.
$parameters = @()

$parameters += New-Object RS.ParameterValue
$parameters[0].Name  = "RequestId"
$parameters[0].Value = $CRID

$RS.SetExecutionParameters($parameters, "en-us") | Out-Null

# PDF, XML, CSV, WORD (.doc), EXCEL (.xls), IMAGE (.tif), MHTML (.mhtml).
$RenderOutput = $RS.Render('XML',
    $deviceInfo,
    [ref] $extension,
    [ref] $mimeType,
    [ref] $encoding,
    [ref] $warnings,
    [ref] $streamIDs
)

# Convert array bytes to file and write
$Stream = New-Object System.IO.FileStream("C:\temp\output.xml"), Create, Write
$Stream.Write($RenderOutput, 0, $RenderOutput.Length)
$Stream.Close()

[xml]$output = Get-Content C:\temp\output.xml | ConvertTo-Xml
[xml]$CRdata = $output.Objects.Object.'#text'

# CR Status
$CRData.Report.TablixMain.Status2
$CRData.Report.Tablix_4Column.Textbox66
$CRdata.Report.Tablix_4Column.Textbox28

Remove-Item C:\temp\output.xml -Force