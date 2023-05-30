with kunieth as (select * from stg_kraken where pair='UNIETH'),
lunizar as (select * from stg_luno where pair='UNIZAR'),
lethzar as(select * from stg_luno where pair='ETHZAR')
select 
--kunieth.hour, 
--kunieth.pair, 
kunieth.bid, 
lunizar.bid/lethzar.bid, 
kunieth.bid/(lunizar.bid/lethzar.bid)-1,
kunieth.ask, 
lunizar.ask/lethzar.ask , 
kunieth.ask/(lunizar.ask/lethzar.ask)-1, 
--(lunizar.bid/lethzar.bid-lunizar.ask/lethzar.ask)/(lunizar.ask/lethzar.ask),
--(kunieth.bid-kunieth.ask)/kunieth.ask
from kunieth
left join lunizar on
kunieth.hour=lunizar.hour
left join lethzar on
kunieth.hour=lethzar.hour;

