{% macro compute_return(principal, 
                        fx_rate, 
                        broker_commission,
                        kraken_deposit_fee,
                        kraken_price,
                        kraken_commission,
                        kraken_withdrawal_fee,
                        luno_deposit_fee,
                        luno_price,
                        luno_commission,
                        luno_withdrawal_fee) %}

{% set broker_rate=fx_rate*(1+broker_commission/100) %}

{% set usd_net = principal/broker_rate  %}

{% set kraken_net = (usd_net-kraken_deposit_fee) %}

{% set kraken_rate = (kraken_price * (1-kraken_commission/100)) %}

{% set kraken_coins = (kraken_net / kraken_rate) %}

{% set kraken_sent = kraken_coins-kraken_withdrawal_fee %}

{% set luno_coins = kraken_sent-luno_deposit_fee %}

{% set luno_rate = luno_price*(1-luno_commission/100) %}

{% set luno_zar = luno_rate*luno_coins %}

{% set bank_zar = luno_zar-luno_withdrawal_fee %}

{% set yield = bank_zar / principal - 1 %}

{{ return(yield) }}

{% endmacro %}