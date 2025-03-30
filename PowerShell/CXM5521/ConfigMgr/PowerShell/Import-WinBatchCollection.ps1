function Import-WinBatchCollection {
    <#
    .SYNOPSIS
        Function to process a spreadsheet into Query based collections
    .DESCRIPTION
        This function is used to take a CSV file and turn it into a set of query based collections.
        The HEADER field should be the collection name, and all the rows below the header should be the members of the respective collection
    .PARAMETER WinBatchCSV
        Path(s) to the CSV File(s) that you would like to process. Headers are Collection Names
    .EXAMPLE
        PS C:\> Import-WinBatchCollection -WinBatchCSV 'c:\temp\WinBatch1.csv'
        Will create / update all collections specified in the WinBatch1.csv file
    .INPUTS
        CSV file
    .OUTPUTS
        None
    .NOTES
        If the collection names (headers) don't exist they will be created
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory = $true)]
        [string[]]$WinBatchCSV
    )

    #region functions
    function Get-SQLArray {
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$StringArray
        )
        [string]::Format("('{0}')", [string]::Join("','", $StringArray))
    }
    #endregion functions

    $NetBiosNameQuery = "SELECT SMS_R_SYSTEM.ResourceID, SMS_R_SYSTEM.ResourceType, SMS_R_SYSTEM.Name, SMS_R_SYSTEM.SMSUniqueIdentifier, SMS_R_SYSTEM.ResourceDomainORWorkgroup, SMS_R_SYSTEM.Client FROM SMS_R_System WHERE SMS_R_System.NetbiosName IN"

    foreach ($CSV in $WinBatchCSV) {
        try {
            $WinBatch = Import-Csv -Path $CSV -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to import $CSV"
        }
        $Collections = $WinBatch | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

        $WinbatchImport = foreach ($Collection in $Collections) {
            $Members = $WinBatch.$Collection | Where-Object { $_ }
            $MemberSQLArray = Get-SQLArray -StringArray $Members
            $ColQuery = [string]::Format('{0} {1}', $NetBiosNameQuery, $MemberSQLArray)
            [pscustomobject]@{
                CollectionName = $Collection
                Query          = $ColQuery
            }
        }

        foreach ($One in $WinbatchImport) {
            if ($PSCmdlet.ShouldProcess("[Collection = '$($One.CollectionName)'] processing", "Import-WinBatchCollection")) {
                $CollectionName = $One.CollectionName
                if (-not ($Collection = Get-CMDeviceCollection -Name $One.CollectionName)) {
                    Write-Warning "[Collection = $CollectionName] not found and will be created"
                    $Today = Get-Date -Format 'yyyy-MM-dd'
                    $RefreshSchedule = New-CMSchedule -RecurInterval Days -RecurCount 1 -Start (Get-Date -Date $([string]::Format("{0} 09:00:00Z", $Today)))
                    $newCMDeviceCollectionSplat = @{
                        RefreshType            = 'Periodic'
                        LimitingCollectionName = 'All Systems'
                        Name                   = $One.CollectionName
                        RefreshSchedule        = $RefreshSchedule
                    }
                    $Created = New-CMDeviceCollection @newCMDeviceCollectionSplat
                    Add-CMDeviceCollectionQueryMembershipRule -Collection $Created -RuleName 'WinBatch' -QueryExpression $One.Query
                }
                else {
                    Write-Output "[Collection = $CollectionName] found - will remove all existing rules"
                    $DirectRules = Get-CMDeviceCollectionDirectMembershipRule -InputObject $Collection
                    if ($null -ne $DirectRules) {
                        Write-Output "[Collection = $CollectionName] - Removing Direct Rules"
                        $RuleCount = $DirectRules | Measure-Object | Select-Object -ExpandProperty Count
                        $Progress = 0
                        foreach ($Rule in $DirectRules) {
                            Write-Progress -Activity "Removing Direct Membership Rules from $($One.CollectionName)" -Status "Removing $($Rule.Name) - ($Progress / $RuleCount)" -PercentComplete (($Progress++ / $RuleCount) * 100)
                            Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $Collection.Name -ResourceId $Rule.Resourceid -Force -Confirm:$false
                        }
                        Write-Progress -Activity "Removing Direct Membership Rules from $($One.CollectionName)" -Completed
                    }
                    $QueryRules = Get-CMDeviceCollectionQueryMembershipRule -InputObject $Collection
                    if ($null -ne $QueryRules) {
                        Write-Output "[Collection = $CollectionName] - Removing Query Rules"
                        $RuleCount = $QueryRules | Measure-Object | Select-Object -ExpandProperty Count
                        $Progress = 0
                        foreach ($Rule in $QueryRules) {
                            Write-Progress -Activity "Removing Query Membership Rules from $($One.CollectionName)" -Status "Removing $($Rule.Name) - ($Progress / $RuleCount)" -PercentComplete (($Progress++ / $RuleCount) * 100)
                            Remove-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection.Name -RuleName $Rule.RuleName -Force -Confirm:$false
                        }
                        Write-Progress -Activity "Removing Direct Query Rules from $($One.CollectionName)" -Completed
                    }
                    Write-Output "[Collection = $CollectionName] - Adding new query rule"
                    Add-CMDeviceCollectionQueryMembershipRule -Collection $Collection -RuleName 'WinBatch' -QueryExpression $One.Query
                }
            }
        }
    }
}