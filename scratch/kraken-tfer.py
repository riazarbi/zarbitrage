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
api_url = "https://api.kraken.com"
api_key = secrets['crypto_users'][crypto_user]['kraken']['key']
api_sec = secrets['crypto_users'][crypto_user]['kraken']['secret']
luno_btc_address = secrets['crypto_users'][crypto_user]['kraken']['luno_alias']

minimum_transfer_value = 1000
maximum_residual_dollars = 100
sleep_interval_minutes = 1

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


while(value):
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print(this_file + ":\t" + "Current Time =", current_time)

    # Get kraken balances
    resp = kraken_request('/0/private/Balance', {
        "nonce": str(int(1000*time.time()))
    }, api_key, api_sec)

    # parse BTC balance
    try:
        BTC_balance = float(resp.json().get('result').get('XXBT'))
    except AttributeError:
        BTC_balance = 0
        print(this_file + ":\t" + "XBT wallet balance API call failed.")
    try:
        USD_balance = float(resp.json().get('result').get('ZUSD'))
    except AttributeError:
        print(this_file + ":\t" + "USD wallet balance API call failed.")
        USD_balance = 0
        
    # Get current USD BTC price
    resp = requests.get('https://api.kraken.com/0/public/Ticker?pair=XBTUSD')
    try:
        market_data = (resp.json().get('result')).get('XXBTZUSD')
    except AttributeError:
        print(this_file + ":\t" + "Market price request failed.")
        market_data = None

    if market_data is not None:
        btc_ask = float(market_data['a'][0])
        btc_bid = float(market_data['b'][0])
        btc_mid = (btc_ask + btc_bid) / 2

        BTC_USD_balance = BTC_balance * btc_mid

        print(this_file + ":\t" + "BTC wallet value: USD " + str(round(BTC_USD_balance, 2)))
        print(this_file + ":\t" + "Kraken USD account value: USD " + str(round(USD_balance, 2)))

        # compute withdrawal amount
        amount_to_withdraw = BTC_balance

        if BTC_USD_balance > minimum_transfer_value and USD_balance < maximum_residual_dollars:
            print(this_file + ":\t" + "Minimum thresholds reached. Transferring to luno.")
             # Construct the request and print the result
            resp = kraken_request('/0/private/Withdraw', {
                "nonce": str(int(1000*time.time())),
                "asset": "XBT",
                "key": luno_btc_address,
                "amount": amount_to_withdraw
            }, api_key, api_sec)

        
        else:
            print(this_file + ":\t" + "Minimum thresholds not reached.")
    
    print(this_file + ":\t" + "Sleeping for " + str(sleep_interval_minutes) + " minutes...")
    time.sleep(sleep_interval_minutes * 60)
