#!/usr/bin/env python
# coding: utf-8

# In[ ]:


get_ipython().run_line_magic('run', '"/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/code/Initialization/Init/Initialization.ipynb"')


# In[ ]:


import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import norm


# In[ ]:


# df[["Polarity","GI_Polarity"]]


# In[ ]:


df_values = df[[
    'VIX', 'S&P500','Positive_ewm','Negative_ewm',
    'Sentiment','Negative', 'Positive','Neutral', 'Compound', 'Polarity','Subjectivity','NewsVolume',"MarketCap",
    'GI_Negative', 'GI_Positive', 'GI_Sentiment', 'GI_Subjectivity','GI_Polarity'
    ]]
# df_values = df[[
#     'Sentiment','Negative','Positive','Neutral', 'Compound', 'Polarity','Subjectivity',
#     'NewsVolume','MarketCap',
#     'VIX', 'S&P500']]


# In[ ]:


# df_ln_returns = df[['GI_Negative return', 'GI_Positive return', 'GI_Sentiment return', 'GI_Subjectivity','GI_Polarity',
#     'Compound return', 'Negative return', 'Neutral return', 'Positive return','Sentiment return','Polarity','Subjectivity', 'NewsVolume return','MarketCapFactor',
#     'VIX return', 'S&P500 return']]
df_ln_returns = df[[
    'Negative_ewm_return','Positive_ewm_return',
    'Sentiment return','Negative return', 'Positive return', 'Neutral return','Compound return', 'Polarity','Subjectivity',
    'GI_Negative return', 'GI_Positive return', 'GI_Sentiment return', 'GI_Subjectivity','GI_Polarity', 
    'NewsVolume return','MarketCap return',
    'VIX return', 'S&P500 return']]


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
f.savefig("/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/images/Correlation/heatmap_values.png", bbox_inches='tight')
f.show()


# In[ ]:


corrmat = df_ln_returns.corr()
f, ax = plt.subplots(figsize =(20, 20))#(22, 20))
sns.set(font_scale=1) 
sns.heatmap(corrmat, ax = ax, cmap='coolwarm',vmin=-1,vmax=1, annot=True, linewidths = 0.1)

# sns.heatmap(corrmat, ax = ax, cmap ="YlGnBu", annot=True,  linewidths = 0.1)
f.tight_layout()
f.suptitle("Sentiment Variables Level Press Release 2020/06/01 - 2023/06/01",fontsize=26,weight='bold')
f.subplots_adjust(top=0.95)
f.savefig("/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/images/Correlation/heatmap_ln_returns.png", bbox_inches='tight')
f.show()


# # Grid Correlation Matrix

# In[ ]:


corrmat = df_values.corr()
cg = sns.clustermap(corrmat, cmap='coolwarm',vmin=-1,vmax=1, annot=True, linewidths = 0.1, figsize=(20, 20));

# cg = sns.clustermap(corrmat, cmap ="YlGnBu",  annot=True, linewidths = 0.1, figsize=(20, 20));
plt.setp(cg.ax_heatmap.yaxis.get_majorticklabels(), rotation = 0)
plt.tight_layout()
plt.suptitle("Sentiment VariablesPress Releases\n2020/06/01 - 2023/06/01",fontsize=26,weight='bold')
plt.subplots_adjust(top=0.95)
cg.savefig("/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/images/Correlation/clustermap_values.png", bbox_inches='tight')
# cg.show()


# In[ ]:


corrmat = df_ln_returns.corr()
cg = sns.clustermap(corrmat,cmap='coolwarm',vmin=-1,vmax=1, annot=True, linewidths = 0.1, figsize=(20, 20));
# cg = sns.clustermap(corrmat, cmap ="YlGnBu",  annot=True, linewidths = 0.1, figsize=(20, 20));
plt.setp(cg.ax_heatmap.yaxis.get_majorticklabels(), rotation = 0)
plt.tight_layout()
plt.suptitle("Sentiment Variables Level Press Releases\n2020/06/01 - 2023/06/01",fontsize=26,weight='bold')
plt.subplots_adjust(top=0.95)
cg.savefig("/Users/Farid Srouji/Documents/Research/master/financialmodelingprep/images/Correlation/clustermap_ln_return.png", bbox_inches='tight')
# cg.show()


# In[ ]:


cg.dendrogram_row.reordered_ind

