[Reflection.Assembly]::LoadWithPartialName("System.Security") | out-null
$sha1 = new-Object System.Security.Cryptography.SHA1Managed

$images = Get-ChildItem E:\Images -Filter "windows_enterprise_10*"

foreach ($iso in $images) {             
    $iso.Name
    $filename = $iso.FullName
     
    $file = [System.IO.File]::Open($filename, "open", "read")
    $sha1.ComputeHash($file) | %{
        write-host -NoNewLine $_.ToString("x2")
    }
    $file.Dispose()

    write-host
}