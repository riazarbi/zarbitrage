with 
kraken as (select * from {{ ref('int_kraken') }}),
luno as (select * from {{ ref('int_luno') }}),
yahoo as (select * from {{ ref('int_yahoo') }}),
map as (select * from {{ ref('trade_loops') }})
select map.*, kraken.hour, yahoo_ask, kraken_ask, luno_bid, from kraken
left join
map on
kraken.pair = map.kraken
left join luno
on
map.luno = luno.pair and kraken.hour = luno.hour
left join yahoo
on
map.fx = yahoo.pair and kraken.hour = yahoo.hour