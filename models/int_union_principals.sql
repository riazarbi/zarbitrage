select * from (select 
prices.*,
principals.amount as principal,
case when principals.amount < 100001 then 550 else 450 end as swift_fee,
from
{{ ref('int_union_prices') }} as prices,
{{ ref('principals')}} as principals) where kraken is not null and luno is not null and fx is not null
