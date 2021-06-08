#!/usr/bin/env python

try:
    # For Python 3.0 and later
    from urllib.request import urlopen
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen

import json

def get_jsonparsed_data(url):
    """
    Receive the content of ``url``, parse it as JSON and return the object.

    Parameters
    ----------
    url : str

    Returns
    -------
    dict
    """
    response = urlopen(url)
    data = response.read().decode("utf-8")
    return json.loads(data)

url = ("https://financialmodelingprep.com/api/v3/sp500_constituent?apikey=8941e8db3f939429e07397564861bc1a")
#print(get_jsonparsed_data(url))
sp500 = get_jsonparsed_data(url)
count=0


i=0
for company in sp500:
    count+=1
    print("-----", count, "-----")
    file_str = '/Users/Farid/Documents/ProjectOptionsPredictions/data/financialmodelingprep/companylist.json'
    print(file_str)
    f = open(file_str, "a", encoding='utf8')
    #print(str(one_press_release))
    f.write(company["symbol"] + "\n")
    f.close()