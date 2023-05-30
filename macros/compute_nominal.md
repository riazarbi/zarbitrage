{% docs compute_nominal %}
A macro to create an UDF to compute the estimated return from an arbitrage loop.

While this _dbt macro_ does not have any arguments, the _sql udf_ that it creates takes the following arguments:

`principal` - The amount invested, in ZAR  
`yahoo_ask` - The amount of ZAR you need to spend to buy one USD  
`broker_commission` - The commission charged by your forex broker  
`kraken_deposit_fee` - The fee, in USD, that Kraken charges you to receive your USD  
`kraken_ask` - the amount of USD you must pay to get 1 crypto token  
`kraken_commission` - the commission Kraken charges you to trade  
`kraken_withdrawal_fee` - the amount Kraken charges you, in crypto tokens  
`luno_deposit_fee` - the amount, in crypto tokens, that Luno charges you to receive tokens  
`luno_bid` - the amount you will receive, in ZAR, for selling 1 crypto token  
`luno_commission` - the commission Luno charges you to trade  
`luno_withdrawal_fee` - the amount, in ZAR, that Luno charges you to withdraw ZAR  

Example usage:

```sql
SELECT
compute_nominal(100000, 
                10, 
                0.005,
                15,
                20000,
                0.0001,
                0,
                0,
                200000,
                0.00001,
                0
                );
```


*See the seed `trade_loops` for the actual values that might be used in this macro.*

{% enddocs %}