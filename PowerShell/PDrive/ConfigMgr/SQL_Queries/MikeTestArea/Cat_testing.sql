select *
from sw.ProductEdition
where ProductID = 2736

select *
from [v1.0].v_Products
where title = 'Visual Studio'

select *
from [v1.0].v_ProductEditions
where ProductID = 2736
order by edition

select *
from [v1.0].v_ProductVersions
where ProductID = 2736