#https://trevorsullivan.net/2012/07/24/powershell-embed-binary-data-in-your-script/
#http://www.powershellmagazine.com/2017/05/22/working-with-binary-files-in-powershell/
function Convert-BinaryToString
{
	[CmdletBinding()]
	param
	(
		[string] $FilePath
	)

	try
	{
		$ByteArray = [System.IO.File]::ReadAllBytes($FilePath);
	}
	catch
	{
		throw "Failed to read file. Please ensure that you have permission to the file, and that the file path is correct.";
	}

	if ($ByteArray)
	{
		$Base64String = [System.Convert]::ToBase64String($ByteArray);
	}
	else
	{
		throw "$ByteArray is $null.";
	}

	Return $Base64String;
}

$Output = Convert-BinaryToString -FilePath E:\Entrust-Prod-CS.cer
$Output | Out-File -FilePath E:\Entrust-Prod-CS.txt