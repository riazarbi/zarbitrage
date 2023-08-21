select 
hour, 
pair, 
median(ask) as yahoo_ask 
from {{ ref('stg_yahoo') }} 
group by 
hour, pair