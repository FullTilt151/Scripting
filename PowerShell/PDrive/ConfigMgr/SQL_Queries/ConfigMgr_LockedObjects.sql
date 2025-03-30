select *
from sedo_lockstate
where LockStateID != '0'

/*
update sedo_lockstate set LockStateID=0
where LockStateID != '0'
*/