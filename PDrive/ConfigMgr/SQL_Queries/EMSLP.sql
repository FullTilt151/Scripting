-- List of users for a username
select *
from Users
where email = 'mcook9@humana.com'

-- List of roles for a username
select *
from UserRoleBPUMapping
where userid = (select userid from Users where loginid = 'mxc4183')

-- Update LoginID for user
/*
update users
set LoginID = 'mxc4183'
where LoginId = 'mcook9'
*/

-- Delete a user
/*
delete
from UserRoleBPUMapping
where userid = (select userid from Users where loginid = 'mxc4183')
*/