#%pip install luno-python
import subprocess
import sys

from luno_python.client import Client
import os
from datetime import datetime
import json
import time
import random

# Read in args
this_file = sys.argv[0]
crypto_user=sys.argv[1]
this_file = "tmp"
crypto_user = "Riaz.Arbi"

f = open("/home/jovyan/secrets.json")
secrets = json.load(f)
print(this_file + ":\t" + "Trading for " + crypto_user)
if crypto_user not in secrets['crypto_users'].keys():
    print(this_file + ":\t" + "Crypto user " + crypto_user + " not known. Exiting." )
    exit()

api_key_id = secrets['crypto_users'][crypto_user]['luno']['api_key_id']
api_key_secret = secrets['crypto_users'][crypto_user]['luno']['api_key_secret']
bitcoin_account_id = secrets['crypto_users'][crypto_user]['luno']['bitcoin_account_id']
investec_account_id = secrets['crypto_users'][crypto_user]['luno']['investec_account_id']

c = Client(api_key_id=api_key_id, api_key_secret=api_key_secret)

withdrawal_amount = 100000

c.list_beneficiaries_response()
c.create_withdrawal(amount = withdrawal_amount,
                   type = 'ZAR_EFT',
                   beneficiary_id = investec_account_id,
                   )