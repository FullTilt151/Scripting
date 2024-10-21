-- List of RBAC perms
select p.ObjectKey, p.ObjectTypeID, ot.ObjectTypeName, p.GrantedOperations, a.AdminID, a.LogonName, a.DisplayName, a.IsGroup
from RBAC_InstancePermissions p inner join 
	 RBAC_Admins a on a.AdminID = p.AdminID inner join
	 RBAC_SecuredObjectTypes OT on p.ObjectTypeID = ot.ObjectTypeID
where p.ObjectTypeID in (1)
order by ObjectTypeID, ObjectKey, p.GrantedOperations

-- Count of RBAC perms
select p.ObjectTypeID, ot.ObjectTypeName, p.GrantedOperations, a.AdminID, a.LogonName, a.DisplayName, a.IsGroup, count(*)
from RBAC_InstancePermissions p inner join 
	 RBAC_Admins a on a.AdminID = p.AdminID inner join
	 RBAC_SecuredObjectTypes OT on p.ObjectTypeID = ot.ObjectTypeID
group by p.ObjectTypeID, ot.ObjectTypeName, p.GrantedOperations, a.AdminID, a.LogonName, a.DisplayName, a.IsGroup
order by p.ObjectTypeID, a.LogonName

-- RBAC for a security scope
select cat.CategoryName, RL.RoleName, adm.LogonName, adm.DisplayName
from RBAC_ExtendedPermissions EP left join
	 RBAC_Categories CAT on EP.ScopeID = CAT.CategoryID left join
	 RBAC_Roles RL on EP.RoleID = RL.RoleID left join
	 RBAC_Admins ADM on EP.AdminID = ADM.AdminID
where ScopeID = 'WP100004'
order by RL.RoleName, adm.LogonName

-- List of RBAC queries
select * from RBAC_ObjectOperations -- lookup - bitflags of operations
select * from RBAC_ObjectOperationDeps -- some soft of lookup? 
select * from RBAC_Admins order by LogonName -- Administrative Users
select * from RBAC_Categories -- Security Scopes
select * from RBAC_Roles -- Security Roles
select * from RBAC_CategoryMemberships where CategoryID = 'WP100004' -- Objects in Security Scopes, category ID is security scope
select * from RBAC_ExtendedPermissions where AdminID = 167773 -- Matches Admin + Role + Scope, or Admin + Role + Collection
select * from RBAC_ExtendedPermissions where ScopeID = 'WP100004'
select * from RBAC_RoleOperations -- bitflag of granted operations to roles, can find "Create Package" permission