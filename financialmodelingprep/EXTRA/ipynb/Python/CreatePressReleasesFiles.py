#!/usr/bin/env python
import datetime, pytz, holidays
from numpy.lib.type_check import nan_to_num
from numpy.core.numeric import NaN
from time import tzname
import pandas as pd
import os

DEBUG=False
CREATE_DF=True
TIME_FILES=False
CREATE_PR_SAVEFILES=True
CLEAN_FILES=True
CREATE_SP500_FILES=False
# import pandas_market_calendars as mcal
# cbot = mcal.get_calendar('CBOT_Equity')
# cbot.valid_days(start_date='2019-09-25', end_date='2021-07-15')


tz_chicago = pytz.timezone('America/Chicago')
tz_newyork = pytz.timezone('America/New_York')
us_holidays = holidays.US()
def afterHours(theDate, check_hours=True):
    if (DEBUG): print("check afterHours")
    # if not now:
    #     now = datetime.datetime.now(tz)
    openTime = datetime.time(hour = 9, minute = 30, second = 0, tzinfo=tz_chicago)
    closeTime = datetime.time(hour = 16, minute = 0, second = 0, tzinfo=tz_chicago)
    if (DEBUG): print(openTime.tzname())
    # If a holiday
    if theDate.strftime('%Y-%m-%d') in us_holidays:
        if (DEBUG): print("holiday")
        return True
    # If before 0930 or after 1600
    if (check_hours and ((theDate.time() < openTime) or (theDate.time() > closeTime))):
        if (DEBUG): print("before 0930 or after 1600")
        return True
    # If it's a weekend
    if (theDate.date().weekday() > 4):
        if (DEBUG): print("weekend")
        return True
    if (DEBUG): print("false")
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
if (CREATE_SP500_FILES):
    url = ("https://financialmodelingprep.com/api/v3/sp500_constituent?apikey=8941e8db3f939429e07397564861bc1a")
    sp500 = get_jsonparsed_data(url)
    count=0
    if os.path.exists("/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt"):
        os.remove("/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt")
    for company in sp500:
        count+=1
        file_str = '/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt'
        f = open(file_str, "a")#, encoding='utf8')
        #print(str(one_press_release))
        f.write(company["symbol"] + "\n")
        f.close()
    print("-----txt=", count, "-----")
    count=0
    if os.path.exists("/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.json"):
        os.remove("/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.json")
    for company in sp500:
        count+=1
        file_str = '/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.json'
        f = open(file_str, "a")#, encoding='utf8')
        #print(str(one_press_release))
        f.write(str(company) + "\n")
        f.close()
    print("-----json=", count, "-----")

with open('/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt') as f:
    companies = f.read()
companies = companies.split()

if (CLEAN_FILES):
    # DATE
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/text/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title_text/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    # TIME    
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/text/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title_text/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    # JSON
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/date/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/time/'
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))
    # COMPANIES
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/txt/'
    for company in os.listdir(dir):
        company_path = os.path.join(dir, company)
        for f in os.listdir(company_path):
            os.remove(os.path.join(company_path, f))
    dir = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/json/'
    for company in os.listdir(dir):
        company_path = os.path.join(dir, company)
        for f in os.listdir(company_path):
            os.remove(os.path.join(company_path, f))

if CREATE_DF: rows_list = []

