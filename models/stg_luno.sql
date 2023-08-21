select
pair,
date_trunc('hour', epoch_ms(client_timestamp)) as hour,
ask,
bid,
last_trade from {{ source('raw', 'luno') }}