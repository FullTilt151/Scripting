Function Get-DatabaseData
{
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$query   
    )

    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = 'Data Source=LOUSQLWPS401;Initial Catalog=CM_CAS;Integrated Security=SSPI'
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    $dataset = New-Object -TypeName System.Data.DataSet
    try
    {
        $adapter.Fill($dataset)  | Out-Null
    }

    catch
    {
        exit 10000
    }
    $connection.close()
    return $dataset.Tables[0]
}

$query = "Select * From vReplicationData where Status = 4"
$results = Get-DatabaseData $query
foreach($result in $results.ReplicationGroup)
{
    $fileName = "$result-ldc.pub"
    New-Item -Path '\\louappwps875\SMS_CAS\inboxes\rcm.box' -Name $fileName -ItemType File
}