select 
prices.*,
principals.amount as principal,
{{ compute_return(
                100000,
                18,
                0,
                0,
                25000,
                0,
                0,
                0,
                400000,
                0,
                0) }} as return
from 
{{ ref('int_prices') }} as prices,
{{ ref('principals')}} as principals
where fx='USDZAR' and hour='2023-05-11 12:00:00' and kraken='UNIUSD'