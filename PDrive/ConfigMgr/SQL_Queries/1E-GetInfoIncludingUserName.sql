select CompletedOrderId, RequestedTimestamp, CompletedTimestamp, state, Packagename, packageid, DeliveryStatus, AdvertId, MessageId, u.UserAccount, u.FullName
from tb_CompletedOrder CO
Join tb_user U on CO.userid = u.userid
Where u.UserId = '32543'


select *
from tb_User
where FullName like '%Dhote%'
