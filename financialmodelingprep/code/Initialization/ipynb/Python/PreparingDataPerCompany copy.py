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

years = [2021, 2020, 2019]
months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
Hours = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
Minutes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
Seconds = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]

import os 
   
import os.path

## Adding article column to dataframe
# count_articles_filtered = 0
# count_total_articles = 0
# count_main_not_exist = 0               
# count_unicode_error = 0     
# count_attribute_error = 0

date_format = ["%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S+%f"]
def try_parsing_date(text):
    for fmt in date_format:
        #return datetime.strptime(text, fmt)
        try:
            return datetime.strptime(text, fmt).strftime('%Y-%m-%d')
        except ValueError:
            pass
    raise ValueError('no valid date format found')

###############################################################################################  
current_date = '2021-07-15'

df_companies = pd.DataFrame(columns=['companies', 'count'])
mylist = pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/companylist.txt', compression=None)
print(mylist)
print(type(mylist))
df_companies[['companies']] = mylist

print(df_companies[['companies']])
mylist = df_companies[['companies']]
for index, row in df_companies.iterrows():
    print(row['companies'])
    company = row['companies']
    count_articles_filtered = 0
    count_total_articles = 0
    count_main_not_exist = 0               
    count_unicode_error = 0     
    count_attribute_error = 0
    df = pd.DataFrame(data=selected_data[0:,1:],
                index=selected_data[0:,0],
                                    columns=['close', 'adj close'],
                                            dtype='float64')

    interpolated_df = df.interpolate()
    interpolated_df.count() # gives 3651 count

    from datetime import datetime
    print(company)
    directory = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies_txt/'+company+'/'
    print("directory="+directory)
    current_article_str = ''  
    for filename in os.listdir(directory):
        dateStr = os.path.splitext(filename)[0]
        print("|"+dateStr+"|")
        # df_companies.at[company, dateStr] = 0
        row['count']=0
        print("row['count']="+str(row['count']))
        #date = try_parsing_date(dateStr)
        #date = try_parsing_date(articles_dict['pub_date'])
        if (dateStr=="desktop"):
            print ("ERROR desktop.ini")
            pass
        else:
            #print ("did not EXIST")
            filename = '/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/companies_txt/'+company+"/" + filename
            #print(date)
            #print("filename="+filename)
            print("----------0-----------")
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
                                # print("current-article_str="+current_article_str)
                                count_total_articles+=1
                                # df_companies.at[company, dateStr]+=1
                                row['count']+=1

                                print("--2---- row['count']"+company+", dateStr])="+str(row['count']))

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

    # row['count'] = count_total_articles
    # print(interpolated_df.keys)
    print("count_total_articles=")                     
    print(count_total_articles)                    
    print("count_main_not_exist=")
    print(count_main_not_exist)
    print("count_unicode_error=")
    print(count_unicode_error)

    # Saving the data as pickle file
    # interpolated_df.to_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/companies/'+company+'pickled_filtered_lead_para_sp500_clean_companies.pkl')  

    # # Save pandas frame in csv form
    # interpolated_df.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/companies/'+company+'sample_interpolated_df_filtered_lead_para_sp500_clean_companies.csv',
    #                     sep='\t', encoding='utf-8')

    # # Reading the data as pickle file
    # dataframe_read = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/companies/'+company+'pickled_filtered_lead_para_sp500_clean_companies.pkl')

print("Finished")
#################################################################################

print(df_companies)
df_companies.to_csv('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/csv/companies_date_count.pkl')