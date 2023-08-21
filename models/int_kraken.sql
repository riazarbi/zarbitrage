select 
hour, 
pair, 
median(ask) as kraken_ask 
from {{ ref('stg_kraken') }} 
group by 
hour, pair