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
{{ ref('int_union_principals') }}