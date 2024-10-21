select v.Name0, sw.FileName, sw.FileDescription, sw.FileVersion, sw.FilePath
from v_R_System v
inner join v_GS_SoftwareFile sw
on sw.ResourceID = v.ResourceID
where v.ResourceID in
(select ResourceID from v_FullCollectionMembership where CollectionID = 'CAS00F14')
order by v.Name0