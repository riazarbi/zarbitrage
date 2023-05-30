{% macro compute_nominal() %}

CREATE OR REPLACE FUNCTION {{ target.schema }}.compute_nominal(principal, 
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
                                                                )

AS (

 (
    (
        (
            (principal/(yahoo_ask*(1+broker_commission)) - kraken_deposit_fee) / 
            (kraken_ask*(1+kraken_commission))
        ) 
        - 
        kraken_withdrawal_fee 
        - 
        luno_deposit_fee
)
*
(
    luno_bid/(1+luno_commission)
) 
-
luno_withdrawal_fee
)


);

{% endmacro %}