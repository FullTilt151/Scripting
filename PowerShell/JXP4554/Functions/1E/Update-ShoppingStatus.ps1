[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
PARAM(
    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Computer(s) to update',
        ValueFromPipeLine = $true
    )]
    [String[]]$ComputerName
)

$ShoppingConnectionString = Get-CMNConnectionString -DatabaseServer 'LOUSQLWPS601' -Database 'Shopping2'

Foreach ($Computer in $ComputerName) {
    $PendingPackages = 0
    $Query = "Declare @OrderType table(`
	        OrderType CHAR(1) NOT NULL,`
	        TypeDesc CHAR(9) NOT NULL);`
        insert @OrderType (OrderType, TypeDesc)`
        values ('U', 'Uninstall')`
        insert @OrderType (OrderType, TypeDesc)`
        values ('I', 'Install')`
        `
        select	MAC.MachineName [WKID], `
        		COD.MachineId,
		        COD.PackageName [Package], `
		        OT.TypeDesc [Order type],`
		        CASE COD.DeliveryStatus`
		        WHEN 0 then 'Pending Deployment'`
		        WHEN 1 then RTRIM(OT.TypeDesc) + 'ed'`
		        WHEN 2 then 'Failed'`
		        WHEN 3 then 'Pending ' + OT.TypeDesc`
		        END as [Status],`
		        COD.DeliveryStatus`
        from tb_CompletedOrder COD`
        join tb_Machine MAC on COD.MachineId = MAC.MachineId`
        join @OrderType OT on COD.OrderType = OT.OrderType`
        where MAC.MachineName = '$Computer'`
        order by COD.DeliveryStatus"
    $OrderStatuses = Get-CMNDatabaseData -connectionString $ShoppingConnectionString -query $Query -isSQLServer
    if ($OrderStatuses.Count -eq 0) {
        Write-Output "Appears there are no orders for $Computer, so I'm calling this one done!"
    }
    else {
        #Show Completed/Failed order
        foreach ($OrderStatus in $OrderStatuses) {
            if ($OrderStatus.DeliveryStatus -in (0, 3)) {
                Write-Output "$($OrderStatus.WKID) $($OrderStatus.Status) $($OrderStatus.Package) <-- will be set to Fail ***"
                $PendingPackages++
            }
           
        }
        if ($PendingPackages -eq 0) {
            Write-Output "$($OrderStatus.WKID) has no pending deployments, so I'm calling this one done!"
        }
        Else {
            $Result = Read-Host 'You must type "Yes" to proceed'
            if ($Result.ToLower() -eq 'yes') {
                $Query = "Update tb_CompletedOrder`
                    Set DeliveryStatus = 2`
                    where MachineId = '$($OrderStatus.MachineID)' and DeliveryStatus in (0,3)"
                Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                Write-Output 'Any pending installs are now failed.'
            }
        }
    }
}