for company in companies:
    print("Company = "+company)
    print("url1="+"https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company)

    url1 = ("https://financialmodelingprep.com/api/v3/press-releases/%s?limit=10000&apikey=8941e8db3f939429e07397564861bc1a" % company)
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
        if ((beforestrdate=="2020-04-10") or (beforestrdate=="2021-04-02") or (beforestrdate=="2021-08-09")):        # Good Frinday
            # print("Good Frinday"+beforestrdate)
            d = datetime.timedelta(days = 1)
            dtobj_tz = dtobj_tz + d

        finaltimeobj = getDate(dtobj_tz)
        # if ((beforestrdate=="2020-04-10") or (beforestrdate=="2021-04-02")):        # Good Frinday
        #     print("after Good Frinday"+str(finaltimeobj))
        hour = finaltimeobj.hour
        if (DEBUG): print("Hour="+str(hour))
        DateStr = str(finaltimeobj.date())
        print("Before getDate="+beforestr+" After getDate="+ str(finaltimeobj))

        if (DEBUG): print("fileDateStr="+DateStr)
        if (DEBUG): print("fileDateStr="+str(finaltimeobj))
        if (DEBUG): print("-------------------- END ----------------------")
        FullTimeDate = str(finaltimeobj).replace(" ", "_")

        if (CREATE_DF):
            new_row = {'Time':finaltimeobj, 'Date':DateStr, 'Hour': hour, 'Articles':(one_press_release["title"] + ". " + one_press_release["text"]), 'Title':one_press_release["title"], 'Text':one_press_release["text"], 'Company':company}
            rows_list.append(new_row)

        if (CREATE_PR_SAVEFILES):
            # For TXT DATE
            file_str_title = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title/' + DateStr + '.txt'
            file_str_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/text/' + DateStr + '.txt'
            file_str_title_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/date/title_text/' + DateStr + '.txt'
            f_title = open(file_str_title, "a", encoding='utf-8')
            f_text = open(file_str_text, "a", encoding='utf-8')
            f_title_text = open(file_str_title_text, "a", encoding='utf-8')

            f_title.write(one_press_release["title"])
            f_text.write(one_press_release["text"])
            f_title_text.write(one_press_release["title"] + ". " + one_press_release["text"])
            f_title.close()
            f_text.close()
            f_title_text.close()

            # For TXT TIME
            if (TIME_FILES):
                file_str_title = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/title/' + FullTimeDate + '.txt'
                file_str_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/text/' + FullTimeDate + '.txt'
                file_str_title_text = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/txt/time/title_text/' + FullTimeDate + '.txt'

                f_title = open(file_str_title, "a", encoding='utf-8')
                f_text = open(file_str_text, "a", encoding='utf-8')
                f_title_text = open(file_str_title_text, "a", encoding='utf-8')

                f_title.write(one_press_release["title"])
                f_text.write(one_press_release["text"])
                f_title_text.write(one_press_release["title"] + ". " + one_press_release["text"])
                f_title.close()
                f_text.close()
                f_title_text.close()

            # For JSON DATE
            file_str_date = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/date/' + DateStr + '.json'
            f_date = open(file_str_date, "a", encoding='utf-8')
            f_date.write(str(one_press_release))
            f_date.close()

            # For JSON TIME
            if (TIME_FILES):
                file_str_time = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/time/' + FullTimeDate + '.json'
                f_time = open(file_str_time, "a", encoding='utf-8')
                f_time.write(str(one_press_release))
                f_time.close()

            # For Comanies TXT
            dir_path_txt = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/txt/' +  company
            if (os.path.isdir(dir_path_txt) == False):
                os.mkdir(dir_path_txt)
            file_str = dir_path_txt + "/" + DateStr + '.txt'
            f = open(file_str, "a", encoding='utf-8')
            f.write(one_press_release["title"] + ". " + one_press_release["text"] + "\n")
            f.close()

            # For Comanies JSON
            dir_path_json = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies/json/' +  company
            if (os.path.isdir(dir_path_json) == False):
                os.mkdir(dir_path_json)
            file_str = dir_path_json + "/" + DateStr + '.json'
            f = open(file_str, "a", encoding='utf-8')
            f.write(str(one_press_release))
            f.close()

df_dates = pd.DataFrame(data=rows_list, columns=["Time", "Date", "Hour", "Articles", "Title", "Text", "Company"])
df_dates = df_dates.sort_values(by='Time') 

df_dates.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/df_dates.pkl')
df_dates.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/csv/df_dates.csv', sep=',', encoding='utf-8')
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/df_dates.pkl')

print("Finished")