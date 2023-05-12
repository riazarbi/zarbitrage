select 
hour, 
pair, 
median(bid) as luno_bid 
from {{ ref('stg_luno') }} 
group by 
hour, pair