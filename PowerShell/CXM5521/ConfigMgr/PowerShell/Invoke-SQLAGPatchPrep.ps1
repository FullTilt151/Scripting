param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Drain', 'Resume')]
    [string]$Purpose = 'Resume'
)

$ErrorActionPreference = 'Stop'

$AvailabilityGroups = Get-DbaAvailabilityGroup -SqlInstance $env:COMPUTERNAME

foreach ($AG in $AvailabilityGroups) {
    $DatabaseName = $AG.AvailabilityDatabases.Name
    $AGName = $AG.AvailabilityGroup
    $AGListener = $AG.AvailabilityGroupListeners.Name
    $PrimaryNode = $AG.PrimaryReplica

    $CheckAG = @"
		SELECT name AS [AGname]
			, replica_server_name AS [ServerName]
			, CASE
				WHEN replica_server_name=ag.primary_replica THEN 'PRIMARY'
				ELSE 'SECONDARY'
			END AS [Status]
			, synchronization_health_desc AS [SynchronizationHealth]
			, failover_mode_desc AS [FailoverMode]
			, availability_mode AS [Synchronous]
			, secondary_role_allow_connections_desc [ReadableSecondary]
		FROM sys.availability_replicas r
			INNER JOIN sys.availability_groups g ON r.group_id = g.group_id
			LEFT JOIN master.sys.dm_hadr_availability_group_states ag ON r.group_id = ag.group_id
"@


    switch ($Purpose) {
        'Drain' {
            try {
                $StartStateAG = Invoke-DbaQuery -SqlInstance $AGListener -Query $CheckAG -EnableException
                $SecondaryNode = $StartStateAG | Where-Object { $_.Status -eq 'SECONDARY' } | Select-Object -ExpandProperty ServerName
            }
            catch {
                Write-Error 'Failed to query for Availability Group status'
                exit 1
            }

            switch ($StartStateAG.SynchronizationHealth) {
                'HEALTHY' {
                    continue;
                }
                default {
                    Write-Error 'At least one node has unhealthy SynchronizationHealth'
                    exit 1
                }
            }
        
            switch ($StartStateAG) {
                { $_.FailoverMode -ne 'MANUAL' } {
                    try {
                        Set-DbaAgReplica -SqlInstance $PrimaryNode -AvailabilityGroup $_.AGname -Replica $_.ServerName -FailoverMode Manual -EnableException
                    }
                    catch {
                        Write-Error "Failed to set [FailoverMode = 'MANUAL'] for [AG = '$($_.AGName)'] against [Replica = '$($_.ServerName)']"
                        exit 1
                    }
                }
            }

            switch ($PrimaryNode -eq $env:COMPUTERNAME) {
                $true {
                    try {
                        Invoke-DbaAgFailover -SqlInstance $SecondaryNode -AvailabilityGroup $AGName -Force -EnableException
                    }
                    catch {
                        Write-Error "Failed to perform failover for [AG = '$AGName'] against [SqlInstance = '$SecondaryNode']"
                        exit 1
                    }
                }
            }
            try {
                Suspend-DbaAgDbDataMovement -SqlInstance $env:COMPUTERNAME -AvailabilityGroup $AGName -Database $DatabaseName -Confirm:$false -EnableException
            }
            catch {
                Write-Error "Failed to set suspend DbDataMovement for [AG = '$AGName'] [Database = '$DatabaseName']"
                exit 1
            }

            $ClusterStatus = Get-ClusterNode -Name $env:COMPUTERNAME
            switch ($ClusterStatus.State) {
                'Up' {
                    try {
                        Suspend-ClusterNode -Wait -Drain
                    }
                    catch {
                        Write-Error "Failed to set suspend ClusterNode"
                        exit 1
                    }
                }
            }
        }
        'Resume' {
            $PrimaryNode = $AG.PrimaryReplica
            $ClusterStatus = Get-ClusterNode -Name $env:COMPUTERNAME
            switch ($ClusterStatus.State) {
                'Up' {
                    continue
                }
                default {
                    try {
                        Resume-ClusterNode -Name $env:COMPUTERNAME
                    }
                    catch {
                        Write-Error "Failed to set resume ClusterNode"
                        exit 1
                    }
                }
            }
            foreach ($Node in $AG.AvailabilityReplicas.Name) {
                try {
                    Set-DbaAgReplica -SqlInstance $PrimaryNode -AvailabilityGroup $AG.AvailabilityGroup -Replica $Node -FailoverMode Automatic -EnableException
                }
                catch {
                    Write-Error "Failed to set [FailoverMode = 'AUTOMATIC'] for [AG = '$($_.AGName)'] against [Replica = '$($_.ServerName)']"
                    exit 1
                }
            }
            try {
                Resume-DbaAgDbDataMovement -SqlInstance $env:COMPUTERNAME -AvailabilityGroup $AG.AvailabilityGroup -Database $AG.AvailabilityDatabases.Name -Confirm:$false -EnableException
            }
            catch {
                Write-Error "Failed to set resume DbDataMovement for [AG = '$AGName'] [Database = '$DatabaseName']"
                exit 1
            }
        }
    }
}