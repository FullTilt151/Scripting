New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\LOUNASWPS08\pDrive"
Get-ChildItem -Path C:\Temp | Measure-Object -Property Length -sum
###########################################################################################################################################

Get-ChildItem -Dir 'P:\Dept907.CIT\OSD\logs' | %{$_.FullName; ((Get-ChildItem -File $_.FullName | Measure-Object -Property Length -sum).Sum) /1MB }

###########################################################################################################
    $var1 = Get-ChildItem -Dir 'P:\Dept907.CIT\OSD\logs' |
    Sort-Object LastWriteTime -Descending |
    Select-Object -first 50 |
    %{$_.FullName; ((Get-ChildItem -File $_.FullName |
    Measure-Object -Property Length -sum).Sum) /1MB
    }


#####################################################################
$RootFolder = 'P:\Dept907.CIT\OSD\logs'

function Get-FormattedSize{
    param(
        [parameter( Mandatory = $true )]
        [int64]$Size
        )

    switch( $Size ){
        { $Size -gt 1GB }{ '{0:N2} GB' -f ( $Size  / 1GB ); break }
        { $Size -gt 1MB }{ '{0:N2} MB' -f ( $Size  / 1MB ); break }
        { $Size -gt 1KB }{ '{0:N2} KB' -f ( $Size  / 1KB ); break }
        default { "$Size B"; break }
        }
    }

$Results = New-Object -TypeName System.Collections.ArrayList

$RootSize = Get-ChildItem -Path $RootFolder -Recurse |
        Where-Object { -not $_.PSIsContainer } |
        Measure-Object -Property Length -Sum |
        Select-Object -ExpandProperty Sum

$null = $Results.Add(( New-Object -TypeName psobject -Property @{
    Path = $RootFolder
    Size = Get-FormattedSize -Size $RootSize
    } ))

$null = $Results.Add( '' )

$Folders = Get-ChildItem -Path $RootFolder |
    Where-Object { $_.PSIsContainer } |
    Select-Object -ExpandProperty FullName

$null = foreach( $Folder in $Folders ){
    $FolderSize = Get-ChildItem -Path $Folder -Recurse |
        Where-Object { -not $_.PSIsContainer } |
        Measure-Object -Property Length -Sum |
        Select-Object -ExpandProperty Sum

    $Results.Add(( New-Object -TypeName psobject -Property @{
    Path = $Folder
    Size = Get-FormattedSize -Size $FolderSize
    } ))

    $Files = Get-ChildItem -Path $Folder | Where-Object { -not $_.PSIsContainer }

    foreach( $File in $Files ){
        $Results.Add(( New-Object -TypeName psobject -Property @{
            Path = $File.Name
            Size = Get-FormattedSize -Size $File.Length
            } ))
        }

    $Results.Add( '' )
    }

$Results |
    Select-Object -Property Path, Size
