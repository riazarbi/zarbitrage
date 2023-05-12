select 
pair, 
date_trunc('hour', epoch_ms(client_timestamp)) as hour,
ask, 
bid from {{ source('raw', 'yahoo') }}