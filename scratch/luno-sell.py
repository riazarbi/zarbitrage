#%pip install luno-python
import subprocess
import sys

from luno_python.client import Client
from luno_python.error import APIError
import os
from datetime import datetime
import json
import time
import random
import math

# Read in args
this_file = sys.argv[0]
crypto_user=sys.argv[1]

f = open("/home/jovyan/secrets.json")
secrets = json.load(f)
print(this_file + ":\t" + "Trading for " + crypto_user)
if crypto_user not in secrets['crypto_users'].keys():
    print(this_file + ":\t" + "Crypto user " + crypto_user + " not known. Exiting." )
    exit()

api_key_id = secrets['crypto_users'][crypto_user]['luno']['api_key_id']
api_key_secret = secrets['crypto_users'][crypto_user]['luno']['api_key_secret']
bitcoin_account_id = secrets['crypto_users'][crypto_user]['luno']['bitcoin_account_id']

c = Client(api_key_id=api_key_id, api_key_secret=api_key_secret)

trade_minimum = 10000
# a basis point is 100th of 1%
spread_minimum_basis_points = 20
sleep_interval_minutes = 1
max_trade_value_zar = 40000

value = True

while(value):
    
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print(this_file + ":\t" + "Current Time =", current_time)
    
    # Get open orders
    print(this_file + ":\t" + "Checking that there are no open orders")
    open_orders = c.list_orders(state="PENDING").get('orders')
    # Skip loop if there is an open order
    if open_orders is not None:
        print(this_file + ":\t" + "There are still open orders.")
        zombie_order = open_orders[0].get('order_id')
        print(this_file + ":\t" + zombie_order)
        print(this_file + ":\t" + "Stopping first order found...")
        c.stop_order(order_id = zombie_order)
    # If there are no open orders
    else:
        print(this_file + ":\t" + 'There are no open orders.')
        # Get luno balances
        luno_balances = c.get_balances().get('balance')
        btc_balance = next((item for item in luno_balances if item["account_id"] == bitcoin_account_id), None)
        btc_confirmed_balance = float(btc_balance.get('balance'))
        print(this_file + ":\t" + "BTC balance is: " + str(btc_confirmed_balance))
        # Compute bid price
        market_data = c.get_ticker(pair='XBTZAR')
        ask = float(market_data.get('ask'))
        bid = float(market_data.get('bid'))
        spread = ask/bid-1
        spread_basis_points = int(spread * 100 * 100)
        # check spread +ve
        # check spread < some threshold
        spread_fail = spread_basis_points > spread_minimum_basis_points or spread_basis_points < 0
        print(this_file + ":\t" + "Spread " +  str(spread_basis_points))
        if spread_fail:
            print(this_file + ":\t" + "Spread is " + str(spread_basis_points) +" basis points. To wide, passing" )

        else:
            # compute bid price
            myask = random.uniform(bid,ask)
            myask = round(myask,0)
            print(this_file + ":\t" + "Proposed ask price: " + str(myask))
            # compute bid amount in ZAR
            btc_zar_val = (btc_confirmed_balance * myask)
            ask_zar = int(min(btc_zar_val, max_trade_value_zar))
            print(this_file + ":\t" + "Proposed ask amount: ZAR " + str(ask_zar))
            if int(ask_zar) == 0:
                print(this_file + ":\t" + "Volume is too low.")
            else:
                # Compute bid volume
                ask_volume = ask_zar / myask 
                ask_volume = round(math.floor(ask_volume * 100000)/100000.0, 5)
                #ask_volume = round(ask_volume,6)
                print(this_file + ":\t" + "Proposed bid volume: BTC " + str(ask_volume))
                print(this_file + ":\t" + "Submitting ask")  
                try:
                    order = c.post_limit_order(pair = 'XBTZAR',
                      price = myask,
                      type = 'ASK',
                      volume = ask_volume,
                      base_account_id = bitcoin_account_id
                      )
                    open_order_id = order.get('order_id')
                #except APIError:
                #    print(this_file + ":\t" + "APIError. Order submission failed.")
                except Exception as e: print(e)
                    
    print(this_file + ":\t" + "Sleeping for " + str(sleep_interval_minutes) + " minutes...")
    time.sleep(sleep_interval_minutes * 60)
