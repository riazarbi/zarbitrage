import time
import os
import requests
import json
import random
from datetime import datetime
import urllib.parse
import hashlib
import hmac
import base64
import math
import sys

# Read in args
this_file = sys.argv[0]
crypto_user=sys.argv[1]

f = open("/home/jovyan/secrets.json")
secrets = json.load(f)
print(this_file + ":\t" + "Trading for " + crypto_user)
if crypto_user not in secrets['crypto_users'].keys():
    print(this_file + ":\t" + "Crypto user " + crypto_user + " not known. Exiting." )
    exit()
    
# Read Kraken API key and secret stored in environment variables
#crypto_user = 'Riaz.Arbi'
api_url = "https://api.kraken.com"
api_key = secrets['crypto_users'][crypto_user]['kraken']['key']
api_sec = secrets['crypto_users'][crypto_user]['kraken']['secret']

api_url = "https://api.kraken.com"

trade_minimum = 100
# a basis point is 100th of 1%
spread_minimum_basis_points = 1
sleep_interval_minutes = 1
max_trade_value_usd = 2500

value = True

def get_kraken_signature(urlpath, data, secret):

    postdata = urllib.parse.urlencode(data)
    encoded = (str(data['nonce']) + postdata).encode()
    message = urlpath.encode() + hashlib.sha256(encoded).digest()

    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    sigdigest = base64.b64encode(mac.digest())
    return sigdigest.decode()

# Attaches auth headers and returns results of a POST request
def kraken_request(uri_path, data, api_key, api_sec):
    headers = {}
    headers['API-Key'] = api_key
    # get_kraken_signature() as defined in the 'Authentication' section
    headers['API-Sign'] = get_kraken_signature(uri_path, data, api_sec)             
    req = requests.post((api_url + uri_path), headers=headers, data=data)
    return req


gmail_user = secrets['arbidata']['gmail']['username']
gmail_password = secrets['arbidata']['gmail']['password']
client_email = secrets['crypto_users'][crypto_user]['email']['address']
sent_from = gmail_user
to = [client_email]


while(value):
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print(this_file + ":\t" + "Current Time =", current_time)
    
    # Cancel all kraken orders
    print(this_file + ":\t" + "Cancelling any existing orders")
    resp = kraken_request('/0/private/CancelAll', {
        "nonce": str(int(1000*time.time())),
        "trades": True
    }, api_key, api_sec)
    
    # Confirm no orders
    resp = kraken_request('/0/private/OpenOrders', {
        "nonce": str(int(1000*time.time())),
        "trades": True
    }, api_key, api_sec)

    if len((resp.json().get('result').get('open'))) != 0:
        print(this_file + ":\t" + "There are still open orders so trying to cancel orders again")
        continue   

    # Get kraken balances
    resp = kraken_request('/0/private/Balance', {
        "nonce": str(int(1000*time.time()))
    }, api_key, api_sec)

    # Parse USD balance
    usd_balance = float(resp.json().get('result').get('ZUSD'))
    print(this_file + ":\t" + "USD balance is: " + str(usd_balance))

    if usd_balance > trade_minimum:
        print(this_file + ":\t" + "USD balance is above trade minimum of USD " + str(trade_minimum) + ". Computing trade.")
        # Compute bid price
        resp = requests.get('https://api.kraken.com/0/public/Ticker?pair=XBTUSD')
        market_data = (resp.json().get('result')).get('XXBTZUSD')

        market_data['ask'] = market_data.pop('a')
        market_data['bid'] = market_data.pop('b')

        ask = float(market_data['ask'][0])
        bid = float(market_data['bid'][0])
        spread = ask/bid-1
        spread_basis_points = int(spread * 100 * 100)
        # check spread +ve
        # check spread < some threshold
        spread_fail = spread_basis_points > spread_minimum_basis_points or spread_basis_points < 0
        print(this_file + ":\t" + "Spread " +  str(spread_basis_points))
        if spread_fail:
            print(this_file + ":\t" + "Spread is " + str(spread_basis_points) +" basis points. To wide, passing" )
            print(this_file + ":\t" + "Sleeping for " + str(sleep_interval_minutes) + " minutes...")
            time.sleep(sleep_interval_minutes * 60)
            continue
        # compute bid price
        mybid = random.uniform(bid,ask)
        mybid = round(mybid,1)
        print(this_file + ":\t" + "Proposed bid price: " + str(mybid))
        # compute bid amount in USD
        bid_usd = int(min(usd_balance, max_trade_value_usd))
        print(this_file + ":\t" + "Proposed bid amount: USD " + str(bid_usd))

        # Compute bid volume
        bid_volume = bid_usd / mybid 
        print(this_file + ":\t" + "Proposed bid volume: BTC " + str(bid_volume))
        print(this_file + ":\t" + "Submitting bid")
    
        # Submit kraken order
        resp = kraken_request('/0/private/AddOrder', {
            "nonce": str(int(1000*time.time())),
            "ordertype": "limit",
            "type": "buy",
            "volume": bid_volume,
            "pair": "XBTUSD",
            "price": mybid
        }, api_key, api_sec)
        order_response = print(resp.json())
    
    print(this_file + ":\t" + "Sleeping for " + str(sleep_interval_minutes) + " minutes...")
    time.sleep(sleep_interval_minutes * 60)