#!/usr/bin/env python
import datetime, pytz, holidays
from time import tzname
import pandas_market_calendars as mcal
cbot = mcal.get_calendar('CBOT_Equity')
cbot.valid_days(start_date='2019-09-25', end_date='2021-07-12')


tz_chicago = pytz.timezone('America/Chicago')
tz_newyork = pytz.timezone('America/New_York')
us_holidays = holidays.US()
def afterHours(theDate, check_hours=True):
    print("check afterHours")
    # if not now:
    #     now = datetime.datetime.now(tz)
    openTime = datetime.time(hour = 9, minute = 30, second = 0, tzinfo=tz_chicago)
    closeTime = datetime.time(hour = 16, minute = 0, second = 0, tzinfo=tz_chicago)
    #print(openTime.tzname())
    # If a holiday
    if theDate.strftime('%Y-%m-%d') in us_holidays:
        print("holiday")
        return True
    # If before 0930 or after 1600
    if (check_hours and ((theDate.time() < openTime) or (theDate.time() > closeTime))):
        print("before 0930 or after 1600")
        return True
    # If it's a weekend
    if (theDate.date().weekday() > 4):
        print("weekend")
        return True
    print("false")
    return False    

def getDate(theDate):
    if(afterHours(theDate)):
        d = datetime.timedelta(days = 1)
        while(afterHours(theDate, False)):
            theDate = theDate + d
        return theDate
    else:
        return theDate


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


#from datetime import datetime
companies2pressrelease = [0] * 505

date2count=0
for company in sp500:

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company["symbol"])

    press_release = get_jsonparsed_data(url1)
    #print (press_release)
    for one_press_release in press_release:

        #print(one_press_release)
        date_time_str = one_press_release['date']

        dtobj_tz = tz_chicago.localize(datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S'))
        beforestr = str(dtobj_tz)
        dtobj_utc = datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S').replace(tzinfo=tz_newyork)
        dtobj_tz = dtobj_utc.astimezone(tz_chicago)
        afterstr = str(dtobj_tz.time())

        finaltimeobj = getDate(dtobj_tz)
        fileDateStr = str(finaltimeobj.date())
        print("Before getDate="+beforestr+" After getDate="+ str(finaltimeobj))
        
        one_press_release['date'] = fileDateStr
 
        file_str = '/Users/Farid Srouji/Documents/Research/VIXInterplaySentiment/master/financialmodelingprep/data/txt/' + fileDateStr + '.txt'
        # print(file_str)
        f = open(file_str, "a", encoding='utf-8')
        #print(str(one_press_release))
        f.write(one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        f.close()

