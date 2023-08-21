select *, 
compute_nominal(principal, 
                                                                yahoo_ask, 
                                                                broker_commission,
                                                                kraken_deposit_fee,
                                                                kraken_ask,
                                                                kraken_commission,
                                                                kraken_withdrawal_fee,
                                                                luno_deposit_fee,
                                                                luno_bid,
                                                                luno_commission,
                                                                luno_withdrawal_fee
                                                                ) as nominal
from 
{{ ref('int_union_principals') }}