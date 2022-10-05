# -*- coding: utf-8 -*-
current_date = '2021-07-16'

import numpy as np
import csv, json
import pandas as pd
from datetime import datetime
import os 
# import os.path

###############################################################################################  

date_format = ["%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S+%f"]
def try_parsing_date(text):
    for fmt in date_format:
        #return datetime.strptime(text, fmt)
        try:
            return datetime.strptime(text, fmt).strftime('%Y-%m-%d')
        except ValueError:
            pass
    raise ValueError('no valid date format found')

count_articles_filtered = 0
count_total_articles = 0
count_main_not_exist = 0               
count_unicode_error = 0     
count_attribute_error = 0
current_title_str = ''
current_text_str = ''

# ################################### ADD 30 MINUTES #############################################  

from datetime import timedelta

def add30Minutes(time_str):
    date_format_str = '%Y-%m-%d %H:%M:%S'
    # create datetime object from timestamp string
    given_time = datetime.strptime(time_str, date_format_str)
    print('Given timestamp: ', given_time)
    n = 30
    # Add 15 minutes to datetime object
    final_time = given_time + timedelta(minutes=n)
    print('Final Time (30 minutes after given time ): ', final_time)
    # Convert datetime object to string in specific format 
    final_time_str = final_time.strftime('%Y-%m-%d %H:%M:%S')
    print('Final Time as string object: ', final_time_str)
# # Given timestamp in string

def getHour(time_str):
    print("getHour time_str =")
    print(time_str)
    # datetime_obj = datetime(time_str)
    time = datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S")
    print("Hour="+str(time.hour))
    return str(time.hour)
    # print("Time = {:d}:{:02d}".format(time.hour, time.minute))

aaa = "2020-08-22 20:30:00"
getHour(aaa)
################################################################################################

years = [2021, 2020, 2019]
months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
Hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
Minutes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
Seconds = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]

with open('/Users/Farid Srouji/Documents/Research/master/globaldata/VIX.csv', 'r') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    # Converting the csv file reader to a lists 
    data_list = list(spamreader)

# Separating header from the data
header = data_list[0] 
data_list = data_list[1:] 

data_list = np.asarray(data_list)
print(data_list)

# Selecting date and close value for each day
selected_data = data_list[:, [0, 4, 5]]
# rng = pd.date_range('2019-09-25', periods=661, freq='D')
#df = pd.DataFrame({ 'Date': rng, 'Val' : np.random.randn(len(rng))}) 

df = pd.DataFrame(data=selected_data[0:,1:],
             index=selected_data[0:,0],
                                columns=['close', 'adj close'],
                                        dtype='float64')


print(df)

###############################################################################################  
import json
directory = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/'
for filename in os.listdir(directory):
    dateStr = os.path.splitext(filename)[0]
    print("dateStr="+dateStr)
    # if (dateStr=="desktop"):
    #     print ("ERROR desktop.ini")
    #     pass
    # else:
    filename = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/json/' + filename
    print("filename="+filename)
    if os.path.isfile(filename):
        try:
            with open(filename, "r", encoding='UTF-8') as lines:
                for one_line in lines:
                    print("Tyope="+str(type(one_line)))
                    print("One Line====")                    
                    # one_line = "'"+one_line+"'"
                    # print("OneLine="+one_line)
                    one_line_obj = eval(one_line)
                    print("Tyope2="+str(one_line_obj['date']))
                    timestr = str(one_line_obj['date'])
                    hourstr = getHour(timestr)
                    print("The Hour="+hourstr)
                    print("one_line_obj="+one_line_obj['date'])
                    if one_line in ['\n', '\r\n']:
                        print("empty line")
                    elif (current_title_str == ""):
                        current_title_str = one_line_obj['title']
                        current_text_str = one_line_obj['text']
                    else:
                        current_title_str = current_title_str + ". " + one_line_obj['title']
                        current_text_str = current_text_str + ". " + one_line_obj['date']
                        count_total_articles+=1        
            df.at[dateStr, 'hour'] = hourstr
            df.at[dateStr, 'title'] = current_title_str
            df.at[dateStr, 'text'] = current_text_str
            current_title_str = ""
            current_text_str = ""
            count_total_articles+=1
        except KeyError:
            print("KeyError")
            count_main_not_exist += 1
            pass   
        except TypeError:
            print("TypeError")                   
            count_main_not_exist += 1
            pass

print(df.index)
print(df)

print("count_total_articles=")                     
print(count_total_articles)                    
print("count_main_not_exist=")
print(count_main_not_exist)
print("count_unicode_error=")
print(count_unicode_error)

df.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/Hours.pkl')  
df.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/Hours.csv',
                       sep='\t', encoding='utf-8')
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/Hours.pkl')

print("Finished")

