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
    print(openTime.tzname())
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

# Get The S&P 500 companies list
url = ("https://financialmodelingprep.com/api/v3/sp500_constituent?apikey=8941e8db3f939429e07397564861bc1a")
sp500 = get_jsonparsed_data(url)

import os

DEBUG=True
CREATE_DF=True
if CREATE_DF: rows_list = []
# df = pd.DataFrame(columns=["Date", "Hour", "Articles", "Title", "Text", "Company"])

for company in sp500:

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company["symbol"])

    press_release = get_jsonparsed_data(url1)
    for one_press_release in press_release:
        if (DEBUG): print("-------------------- START ----------------------")
        date_time_str = one_press_release['date']
        if (DEBUG):  print("date_time_str="+date_time_str)
        # dtobj_tz = tz_chicago.localize(datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S'))
        dtobj_tz = datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S')
        if (DEBUG):  print("date_time_str="+date_time_str+"became:"+str(dtobj_tz))
        beforestr = str(dtobj_tz)
        beforestrdate = str(dtobj_tz.date())
        dtobj_utc = datetime.datetime.strptime(date_time_str, '%Y-%m-%d %H:%M:%S').replace(tzinfo=tz_newyork)
        dtobj_tz = dtobj_utc.astimezone(tz_chicago)
        if (DEBUG): print("beforestrdate="+beforestrdate)
        if ((beforestrdate=="2020-04-10") or (beforestrdate=="2021-04-02")):        # Good Frinday
            d = datetime.timedelta(days = 1)
            dtobj_tz = dtobj_tz + d
        finaltimeobj = getDate(dtobj_tz)
        hour = finaltimeobj.hour
        if (DEBUG): print("Hour="+str(hour))
        fileDateStr = str(finaltimeobj.date())
        if (DEBUG): print("Before getDate="+beforestr+" After getDate="+ str(finaltimeobj))

        if (DEBUG): print("fileDateStr="+fileDateStr)
        if (DEBUG): print("fileDateStr="+str(finaltimeobj))
        if (DEBUG): print("-------------------- END ----------------------")

        if (DEBUG==False):
            # For TXT DATE
            file_str_title = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title/' + fileDateStr + '.txt'
            file_str_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/text/' + fileDateStr + '.txt'
            file_str_title_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title_text/' + fileDateStr + '.txt'
            f_title = open(file_str_title, "a", encoding='utf-8')
            f_text = open(file_str_text, "a", encoding='utf-8')
            f_title_text = open(file_str_title, "a", encoding='utf-8')

            f_title.write(one_press_release["title"])
            f_text.write(one_press_release["text"])
            f_title_text.write(one_press_release["title"] + ". " + one_press_release["text"])
            f_title.close()
            f_text.close()
            f_title_text.close()

            # For TXT TIME
            file_str_title = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/title/' + str(finaltimeobj) + '.txt'
            file_str_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/text/' + str(finaltimeobj) + '.txt'
            file_str_title_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/title_text/' + str(finaltimeobj) + '.txt'

            f_title = open(file_str_title, "a", encoding='utf-8')
            f_text = open(file_str_text, "a", encoding='utf-8')
            f_title_text = open(file_str_title, "a", encoding='utf-8')

            f_title.write(one_press_release["title"])
            f_text.write(one_press_release["text"])
            f_title_text.write(one_press_release["title"] + ". " + one_press_release["text"])
            f_title.close()
            f_text.close()
            f_title_text.close()

            # For JSON DATE
            file_str_date = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/date/' + fileDateStr + '.json'
            f_date = open(file_str_date, "a", encoding='utf-8')
            f_date.write(str(one_press_release))
            f_date.close()

            # For JSON TIME
            file_str_time = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/time/' + str(finaltimeobj) + '.json'
            f_time = open(file_str_time, "a", encoding='utf-8')
            f_time.write(str(one_press_release))
            f_time.close()

            # For Comanies TXT
            dir_path_txt = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/txt/' +  company
            if (os.path.isdir(dir_path_txt) == False):
                os.mkdir(dir_path_txt)
            file_str = dir_path_txt + "/" + fileDateStr + '.txt'
            f = open(file_str, "a", encoding='utf-8')
            f.write(one_press_release["title"] + ". " + one_press_release["text"] + "\n")
            f.close()

            # For Comanies JSON
            dir_path_json = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/json/' +  company
            if (os.path.isdir(dir_path_json) == False):
                os.mkdir(dir_path_json)
            file_str = dir_path_json + "/" + fileDateStr + '.json'
            f = open(file_str, "a", encoding='utf-8')
            f.write(str(one_press_release))
            f.close()

        if (CREATE_DF):
            new_row = {'Date':finaltimeobj, 'Hour': hour, 'Articles':(one_press_release["title"] + ". " + one_press_release["text"]), 'Title':one_press_release["title"], 'Text':one_press_release["text"], 'Company':company["symbol"]}
            rows_list.append(new_row)
            # Create List for DATAFRAME
            # df.at[finaltimeobj, 'Articles']
            # if(df.loc[df['Date'] == finaltimeobj].na):
            #     dfrow = df.loc[df['Date'] == finaltimeobj]
            # df.at[finaltimeobj, "Articles"] =  df[finaltimeobj, "Articles"]+ ". " + (one_press_release["title"] + ". " + one_press_release["text"])
            # else:
         
                # df.insert(rows_list)

df_dates = pd.DataFrame(data=rows_list, columns=["Date", "Hour", "Articles", "Title", "Text", "Company"])
df = pd.DataFrame(columns=["Date", "Hour", "Articles", "Title", "Text", "Company"])
print(df_dates)
print(df_dates.index)
df.Date = df_dates.Date.unique()

print(df)
# for date, row in df_dates.T.iteritems():
#     df.
        # it = next((item for item in rows_list if item["Date"] == finaltimeobj), None)


        # dfrow.update(Date, 
        #                     Hour,
        #                     Articles + ". " + (one_press_release["title"] + ". " + one_press_release["text"]),
        #                     Title + ". " + one_press_release["title"],
        #                     Text + ". " + one_press_release["text"],
        #                     Company)
        # for d in rows_list:
        #     print(d.)
            # print((Date, 
            #        Hour,
            #        Articles + ". " + (one_press_release["title"] + ". " + one_press_release["text"]),
            #        Title + ". " + one_press_release["title"],
            #        Text + ". " + one_press_release["text"],
            #        Company) 
            # for Date, Hour, Articles, Title, Text, Company in d.items():
            #     if Date == finaltimeobj:
            #         d.update(Date, 
            #                 Hour,
            #                 Articles + ". " + (one_press_release["title"] + ". " + one_press_release["text"]),
            #                 Title + ". " + one_press_release["title"],
            #                 Text + ". " + one_press_release["text"],
            #                 Company)


print(df)
