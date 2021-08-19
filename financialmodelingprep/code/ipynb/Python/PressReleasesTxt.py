#!/usr/bin/env python
import datetime, pytz, holidays
from numpy.lib.type_check import nan_to_num
from numpy.core.numeric import NaN
from time import tzname
import pandas as pd

# import pandas_market_calendars as mcal
# cbot = mcal.get_calendar('CBOT_Equity')
# cbot.valid_days(start_date='2019-09-25', end_date='2021-07-15')


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

def getHour(time_str):
    time = datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S")
    return int(time.hour)

def isNaN(string):
    return string != string

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

df_text = pd.DataFrame(data=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix.csv'), 
                        columns=['Date', 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
df_title = pd.DataFrame(data=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix.csv'), 
                        columns=['Date', 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
df_title_text = pd.DataFrame(data=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix.csv'), 
                        columns=['Date', 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])

df_text.fillna('', inplace=True)
df_title.fillna('', inplace=True)
df_title_text.fillna('', inplace=True)

# df = pd.DataFrame()
# df=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix.csv')
# print(df)
# fdsafdsa
df_title.index = df_title["Date"]
df_text.index = df_text["Date"]
df_title_text.index = df_text["Date"]

print(df_text)

# df_text.index= pd.to_datetime(df_text.index)
# fileDateStr="2019-09-25"
# hour=8
# texts = df_text.loc[fileDateStr][hour]
# print(texts)
# fdsafdsa
# datetimeObj = datetime.datetime.strptime(fileDateStr, '%Y-%m-%d')
# titles = df_text.loc[datetimeObj][4]
# print(titles)
# fadsfasfsda
# Get The S&P 500 companies list
url = ("https://financialmodelingprep.com/api/v3/sp500_constituent?apikey=8941e8db3f939429e07397564861bc1a")
#print(get_jsonparsed_data(url))
sp500 = get_jsonparsed_data(url)
count=0

for i in sp500:
    count+=1

print("-----", count, "-----")
# nan = float('nan')
for company in sp500:

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company["symbol"])

    press_release = get_jsonparsed_data(url1)
    #print (press_release)
    for one_press_release in press_release:
        print("-------- start--------")
        #print(one_press_release)
        date_time_str = one_press_release['date']
        print("date_time_str="+date_time_str)
        dtobj_tz = tz_chicago.localize(datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S'))
        beforestr = str(dtobj_tz)
        beforestrdate = str(dtobj_tz.date())
        dtobj_utc = datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S').replace(tzinfo=tz_newyork)
        dtobj_tz = dtobj_utc.astimezone(tz_chicago)
        print("dfsafdafsd="+beforestrdate)
        # Good Frinday
        if ((beforestrdate=="2020-04-10") or (beforestrdate=="2021-04-02")):
            d = datetime.timedelta(days = 1)
            dtobj_tz = dtobj_tz + d
        finaltimeobj = getDate(dtobj_tz)
        hour = finaltimeobj.hour
        print("Hour="+str(hour))
        fileDateStr = str(finaltimeobj.date())
        print("Before getDate="+beforestr+" After getDate="+ str(finaltimeobj))
        
        # one_press_release['date'] = fileDateStr
        print("fileDateStr="+fileDateStr)
        file_str_title = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/title/' + fileDateStr + '.txt'
        file_str_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/text/' + fileDateStr + '.txt'
        file_str_title_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/title_text/' + fileDateStr + '.txt'

        f_title = open(file_str_title, "a", encoding='utf-8')
        f_text = open(file_str_text, "a", encoding='utf-8')
        f_title_text = open(file_str_title, "a", encoding='utf-8')

        # if (fileDateStr!="2021-08-09"):
        titles = df_title.loc[fileDateStr][hour]
        texts = df_text.loc[fileDateStr][hour]
        title_text = df_title_text.loc[fileDateStr][hour]

        if (titles==''):
            df_title.at[fileDateStr,hour] = one_press_release["title"]
        else:
            df_title.at[fileDateStr,hour] = titles + ". " + one_press_release["title"]

        if(texts==''):
            df_text.at[fileDateStr,hour] = one_press_release["text"]
        else:
            df_text.at[fileDateStr,hour] = texts + ". " + one_press_release["text"]
        
        if(title_text==''):
            df_title_text.at[fileDateStr,hour] = (one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        else:
            df_title_text.at[fileDateStr,hour] = title_text + ". " + (one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        # title_and_text = (one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        # df_text.at[fileDateStr,"title_and_text"] = titles_and_texts + title_and_text

        # df.at[fileDateStr,"hour"] = hour

        f_title.write(one_press_release["title"])
        f_text.write(one_press_release["text"])
        f_title_text.write(one_press_release["title"] + ". " + one_press_release["text"] + "\n")
        f_title.close()
        f_text.close()
        f_title_text.close()
        print("-------- end--------")

print("------------------------- Finish------------------------")

print(df_text)
#########text
df_text.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/texts.pkl')
df_text.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/texts.csv', sep=',', encoding='utf-8')
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/texts.pkl')

#########titles
df_title.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/titles.pkl')
df_title.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/titles.csv', sep='\t', encoding='utf-8')
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/titles.pkl')

#########title_text
df_title_text.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/title_text.pkl')
df_title_text.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/title_text.csv', sep='\t', encoding='utf-8')
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/title_text.pkl')

print("Finished")
