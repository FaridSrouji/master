
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

# Get The S&P 500 companies list
url = ("https://financialmodelingprep.com/api/v3/sp500_constituent?apikey=8941e8db3f939429e07397564861bc1a")
#print(get_jsonparsed_data(url))
sp500 = get_jsonparsed_data(url)
count=0

for i in sp500:
    count+=1
    print("-----", count, "-----")


from datetime import datetime


for company in sp500:

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company["symbol"])

    press_release = get_jsonparsed_data(url1)
    #print (press_release)
    for one_press_release in press_release:

        #print(one_press_release)
        date_time_str = one_press_release['date']
        print(date_time_str)
        datetime_object = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S')
   
        #dateStr = datetime_object.date()
        Year = datetime_object.year # dateStr.strftime("%Y")
        Month = datetime_object.month # dateStr.strftime("%m")
        Day = datetime_object.day #dateStr.strftime("%d")

        Hour = datetime_object.strftime("%H") 
        Minute = datetime_object.strftime("%M")
        Second = datetime_object.strftime("%S")
        print("Hour=" + str(Hour))
        print(company)
        print(str(datetime_object.date()))
        file_str = '/Users/Farid/Documents/ProjectOptionsPredictions/data/financialmodelingprep/' + str(datetime_object.date()) + '.txt'
        print(file_str)     
        f = open(file_str, "a", encoding='utf-8')
        print(str(one_press_release))
        f.write(one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        f.close()