Get-ChildItem C:\Users | 
ForEach-Object { 
$Path = $($_.FullName) + '\AppData\LocalLow\Sun\Java\Deployment\cache'; 
    if (Test-Path $Path -PathType Container) {
        'Removing ' + $Path;
        Remove-Item -Path $path -Force -Recurse;
    }
}