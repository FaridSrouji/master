import numpy as np
import pandas as pd
from nltk.classify import NaiveBayesClassifier
from nltk.corpus import subjectivity
from nltk.sentiment import SentimentAnalyzer
from nltk.sentiment.util import *

import numpy as np 
import pandas as pd 
#pd.set_option('display.max_colwidth', -1)
from time import time
import re
import string
import os
from pprint import pprint
import collections

import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="darkgrid")
sns.set(font_scale=1.3)

from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.metrics import classification_report

from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
#from sklearn.externals import joblib
import joblib as jb

#import gensim

from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.tokenize import word_tokenize

import warnings
warnings.filterwarnings('ignore')

np.random.seed(37)

# Reading the saved data pickle file
df  = pd.DataFrame()
df = pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/pickled_filtered_lead_para_sp500_clean.pkl', compression=None)
df_sentiment=pd.read_pickle('/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/sentiment.pkl', compression=None)
df_vix=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix.csv')
df_vix_2010_2021=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix_2010_2021.csv')

df_vix.index = df.index
df = df.join(df_vix)
df = df.join(df_sentiment)
df["vix"] = df["adj close"]
vix_yesterday = df["vix"].shift(periods=1)
df["vix_ln_return"]=np.log(df["vix"]/vix_yesterday)
df['sentiment'] = df[["sentiment"]].apply(pd.to_numeric)
df["sentiment_ewm"]=df["sentiment"].ewm(10).mean()
df.index= pd.to_datetime(df.index)
df.index= pd.to_datetime(df.index)
df["date"]=df.index
df_part1 = df.loc['2019-09-25':'2020-02-14']
df_part2 = df.loc['2020-02-15':'2020-05-31']
df_part3 = df.loc['2020-06-01':'2021-07-15']

df1_part3 = df_part3
idx = pd.date_range('2020-06-01', '2021-07-15')
df1_part3.index = pd.DatetimeIndex(df1_part3.index)

import datetime as dt
from datetime import date
import calendar
my_date = date.today()
calendar.day_name[my_date.weekday()]  #'Wednesday'

# Prepare data
df_part3['year'] = [d.year for d in df_part3.index]
df_part3['month'] = [d.strftime('%b') for d in df_part3.index]
df_part3['day'] = [d for d in df_part3.index.day_name()]
years = df_part3['year'].unique()
df_part3['month-year'] = [d.strftime('%b') + str(d.year) for d in df_part3.index]

############### VIX #################

# Import Data
df_vix_2010_2021=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix_2010_2021.csv')
df_options=pd.read_csv('/Users/Farid Srouji/Documents/Research/master/globaldata/vix_2010_2021.csv')
df_vix_2010_2021['Date']= pd.to_datetime(df_vix_2010_2021['Date'])
df_vix_2010_2021.index= df_vix_2010_2021['Date']
print("df_vix_2010_2021['Date']="+str(type(df_vix_2010_2021['Date'])))
print("df_part3['Date']="+str(type(df_part3['date'])))

df_vix_2010_2021["vix"] = df_vix_2010_2021["Adj Close"]#.apply(np.int)
df_vix_2010_2021["vix_ln_return"]=np.log(df_vix_2010_2021["vix"]/df_vix_2010_2021["vix"].shift(1))

import datetime as dt
from datetime import date
import calendar
my_date = date.today()
calendar.day_name[my_date.weekday()] 

df_vix_2010_2021['year'] = [d.year for d in df_vix_2010_2021.Date]
df_vix_2010_2021['month'] = [d.strftime('%b') for d in df_vix_2010_2021.Date]
df_vix_2010_2021['day'] = [d for d in df_vix_2010_2021.index.day_name()]
years = df_vix_2010_2021['year'].unique()
df_vix_2010_2021['month-year'] = [d.strftime('%b') + str(d.year) for d in df_vix_2010_2021.Date]

############## SPX ###################
#if you get an error after executing the code, try adding below:
pd.core.common.is_list_like = pd.api.types.is_list_like

import pandas_datareader.data as web
import datetime

start = datetime.datetime(2019, 9, 25)
end = datetime.datetime(2021, 7, 16)
SP500  = pd.DataFrame()

SP500 = web.DataReader(['sp500'], 'fred', start, end)

df = df.join(SP500)
sp500_yesterday = df["sp500"].shift(periods=1)
df["sp500_ln_return"]=np.log(df["sp500"]/sp500_yesterday)

df_part3 = df_part3.join(SP500)
sp500_yesterday = df_part3["sp500"].shift(periods=1)
df_part3["sp500_ln_return"]=np.log(df_part3["sp500"]/sp500_yesterday)