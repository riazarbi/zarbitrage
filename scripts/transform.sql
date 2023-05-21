
-- CREATE TABLES
CREATE TABLE kraken AS SELECT * FROM   "/home/maker/data/kraken/*.csv";
CREATE TABLE luno AS SELECT * FROM   "/home/maker/data/luno/*.csv";
CREATE TABLE xe AS SELECT * FROM   "/home/maker/data/xe/*.csv";
CREATE TABLE yahoo AS SELECT * FROM   "/home/maker/data/kraken/*.csv";
CREATE TABLE TRADE_LOOPS AS SELECT * FROM   "/home/maker/seeds/trade_loops.csv";
CREATE TABLE PRINCIPALS AS SELECT * FROM   "/home/maker/seeds/principals.csv";


-- STAGING TABLES
CREATE TABLE STG_KRAKEN AS
select 
pair,
date_trunc('hour', epoch_ms(client_timestamp)) as hour,
ask,
bid,
last
from KRAKEN;

CREATE TABLE STG_LUNO AS
select
pair,
date_trunc('hour', epoch_ms(client_timestamp)) as hour,
ask,
bid,
last_trade from LUNO;

CREATE TABLE STG_YAHOO AS
select 
pair, 
date_trunc('hour', epoch_ms(client_timestamp)) as hour,
ask, 
bid from YAHOO;

-- INTERMEDIATE TABLES

CREATE TABLE INT_KRAKEN AS
select 
hour, 
pair, 
median(ask) as kraken_ask 
from STG_KRAKEN 
group by 
hour, pair;

CREATE TABLE INT_LUNO AS 
select 
hour, 
pair, 
median(bid) as luno_bid 
from STG_LUNO 
group by 
hour, pair;

CREATE TABLE INT_YAHOO AS
select 
hour, 
pair, 
median(ask) as yahoo_ask 
from STG_YAHOO 
group by 
hour, pair;

CREATE TABLE INT_UNION_PRICES AS 
with 
kraken as (select * from INT_KRAKEN),
luno as (select * from INT_LUNO),
yahoo as (select * from INT_YAHOO),
map as (select * from TRADE_LOOPS)
select map.*, kraken.hour, yahoo_ask, kraken_ask, luno_bid, from kraken
left join
map on
kraken.pair = map.kraken
left join luno
on
map.luno = luno.pair and kraken.hour = luno.hour
left join yahoo
on
map.fx = yahoo.pair and kraken.hour = yahoo.hour;


CREATE TABLE INT_UNION_PRINCIPALS AS 
select * from (select 
prices.*,
principals.amount as principal,
case when principals.amount < 100001 then 550 else 450 end as swift_fee,
from
INT_UNION_PRICES as prices,
PRINCIPALS as principals) where kraken is not null and luno is not null and fx is not null;

CREATE TABLE INT_NOMINAL AS 
select *, 
((
    ((principal/yahoo_ask*(1+broker_commission)-kraken_deposit_fee)/
        (kraken_ask*(1-kraken_commission)) 
    ) - kraken_withdrawal_fee - luno_deposit_fee
)
*
(
    luno_bid*(1-luno_commission)
) 
-
luno_withdrawal_fee
)
as nominal,
from 
INT_UNION_PRINCIPALS;

CREATE TABLE RETURNS AS 
select 
    hour, 
    kraken, 
    principal, 
    nominal, 
    nominal/principal-1 as return 
from INT_NOMINAL;
