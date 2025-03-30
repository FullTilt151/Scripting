$wsusServers = @{
    'MT1' = 'LOUAPPWTS1150.rsc.humad.com';
    'WQ1' = 'LOUAPPWQS1023.rsc.humad.com';
    'WP1' = 'LOUAPPWPS1642.rsc.humad.com';
    'SQ1' = 'LOUAPPWQS1020.rsc.humad.com';
    'SP1' = 'LOUAPPWPS1740.rsc.humad.com';
}
            
$bulletins = ('08-052', '09-062', '11-025', '12-039', '12-059', '12-060', '12-066', '13-009', '13-023', '13-041', '13-044', '13-054', '13-085', '13-094', '13-097', '13-104', '13-106', '14-001', '14-010', '14-012', '14-018', '14-021', '14-023', '14-025', '14-025', '14-036', '14-037', '14-051', '14-052', '14-053', '14-056', '14-065', '14-072', '14-080', '14-081', '14-083', '15-004', '15-009', '15-011', '15-011', '15-013', '15-022', '15-028', '15-032', '15-034', '15-044', '15-045', '15-046', '15-048', '15-056', '15-065', '15-079', '15-093', '15-094', '15-098', '15-106', '15-112', '15-124', '15-128', '16-001', '16-039', '16-051', '16-087', '16-095', '16-118', '16-120', '16-132', '16-139', '16-142', '16-144', '16-146', '17-006')
$articles = ('2264072', '2264107', '2750841', '2871997', '2960358', '2963983', '3033929', '4015549', '4019263', '4019264', '4021558')
            
foreach ($wsusServer in $wsusServers.GetEnumerator()) {
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
    $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer(($wsusServer.Value), $false, 8530);
    $allGroups = $wsus.GetComputerTargetGroups()
    $approval = [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::NotApproved
    Write-Output "Checking $($wsusServer.Name)"
    foreach ($bulletin in $bulletins) {
        $updates = $wsus.SearchUpdates($bulletin)
        foreach ($update in $updates) {
            if ($update.IsDeclined) {
                $color = 'Red'
                foreach ($group in $allGroups) {
                    $update.Approve($approval, $allGroups[0])
                }
            }
            else {$color = 'Green'}
            Write-Host -ForegroundColor $color "$($update.SecurityBulletins[0]) $($update.KnowledgebaseArticles[0]) - $($update.Title)"
        }
    }
    foreach ($article in $articles) {
        $updates = $wsus.SearchUpdates($article)
        foreach ($update in $updates) {
            if ($update.IsDeclined) {
                $color = 'Red'
                $update.Approve($approval, $allGroups[0])
            }
            else {$color = 'Green'}
            Write-Host -ForegroundColor $color "$($update.SecurityBulletins[0]) $($update.KnowledgebaseArticles[0]) - $($update.Title)"
        }
    }
}
            