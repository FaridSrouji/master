#!/usr/bin/env python
import datetime, pytz, holidays
from time import tzname
import pandas_market_calendars as mcal
cbot = mcal.get_calendar('CBOT_Equity')
cbot.valid_days(start_date='2019-09-25', end_date='2021-06-24')


tz = pytz.timezone('America/Chicago')
tz_pr = pytz.timezone('America/New_York')
us_holidays = holidays.US()
def afterHours(theDate):
        # if not now:
        #     now = datetime.datetime.now(tz)
        openTime = datetime.time(hour = 9, minute = 30, second = 0, tzinfo=tz)
        closeTime = datetime.time(hour = 16, minute = 0, second = 0, tzinfo=tz)
        print(openTime.tzname())
        # If a holiday
        if theDate.strftime('%Y-%m-%d') in us_holidays:
            return True
        # If before 0930 or after 1600
        if (theDate.time() < openTime) or (theDate.time() > closeTime):
            return True
        # If it's a weekend
        if theDate.date().weekday() > 4:
            return True

        return False    

def getDate(theDate):
    if(afterHours(theDate)):
        d = datetime.timedelta(days = 1)
        newDate = theDate + d
        return newDate
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


for company in sp500:

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=100000&apikey=8941e8db3f939429e07397564861bc1a" % company["symbol"])

    press_release = get_jsonparsed_data(url1)
    #print (press_release)
    for one_press_release in press_release:

        #print(one_press_release)
        date_time_str = one_press_release['date']
        print(date_time_str)
        datetime_object = datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S')
        datetime_object.replace(tzinfo=tz_pr)
        datetime_object.astimezone(tz_pr)
        print("tzinfo="+str(datetime_object.tzname()))
        #TODO: timezone

        datetime_obj = datetime.datetime(datetime_object.year,datetime_object.month, datetime_object.day, datetime_object.hour, datetime_object.minute, datetime_object.second, tzinfo=tz_pr)
        print("tzinfo="+str(datetime_obj.tzname()))
        file_datetime = getDate(datetime_obj)
        print("Before="+str(datetime_obj)+" After="+str(file_datetime ))
        one_press_release['date'] = str(file_datetime)

        print(str(datetime_obj.date()))
        file_str = '/Users/Farid Srouji/Documents/Research/VIX prediction/master/financialmodelingprep/data/json/' + str(file_datetime.date()) + '.json'
        print(file_str)     
        f = open(file_str, "a", encoding='utf-8')
        #print(str(one_press_release))
        f.write(str(one_press_release))
        f.close()
