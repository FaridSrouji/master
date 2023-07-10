#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import norm
PresentDate = "2023-06-01"


# In[ ]:


df = pd.read_pickle("/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/data/pkl/df.pkl")


# In[ ]:


df_values = df[[
    'VIX', 'S&P500',
    #'Positive_ewm','Negative_ewm',
    'Sentiment','Negative', 'Positive','Neutral', 'Compound', 'Polarity','Subjectivity','NewsVolume',"MarketCap",
    'GI_Negative', 'GI_Positive', 'GI_Sentiment', 'GI_Subjectivity','GI_Polarity'
    ]]
# df_values = df[[
#     'Sentiment','Negative','Positive','Neutral', 'Compound', 'Polarity','Subjectivity',
#     'NewsVolume','MarketCap',
#     'VIX', 'S&P500']]


# # HeatMap

# In[ ]:


corrmat = df_values.corr()
sns.set(font_scale=1)

f, ax = plt.subplots(figsize =(13, 10))#(22, 20))
# sns.set(font_scale=1) 
sns.heatmap(corrmat, ax = ax, cmap='coolwarm',vmin=-1,vmax=1, annot=True, linewidths = 0.1)
f.tight_layout()
f.suptitle("Press Releases\nCorrelation Heatmap 2020-06-01 to " + PresentDate,fontsize=26,weight='bold')

f.subplots_adjust(top=0.95)
# sns.heatmap(corrmat, ax = ax, cmap ="YlGnBu", annot=True, linewidths = 0.1)
f.savefig("../static/heatmap_values.png", bbox_inches='tight')
f.show()

