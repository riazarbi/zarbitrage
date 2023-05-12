# ZARBITRAGE

Monitoring the South African cryptocurrency premium since 2023!

Check out the end result here https://riazarbi.github.io/zarbitrage/

## What is this all about?

An arbitrage opportunity is a term that refers to the possibility to buy and sell the same thing simultaneously in two markets to make a profit. 

Consider two apple markets across the street from one another. The price of apples in market A is $1. The price in market B is $2. An astute profiteer (who owns no apples) could go to market B, and offer to sell 1000 apples at $2 each to a willing buyer. When they find a buyer, they can walk to market A, and buy 1000 apples for $1 each, carry them over to market B, collect their $2000, walk back to market A, pay the $1000, and walk away from the whole affair with $1000 in their pocket.

Arbitrage opportunities are very rare, and as soon as they are discovered they typically disappear (all the traders in apple market A walk over to market B) Cryptocurrency pricing markets are typically very efficient, with very small price discrepancies being traded out by arbitragers very quickly. 

_However_ South African cryptocurrency prices tend to be persistently higher than global markets. Persistent arbitrage opportunities can only exist if there is agood econokic reason for them. In this case, the premium exists because of an artificial cap on the flow of capital out of South Africa. Individuals in SOuth Africa are limited to ZAR1m in capital withdrawals each calendar year. To take out more requires special approval from the reserve bank. This means that outflows are constrained. Cryptocurrency flows cannot be constrained, because there is no mechanism by which a wallet trandsfer can be stopped by the reserve bank. 

The end result is that demand for cryptocurrency in South Africa is slightly inflated, possibly because it is a channel for illicit outflows of capital from the country. 

## What does this repo do?

This repo computes the SOuth African cryptocurrency premium for a range of tradeable currency pairs and renders that premium in pretty charts.

## But can't I just do this myself?

Of course! Google is your friend. Two reasons why you might end up using this though.

1. Premiums are volatile. They change by the hour, so every time you want to know the premium you'll have to eat a few minutes out of your day looking up all the values and computing them 
2. Just because the reference prices suggest an arbitrage does not mean that an arbitrage opportunity exists. Have you taken into account transaction fees? Deposit fees? Withdrawal fees? Broker spreads? SWIFT fees? This repo tries to take all of that into account. 

## Ok so how do I check the premium?

If you are a human, check out the github pages website for this repo at https://riazarbi.github,.io/zarbitrage

If you are a robot, you have two options - 

1. Clone the repo and connect to the `duckdb` database with your favourite client.
2. Hit up ____ to get the raw instance premium for a range of currencies.

## This is so cool can I {contribute,use this to make money,clone this and hoard it}

You can do whatever you want with it. I might not respond to you, because, well, I don't have to. If you want to actually use this to make decisions _about the real world_ then you are on your own. **You have to verify the coerrectness of this code yourself**. I take NO responsibility for the accuracy of anything.