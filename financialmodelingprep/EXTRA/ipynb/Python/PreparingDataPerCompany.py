# -*- coding: utf-8 -*-
  
import numpy as np
import csv, json
import pandas as pd
from datetime import datetime

#pd.__version__
#pd.show_versi                       ons(as_json=False)             

################################################################################################
## Preparing VIX data
# Reading VIX index prices csv file
with open('/Users/Farid Srouji/Documents/Research/master/globaldata/VIX.csv', 'r') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    # Converting the csv file reader to a lists 
    data_list = list(spamreader)

# Separating header from the data
header = data_list[0] 
data_list = data_list[1:] 

data_list = np.asarray(data_list)

# Selecting date and close value for each day
selected_data = data_list[:, [0, 4, 5]]

df = pd.DataFrame(data=selected_data[0:,1:],
             index=selected_data[0:,0],
                                columns=['close', 'adj close'],
                                        dtype='float64')

# Reference for pandas interpolation http://pandas.pydata.org/pandas-docs/stable/missing_data.html
# Adding missing dates to the dataframe
# df1 = df
# idx = pd.date_range('2019-09-25', '2021-07-16')
# df1.index = pd.DatetimeIndex(df1.index)
# df1 = df1.reindex(idx, fill_value=np.NaN)
# df1.count() # gives 2518 count
interpolated_df = df.interpolate()
interpolated_df.count() # gives 3651 count

# Removing extra date rows added in data for calculating interpolation
#interpolated_df = interpolated_df[3:]

###############################################################################################  
## Preparing NYTimes data
# Function to parse and convert date format
date_format = ["%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S+%f"]
def try_parsing_date(text):
    for fmt in date_format:
        #return datetime.strptime(text, fmt)
        try:
            return datetime.strptime(text, fmt).strftime('%Y-%m-%d')
        except ValueError:
            pass
    raise ValueError('no valid date format found')

years = [2021, 2020, 2019]
months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
Hours = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
Minutes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
Seconds = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]

# dict_keys = ['date', 'title'] #, 'lead_paragraph']
# articles_dict = dict.fromkeys(dict_keys)

current_date = '2021-07-15'
from datetime import datetime

#current_article_str = ''      
import os.path

## Adding article column to dataframe
count_articles_filtered = 0
count_total_articles = 0
count_main_not_exist = 0               
count_unicode_error = 0     
count_attribute_error = 0
file_str_companies = '/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt'
file_opened_companies_list = open(file_str_companies, 'r').read().split('\n')
    

import os 
 
print (file_str_companies)
for company in file_opened_companies_list:
    print(company)
    directory = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies_txt/'+company+'/'
    print("directory="+directory)
    current_article_str = ''  
    for filename in os.listdir(directory):
        dateStr = os.path.splitext(filename)[0]
        #print("|"+dateStr+"|")
        #date = try_parsing_date(dateStr)
        #date = try_parsing_date(articles_dict['pub_date'])
        if (dateStr=="desktop"):
            print ("ERROR desktop.ini")
            pass
        else:
            #print ("did not EXIST")
            filename = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies_txt/'+company+"/" + filename
            #print(date)
            print("filename="+filename)
            if os.path.isfile(filename):
                #print ("exist1")
                try:
                    with open(filename, "r", encoding='UTF-8') as lines:
                        #print(current_article_str)
                        for one_line in lines:
                            if one_line in ['\n', '\r\n']:
                                print("empty line")
                            elif (current_article_str == ""):
                                current_article_str = one_line
                            else:
                                current_article_str = current_article_str + ". " + one_line
                                #print("current-article_str="+current_article_str)
                                count_total_articles+=1
                    interpolated_df.at[dateStr, 'articles'] = current_article_str
                    current_article_str = ""
                    count_total_articles+=1
                except KeyError:
                    print("KeyError")                  
                    count_main_not_exist += 1
                    pass   
                except TypeError:
                    print("TypeError")                   
                    count_main_not_exist += 1
                    pass


print(interpolated_df.keys)

print("count_total_articles=")                     
print(count_total_articles)                    
print("count_main_not_exist=")
print(count_main_not_exist)
print("count_unicode_error=")
print(count_unicode_error)

# Saving the data as pickle file
interpolated_df.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/pickled_filtered_lead_para_sp500_clean_companies.pkl')  

# Save pandas frame in csv form
interpolated_df.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/sample_interpolated_df_filtered_lead_para_sp500_clean_companies.csv',
                       sep='\t', encoding='utf-8')

# Reading the data as pickle file
dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/pickled_filtered_lead_para_sp500_clean_companies.pkl')

print("Finished")
#################################################################################

            
