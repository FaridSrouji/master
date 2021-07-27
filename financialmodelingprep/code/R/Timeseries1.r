---
# title: ''
# author: ""
date: '`r Sys.Date()`'
output:
  html_document:
    number_sections: true
    fig_caption: true
    toc: true
    fig_width: 7
    fig_height: 4.5
    theme: cosmo
    highlight: tango
    code_folding: hide
---

```{r setup, include=FALSE, echo=FALSE}

knitr::opts_chunk$set(
    echo = TRUE,
    message = FALSE,
    warning = FALSE,
    error = FALSE
)

```

<span style="background:#fed56f; font-weight:bold; color:black">Please if you liked the notebook give an upvote. The reason why I am asking is becauseu an upvote gives us the Kaggle user the motivation to bring content you like in the foreseen future. Also, it will help me understand if I have to improve on certain aspects of the noteook. Therefore, if you also think there is something I could do to improve in this project, feel free to write a constructive criticism in the comment section. </span>


# Purpose of this Notebook
# The purpose of this notebook is to show the Kaggle community how to use the timetk package in R to analyze time series data. When we think of time series analysis the first thing that would probably come to our mind is <b>"forecasting".</b> However, time series data is much more than forecasting and although forecasting seems to be an interesting aspect when analyzing time series data, it is important to know some of the other concepts which include:
# I hope you will like this notebook and my main goal is to give to the Kaggle community a brief introduction to the time series topic.


<ul>
<li>Data Exploration</li>
<li>Locally Estimated Scatterplot Smoothing (LOESS) </li>
<li>Autocorrelation </li>
<li>Cross Correlation </li>
<li>Transformation Techniques </li>
<li>Seasonal Decomposition </li>
</ul>

Without understanding how your time series behaves it will be complex to understand what is an accurate forecast based on past events.

# Sources
Ive been a fan of Matt Danchos courses so it is fair enough to say that his [High-Performance Time Series Forecast Course](https://www.business-science.io/university/2020/08/31/course-launch-time-series-coming-soon.html) has taught me important concepts. Not only he brings this amazing course but also he is the creator of the **timetk**, **tidyquant** and **modeltime** packages. <br><br>

**Note:** I am not a sponsor for his course but I think whoever wants to step up his knowledge on time series should definitely try it. <br><br>


**Other sources include:**
<ul>
<li>[Forecasting: Principles and Practice by Robert J Hyndman and George Athanasopoulos](https://otexts.com/fpp2/)</li>
<li>[Time Series Analysis and Its Applications by Robert H.Shumway and David S. Stoffer](http://db.ucsd.edu/static/TimeSeries.pdf) </li>
</ul>

**Note:** I will keep adding sources as I make progress while working on the notebook. 


# Chapter 2:
Visit the next chapter for getting more concepts on time series. In the next chapter we will focus on feature engineering for improving predictability. 
[Time Series || Feature Engineering Concepts](https://www.kaggle.com/janiobachmann/time-series-feature-engineering-concepts)

# Project Style
Since I started publishing my notebooks within the Kaggle community, I start publishing before ending the notebook. **Why would I do that?** Because I am eager to look for constructive criticisms and suggestions along my project. My most successful projects were the ones that I had most interactions with the Kaggle community. Good Ideas came from the comment sections which allowed me to improve even further my notebooks. Hence, this is the reason why I start publishing my notebooks before finishing them. Hope you like this one and most importantly hope we can all learn together!

<center>
![Dow Jones](https://www.business-science.io/assets/2020-03-18-timeseries-ml/time-series-machine-learning-in-r.jpg)

# Loading and Gaining Insights


## Loading Libraries for the analysis and Importing File

```{r import_libraries}


# Core libraries
library(tidyverse)
library(timetk)
library(tidyquant)


# Exploration
library(DataExplorer)


# Visualization
library(plotly)
library(highcharter)
library(gt)
library(ggthemes)


```


## Classifying Companies by Sector
Before digging into our time series data I wanted to explore the number of stocks for each sector. I classified the sector based on the [MarketWatch Website](https://www.marketwatch.com/).


**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Using treemap for visualization:</span> To visualize the number of occurences for each sector, I used a treemap to better count the number of stocks in each sector. Since we have several sectors a treemap would be a good option to use in this case.</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Technology the most popular sector:</span> The technology sector is the most popular sector in the Dow Jones Index with 7 stocks classified within that sector. (Notice: since this is from past data there are stocks that might not be such as the case of "AABA" (Yahoo), which was taken our of the index. ) </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Companies that comprise the Technology Sector:</span> Apple, Cisco, Intel, Microsoft, United Technologies, Google and Yahoo (last one is currently not in the index)</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Where do we get this colors in the treemap?!</span> If you are curious, these colors comes from the tidyquant package. If you want to get all the color codes you can run the "palette_light()" and it will output all the colors from the tidyquant package. </li>
</ul>


```{r read_file}
# read the data ----

complete_stock_tbl <- read.csv("../input/stock-time-series-20050101-to-20171231/all_stocks_2006-01-01_to_2018-01-01.csv")

# Create sector by type of stock
# AABA (Yahoo final day of trading in October)
# Yahoo was classified as Technology
final_stock_tbl <- complete_stock_tbl %>% 
  set_names(names(.) %>% str_to_lower()) %>% 
  mutate(
    sector = case_when(
      name == "MMM" ~ "Business/Consumer Services",
      name == "AXP" ~ "Financial Services",
      name == "AAPL" ~ "Technology", 
      name == "BA" ~ "Industrial Goods",
      name == "CAT" ~ "Industrial Goods", 
      name == "CVX" ~ "Companies on the Energy Service",
      name == "CSCO" ~ "Technology",
      name == "KO" ~ "Consumer Goods", 
      name == "DIS" ~ "Media/Entertainment",
      name == "XOM" ~ "Companies on the Energy Service",
      name == "GE" ~ "Business/Consumer Services",
      name == "GS" ~ "Financial Services",
      name == "HD" ~ "Retail/Wholesale",
      name == "IBM" ~ "Business/Consumer Services",
      name == "INTC" ~ "Technology",
      name == "JNJ" ~ "Health Care/Life Sciences",
      name == "JPM" ~ "Financial Services",
      name == "MCD" ~ "Leisure/Arts/Hospitality",
      name == "MRK" ~ "Health Care/Life Sciences",
      name == "MSFT" ~ "Technology",
      name == "NKE" ~ "Consumer Goods",
      name == "PFE" ~ "Health Care/Life Sciences",
      name == "PG" ~ "Consumer Goods",
      name == "TRV" ~ "Financial Services",
      name == "UTX" ~ "Technology", 
      name == "UNH" ~ "Financial Services", 
      name == "VZ" ~ "Telecommunication Services", 
      name == "WMT" ~ "Retail/Wholesale",
      name == "GOOGL" ~ "Technology",
      name == "AMZN" ~ "Retail/Wholesale",
      TRUE ~ "Technology"
      
    )
  )


# To get the technology stocks
# final_stock_tbl %>% 
#   filter(sector == "Technology") %>% 
#   distinct(name)
```




```{r tree_map_sector}
# Count by unique sector
stocks_by_sector <- final_stock_tbl %>% 
  distinct(sector, name) %>%
  group_by(sector) %>% 
  summarise(
    count = n()
  ) %>% 
  ungroup() %>% 
  arrange(desc(count))
# Use palette_light() to know the color codes of tidyquant theme


# Treemap with Tidyquant colors
treemap_by_sector <- stocks_by_sector %>% 
hctreemap2(group_vars = "sector",
           size_var = "count",
           layoutAlgorithm = "squarified") %>%
    hc_plotOptions(treemap = list(colorByPoint = TRUE)) %>%
    hc_colors(c("#2C3E50", "#E31A1C", "#18BC9C", "#CCBE93", 
                "#A6CEE3", "#1F78B4", "#B2DF8A", "#FB9A99",
                "#FDBF6F", "#FF7F00", "#6A3D9A" )) %>%
    hc_colorAxis(dataClasses = color_classes(stocks_by_sector$sector)) %>%    
    hc_legend(enabled = FALSE) %>% 
  hc_title(text = "Number of Companies by Sector") %>% 
  hc_subtitle(text = "Dow Jones Index") %>% 
    hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
             Count: {point.value:,.0f}")



# Return the plot
treemap_by_sector


```

## Companies to Analyze
The following companies will be analyzed:
<ul>
<li>**Apple (AAPL):** Belongs to the Technolgy sector. </li>
<li>**Caterpillar (CAT):** Belongs to the Industrial Goods sector. </li>
<li>**Google (GOOGL): ** Belongs to the Technology sector. </li>
<li>**Exxon (XOM):** Belongs to the Energy sector </li>
<li>**Golman Sachs (GS):** Belongs to the Financial Sector.</li>
<li>**WalMart: ** Belongs to the Retail/Wholesale sector. </li>
</ul>



## Explaining Loess {.tabset .tabset-fade .tabset-pills}
As shown in the plots below we see some companies which are less volatile than others, companies that have a more upward trend line than others. But have you ever asked yourself what is the point of the trendline and how it is calculated? **LOESS** stands for **Locally Weighted Scatterplot Smoothing** and think of this as a regression within a specific "window" (range of time) in which the closest observation is given more weight than "farther" observations of a specific "focal point". We performed weighted least squared (best fitting line). I would suggest to look at this explanation from [StatQuest](https://www.youtube.com/watch?v=Vf7oJ6z2LCc&t=191s) since it explains in an easy to understand way how the Smooth line is calculated (LOESS). <br><br>


Nevertheless, I would say these are the most important points for understanding how LOESS works.

<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Number of observations within a window:</span> The higher the number of observations within a specific window, the smoother the trendline will be. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Focal Point:</span> Is the observation for which we are performing LOESS (The closer other observations are from this focal point, the "higher the weights assigned to these observations" causing those values (closer to the focal point) to have a higher impact to the trendline). </li>
</ul>

<br>

**Formula for Assigning weights (Tricube weight function)**
<br>
Where:<br>
<ul>
<li>k: Number of observations (within each window)</li>
<li>xi: Focal Point </li>
<li>xk: "The neighboring point". </li>
<li>di: Distance from Focal point to the Nth neighboring point.  </li> <br>


$\LARGE w(x_k) = (1-|\frac{x_i - x_k}{d_i}|^3)^3$

<br>

After that linear regression is apply to find the line that reduces error the most. This will be done for all points in the "actual" time series. 




```{r funct_by_time}
# Function to get average price by week, month and quarter
# If we use the mean(close) daily we get the actual values
# Since values are unique
convert_date_ts <- function(data, unit = "day"){
  
  new_data <- data %>% 
    mutate(date = floor_date(date, unit = unit)) %>% 
    group_by(date, name) %>% 
    summarise(
      close = mean(close)
    ) %>% 
    ungroup()
  
  return(new_data)
}


```


### Day

```{r ts_daily}
# Pick by stock (6 stocks from different industries)
filtered_final_stock_tbl <- final_stock_tbl %>% 
  filter(name %in% c("AAPL", "GS", "GOOGL", "XOM", "CAT", "WMT")) %>% 
  mutate(
    date = ymd(date)
  )

# Daily
filtered_final_stock_tbl %>% 
  convert_date_ts() %>% 
  group_by(name) %>% 
  plot_time_series(
    .date_var = date,
    .value = close,
    .facet_ncol = 2,
    .smooth_color = "#18BC9C",
    .smooth_size = 0.5
  )


```

### Week

```{r ts_weekly}
filtered_final_stock_tbl %>% 
  convert_date_ts(unit = "week") %>% 
  group_by(name) %>% 
  plot_time_series(
    .date_var = date,
    .value = close,
    .facet_ncol = 2,
    .smooth_color = "#18BC9C",
    .smooth_size = 0.5
  )


```


### Month

```{r ts_monthly}

filtered_final_stock_tbl %>% 
  convert_date_ts(unit = "month") %>% 
  group_by(name) %>% 
  plot_time_series(
    .date_var = date,
    .value = close,
    .facet_ncol = 2,
    .smooth_color = "#18BC9C",
    .smooth_size = 0.5
  )

```

### Quarter

```{r ts_quarterly}

filtered_final_stock_tbl %>% 
  convert_date_ts(unit = "quarter") %>% 
  group_by(name) %>% 
  plot_time_series(
    .date_var = date,
    .value = close,
    .facet_ncol = 2,
    .smooth_color = "#18BC9C",
    .smooth_size = 0.5
  )

```



### Year

```{r ts_yearly}
filtered_final_stock_tbl %>% 
  convert_date_ts(unit = "year") %>% 
  group_by(name) %>% 
  plot_time_series(
    .date_var = date,
    .value = close,
    .facet_ncol = 2,
    .smooth_color = "#18BC9C",
    .smooth_size = 0.5
  )


```



## Determining missing values with DataExplorer
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Using DataExplorer:</span> The DataExplorer library is a useful package to initially explore your data which is critical for understanding your table.  </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Missing data:</span> We have some missing data in the open, high and low. However, I suspect this is coming from the data itself rather than from some major event. Especially, if we have the closing price for those companies. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Imputation of Missing Values: </span> There are techniques to deal with missing values which will help with the missing data. For now just know that there are ways to deal with missing data.  </li>
</ul>


```{r missing_data}
# Missing values on the 2017-07-31

filtered_final_stock_tbl %>% 
  plot_missing(
    ggtheme = theme_calc(), 
    title = "Percent Missing Values by Column"
  )

```



## Which Stocks grew the most percent wise on average {.tabset .tabset-fade .tabset-pills}
Note: As expected, during the years of 2007 and 2008 is where we have the highest volatility due to the financial crisis that occur during those years caused mainly by uncertainty in the markets.

<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Apple (AAPL):</span> Not so surprisingly enough, Apple was the one on top of the list when it comes to returns. However, when the time period gets into Quarterly and Yearly the standard deviation is much higher meaning that this company faced a lot of volatility at certain periods of time. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">EXXON (XOM):</span> Had the lowest amount of stock return.</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Goldman Sachs (GS):</span> This company had on average the highest level of volatility, probably mostly impacted by the financial recession of 2007-2008. </li>

</ul>

```{r stock_returns_by_company}
# Daily stock return by company
# Using Tidyquant package

daily_stock_return <- filtered_final_stock_tbl %>%
  mutate(
    name = name %>% as_factor()
  ) %>% 
  group_by(name) %>% 
  tq_transmute(
    select = close,
    mutate_fun = periodReturn,
    period = "daily",
    col_rename = "stock_return"
  )

# Visualization with ggplot
daily_stock_return %>% 
  ggplot(aes(x=date, y=stock_return)) + geom_line(color = palette_light()[[1]]) + 
  facet_wrap(~name) + theme_calc() + 
  labs(
    title = "Stock Returns",
    subtitle = "by Company",
    y = "returns"
  ) + 
  theme(plot.title = element_text(hjust=0.5)) 

  

```



```{r return_vol_tbl}
return_volatility_tbl <- function(data, unit="daily", ...){
  
  vars_col <- quos(...)
  
  tbl_return_volatility <- data %>% 
    mutate(
    name = name %>% as_factor()
  ) %>% 
  group_by(name) %>% 
  tq_transmute(
    select = close,
    mutate_fun = periodReturn,
    period = unit,
    col_rename = "stock_return"
  ) %>% 
    mutate(
    company = case_when(
      name == "AAPL" ~ "Apple",
      name == "GOOGL" ~ "Google",
      name == "XOM" ~ "Exxon",
      name == "GS" ~ "Goldman Sachs",
      name == "WMT" ~ "Walmart",
      TRUE ~ "Caterpillar"
    )
  ) %>% 
    group_by(!!!vars_col) %>% 
      summarise(
    `percent return` = mean(stock_return),
    `standard deviation` = sd(stock_return)
  ) %>% 
  ungroup() %>% 
  arrange(desc(`percent return`)) %>% gt() %>% 
  data_color(
    columns = vars(`standard deviation`),
    colors = scales::col_numeric(
      palette = c("#ffffff", "#f2fbd2", "#FA6047", "#F25555", "#FA1B1B"), 
      domain = NULL
    )) %>% 
  data_color(
    columns = vars(`percent return`),
    colors = scales::col_numeric(
      palette = c("#ffffff", "#f2fbd2", "#c9ecb4", "#93d3ab", "#35b0ab"),
      domain = NULL
    )
  ) %>% fmt_percent(
    columns = vars(`percent return`), 
    decimals = 4
  ) %>% 
  fmt_number(
    columns = vars(`standard deviation`),
    decimals = 4
  ) %>% 
    tab_header(
    title = md("**2006 - 2017 Measure of Return and Volatility**"),
    subtitle = "An overview of Risk and Return"
  )
  
  
  return(tbl_return_volatility)
    
}
```


### Daily

```{r risk_return_table}
filtered_final_stock_tbl %>% 
  return_volatility_tbl(unit = "daily", company, name)
  

```


### Weekly

```{r return_weekly}
filtered_final_stock_tbl %>% 
  return_volatility_tbl(unit = "weekly", company, name)


```



### Monthly

```{r return_monthly}
filtered_final_stock_tbl %>% 
  return_volatility_tbl(unit = "monthly", company, name)

```


### Quarterly


```{r return_quarterly}
filtered_final_stock_tbl %>% 
  return_volatility_tbl(unit = "quarterly", company, name)


```


### Yearly
```{r return_yearly}
filtered_final_stock_tbl %>% 
  return_volatility_tbl(unit = "yearly", company, name)

```

## Exploring Seasonality and Pattern
To better understand certain seasonality patters it is critical to see how the target variable behaves at certain periods of time. In this case we would analyze how the closing price of company x behaves at different days of the week, months, quarters and years. This could help us understand if there are other external factors that influences the **price of the stock.**

**Summary:**
<ul>
<li>**Different periods in time:** We will analyze the distribution at during weekdays, week, month quarter and year.
</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Exxon (XOM)</span> For this case we will look at how the stock of Exxon behaves. We will see the distribution of the closing price at different points in time. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Weekdays: </span> During weekdays we dont see an obvious differents in the distribution of the closing price. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Months:</span> Months of June and December tend to have a slighltly higher closing price. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Quarters:</span> The second and fourth quarter has a slightly higher median price in the distribution of the closing price. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Year:</span> 2010 had the worst distribution in the closing price for the company (probably an external factor impacted the sector), while 2014 was the year in which the distribution of the closing price was the highest. </li>
</ul>

```{r seasonality_boxplot, fig.height=8}
                                 
# Let's pick Exxon for seasonality 
filtered_final_stock_tbl %>% 
  filter(name == "XOM") %>% 
  plot_seasonal_diagnostics(
    .date_var = date,
    .value = close,
    .interactive=FALSE
  )


```

## STL (Seasonal and Trend decomposition using LOESS) {.tabset .tabset-fade .tabset-pills}

When we talk about **Seasonal Decomposition** think of it as a technique to decompose a time series into three characteristics.
<ul>
<li> Trend </li>
<li> Seasonality </li>
<li> Residual (Remainder) </li>
<br>

<span style="background:#fed56f; font-weight:bold; color:black">Explaining Trend:</span>
As we have seen before, trend gives a general direction as to where the time series is heading at. Remember, trend is determined by using "LOESS" which is nothing more than a local regression within a specific window time frame. <br>

<span style="background:#fed56f; font-weight:bold; color:black">Explaining Seasonality:</span>
In the second panel we observe the seasonal swing across time. This is usually capture around the trend line we observe in the first panel.Capturing seasonality swings could help our forecast model if seasonality has an impact on predicting a target variable in this case a closing price. When the seasonality is constant as shown below we have an **Additive Decomposition**. Additive Decompositions assumes that the swings in our second panel are the same every year (constant). When the seasonality is not constant then we have a **Multiplicative Decomposition**. We usually use multiplicative decomposition when we use an exponential growth in our seasonality panel.

<span style="background:#fed56f; font-weight:bold; color:black">Combining Seasonality + Trend :</span>
By combining this two, we try to replicate the actual time series data although, they are not the same it is quite a close approximation.

<span style="background:#fed56f; font-weight:bold; color:black">Residuals:</span>
This is just the remainder between the actual data and the seasonal + trend time series. 


**Note:** To understand this concept I would suggest looking at visualizations in youtube since it is much better to grasp especially when you are new to this topic of time series. Here are some interesting videos to look at:
<ul>
<li>[Seasonal Decompositoin and Forecasting, Part 1](https://www.youtube.com/watch?v=85XU1T9DIps) </li>
<li>[What is Time Series Decomposition](https://www.youtube.com/watch?v=0ar9extHObg) </li>
<li>[Introduction to Time Series in R: The Decompose Function](https://www.youtube.com/watch?v=VrJYOItZYLQ) </li>


<br>

**Formulas:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Additive Decomposition:</span> $Seasonal + Trend + Random$ </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Multiplicative Decomposition:</span> $Seasonal*Trend*Random$ </li>

**Note: To see the seasonality zoom in on the season panel for one of the stocks. You will clearly see an Additive Decomposition. Please click on the interactive tab.**

### Non-Interactive STL


```{r seasonal_decomposition_AAPL, fig.height=8}
# Function to create seasonal decomposition with loess for the stocks

plot_seasonal_decomposition <- function(data, interactive=FALSE){
  
  stl_plot <- data %>% 
    group_by(name) %>% 
    plot_stl_diagnostics(
      .date_var = date,
      .value = log1p(close),
      .interactive = interactive
    )
  
  return(stl_plot)
}


# Visualization Not interactive
filtered_final_stock_tbl %>% 
  filter(name %in% c("AAPL", "XOM", "GS")) %>% 
  group_by(name) %>% 
  plot_seasonal_decomposition()



```


### Interactive STL

```{r interactive_stl, fig.height=8}

filtered_final_stock_tbl %>% 
  filter(name %in% c("AAPL", "XOM", "GS")) %>% 
  group_by(name) %>% 
  plot_seasonal_decomposition(interactive = TRUE)

```


## Outlier Detection
Anomalies are used mainly for finding out events that were not expected in our time series. It can also be that a mistake in the data could have caused an outlier in the time series. **Detecting Outliers** gives us the possibility of investigating further if events that were not expected actually drove the time series to behaved in an anomaly manner.






```{r outlier_detection, fig.height=6}

filtered_final_stock_tbl %>%
  group_by(name) %>%
  plot_anomaly_diagnostics(
    .date = date,
    .value = close,
    .facet_ncol = 2,
    .interactive=FALSE,
    .title = "Anomaly Diagnostics Dow Jones",
    .anom_color ="#FB3029", 
    .max_anomalies = 0.07, 
    .alpha = 0.05
    )

```

### Investigate Anomaly of XOM (Exxon)
As we have seen previously, Exxon belongs to the energy industry more specifically the **oil industry.** The question we will answer will be: **What events occurred that caused a large drop in the stock price?** Below we will see attached a time series of the **West Texas Intermediate (WTI)** to see if it has a similar behavior with the XOM stock. For those that dont know WTI is a benchmark for oil pricing in the markets.
<br>

**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Outlier #1:</span> Caused by economic growth and demand in the oil industry resulting in profit gains. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Outlier #2:</span> Caused by the financial crisis 2007-2008. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Outlier #3:</span> Caused by lower than expected results in the market (loss in profit) around 2010.</li>

</ul>

This can be investigated further, but what is important is to know that these are not common events in our time series.

<center>
![Source: US Energy Information Administration and Statista ](https://cdn.statcdn.com/Infographic/images/normal/21420.jpeg){height=200, width=500}
</center>



```{r xom_outlier_detection}
filtered_final_stock_tbl %>%
  filter(name == "XOM") %>% 
  plot_anomaly_diagnostics(
    .date = date,
    .value = close,
    .interactive=FALSE,
    .title = "Anomaly Diagnostics Exxon (XOM)",
    .anom_color ="#FB3029", 
    .max_anomalies = 0.05, 
    .alpha = 0.05
    )


```


# Statistical Methods

**Definition List:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Lags:</span> Lag is the time gap we have with our time series. Remember, Lag 1 is measuring the time series with itself so it will "always" have a correlation of 1.  </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Autocorrelation:</span> Autocorrelation or ACF, explains how a time series is similar to itself through the use of lags. By finding patterns, we will be able to find cyclical seasonality patterns which would further help us to use certain lags for forecasting since we will add this seasonality patterns to our model. Autocorrelation is comprised of both the **direct** and **indirect** relationships (unlinke PACF which is only direct.)  </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Partial Autocorrelation:</span> Partial Autocorrelation (PACF) is the same as autocorrelation however, the impact of lags from before are removed or in other words the relationship from previous lags are not taken in the calculation. Therefore, if we want to find the relationship between lag 1 and lag 4, the correlation between these two lags will be direct and will not be affected by the correlations of lag 2 and lag 3.</li>

</ul>


Sources: 
<ul>
<li>
[A Gentle Introduction to Autocorrelation and Partial Autocorrelation](https://machinelearningmastery.com/gentle-introduction-autocorrelation-partial-autocorrelation/) </li>
</ul>



**Example of lag:**
![Lag Image](https://www.business-science.io/assets/lag-explanation.PNG)

Source: Picture taken from BusinessScience


### Autocorrelation (ACF)


```{r ACF}


filtered_final_stock_tbl %>%
    group_by(name) %>%
  summarise_by_time(
    .date_var = date,
    .value = mean(close, na.rm = TRUE),
    .by="month"
  ) %>% 
  tk_acf_diagnostics(
    .date_var = date,
    .value = log1p(.value)
  ) %>% 
      ggplot(aes(x = lag, y = ACF, color = name, group = name)) +
    # Add horizontal line a y=0
    geom_hline(yintercept = 0) +
    # Plot autocorrelations
    geom_point(size = 2) +
    geom_segment(aes(xend = lag, yend = 0), size = 1) +
    # Add cutoffs
    geom_line(aes(y = .white_noise_upper), color = "black", linetype = 2) +
    geom_line(aes(y = .white_noise_lower), color = "black", linetype = 2) +
    # Add facets
    facet_wrap(~ name, ncol = 3) +
    # Aesthetics
    expand_limits(y = c(-1, 1)) +
    scale_color_stata() +
    theme_calc() +
    theme(
        legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)
    ) + labs(
      title = "AutoCorrelation (ACF)",
      subtitle = "Dow Jones 30 Index"
    )





```


### Partial Auto Correlation (PACF)

```{r PACF}
filtered_final_stock_tbl %>%
    group_by(name) %>%
  summarise_by_time(
    .date_var = date,
    .value = mean(close, na.rm = TRUE),
    .by="month"
  ) %>% 
  tk_acf_diagnostics(
    .date_var = date,
    .value = log1p(.value)
  ) %>% 
      ggplot(aes(x = lag, y = PACF, color = name, group = name)) +
    # Add horizontal line a y=0
    geom_hline(yintercept = 0) +
    # Plot autocorrelations
    geom_point(size = 2) +
    geom_segment(aes(xend = lag, yend = 0), size = 1) +
    # Add cutoffs
    geom_line(aes(y = .white_noise_upper), color = "black", linetype = 2) +
    geom_line(aes(y = .white_noise_lower), color = "black", linetype = 2) +
    # Add facets
    facet_wrap(~ name, ncol = 3) +
    # Aesthetics
    expand_limits(y = c(-1, 1)) +
    scale_color_stata() +
    theme_calc() +
    theme(
        legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)
    ) + labs(
      title = "Partial AutoCorrelation (PACF)",
      subtitle = "Dow Jones 30 Index"
    )


```


### Cross Correlation (CCF) 
The first time I heard about the concept "cross correlation" was at one of my first jobs where I had to find the correlation of two time series to see if there were some "similarities" between the two. If the value of one time series goes up will this have an effect on the other time series at different lags. Will one time series have some sort of effect on the other time series? In our example imagine we would like to diversify in the stock market? If we know that there is a direct relationship between two stocks and you would like to reduce the risk you will most likely no invest in the those stocks at the same time. Since you know you will be negatively impacted when the stock price declines.

<br>

In this case we will see if there is a cross correlation to prove the point that this might help us diversify by doing an analysis like this one.

<br>



```{r ccf_tbl}
tech_stocks_tbl <- filtered_final_stock_tbl %>% 
  filter(sector == "Technology") %>% 
  select(date, name, close) %>% 
  pivot_wider(names_from = name, values_from = close) %>% 
  summarise_by_time(
    .date_var = date, 
    .by = "month", 
    across(AAPL:GOOGL, .fns = mean)
  )

tech_stocks_tbl %>% 
  tk_acf_diagnostics(
    date,
    AAPL,
    .ccf_vars = GOOGL
  ) %>% select(lag, CCF_GOOGL) %>% slice(1:10) %>% 
  gt() %>% 
  data_color(
    columns = vars(CCF_GOOGL),
    colors = scales::col_numeric(
      palette = c("#ffffff", "#f2fbd2", "#FA6047", "#F25555", "#FA1B1B"), 
      domain = NULL
    ))




```


**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">CCF on AAPL Close Price:</span> The closing price of AAPL is the target variable and the closing price of GOOGL is the independent variable. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">High correlation at Lag 0:</span> This indicates that when the closing price of AAPL is high or increasing this has a positive effect on the closing price of GOOGL  **On that same day or at LAG 0!** </li>
</ul>




```{r ccf_plot}

# Plot
tech_stocks_tbl %>% 
  plot_acf_diagnostics(
    date,
    AAPL,
    .ccf_vars = GOOGL,
    .show_ccf_vars_only = TRUE,
    .interactive=FALSE, 
    .line_color = "black",
    .point_color =palette_light()[[2]],
    .line_size = 1.5,
    .title = "Cross Correlation of Technology Stocks"
  ) 

```



## Simple Moving Averages
Moving averages help us smooth the time series and helps us to better understand where the trend is heading. Believe it or not, moving averages is used a lot for forecasting although, it is not the most optimal technique to do so especially since it does not handle that well the impact of outliers. Moreover, moving averages helps us detect as well seasonality in our time series.

**Most Common Moving Average in the Stock Market:**
<ul>
<li>15 days MA </li>
<li>30 days MA </li>
<li>100 days MA </li>
<li>200 days MA </li>
</ul>

<br>

**Note:** Notice how the higher the moving average the smoother the line. Usually, we use moving averages to detect trends in our time series data.


```{r}

gs_ma_sample <- filtered_final_stock_tbl %>%  
  select(date, close, name) %>% filter(name == "GS") %>% 
  filter_by_time(.date_var = date, .start_date = "2015", .end_date = "2017") %>% 
  mutate(
    adjusted_15_mm_close = slidify_vec(
        .x      = close,
        .period = 15,
        .f      = mean,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_30_mm_close = slidify_vec(
        .x      = close,
        .period = 30,
        .f      = mean,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_100_mm_close = slidify_vec(
        .x      = close,
        .period = 100,
        .f      = mean,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_300_mm_close = slidify_vec(
        .x      = close,
        .period = 300,
        .f      = mean,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE)
    ) %>% 
  pivot_longer(contains("close"), names_repair = "unique") %>% 
  rename(
    name = name...2,
    metric = name...3
  ) 


gs_ma_sample %>% 
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=metric), size=1) + 
  theme_calc() + theme(legend.position = "bottom", plot.title = element_text(hjust=0.5)) + 
  guides(color = guide_legend(nrow=2, byrow=TRUE)) + 
  labs(
    title = "Moving Average (MA) as a Metric",
    subtitle = str_glue("GS Stock 2015 - 2017 "),
    y = "Closing Price") + scale_color_stata() + 
  scale_x_date(expand = c(0,0))


```




**Note:** In this case I used a "Rolling" Median since I want to avoid the effect of outliers. Moving average are more prone to be affected by outliers! Nevertheless, you can use moving average by changing the function from median to mean.



```{r ma, fig.height=5}

mm_final_tbl <- filtered_final_stock_tbl %>%  
  select(date, close, name) %>%
  mutate(
    adjusted_15_mm_close = slidify_vec(
        .x      = close,
        .period = 15,
        .f      = median,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_30_mm_close = slidify_vec(
        .x      = close,
        .period = 30,
        .f      = median,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_100_mm_close = slidify_vec(
        .x      = close,
        .period = 100,
        .f      = median,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE),
    adjusted_300_mm_close = slidify_vec(
        .x      = close,
        .period = 300,
        .f      = median,
        na.rm   = TRUE,
        .align  = "center",
        .partial = TRUE)
    ) %>% 
  pivot_longer(contains("close"), names_repair = "unique") %>% 
  rename(
    name = name...2,
    metric = name...3
  ) 


# Visualization

mm_final_tbl %>% 
  ggplot(aes(x=date, y=value, color=metric)) + geom_line(size=1, alpha=0.8) + facet_wrap(~name, scales = "free_y") + theme_calc() + scale_color_stata() +
  labs(
    title = "Moving Medians",
    subtitle = "Dow Jones 30",
    y = "price"
  ) + theme(legend.position = "bottom", plot.title = element_text(hjust=0.5),
            legend.text = element_text(size=10)) + 
  guides(color = guide_legend(nrow=2, byrow=TRUE)) 


```
                                 
                                 
## Moving Average in Forecasting

The goal of this section is to <span style="background:#fed56f; font-weight:bold; color:black"> showcase </a> in which scenarios moving average could be useful and in which ones could it be that they are not that useful.

**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Easy to understand: </span> Moving averages are easy to understand thus not many technicalities are needed to understand this concept. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> Expected Volatility: </span> When there is an expected volatility, you run into the risk of having large residuals through the use of moving averages. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> Low volatility: </span> Moving averages are useful during time frames of low volatility as it is able to capture the short-term trend. </li>
</ul>


```{r}
# Gs data from 2009 - 2012 (We want to capture some volatility)
# So that we can prove the point that moving average can cause some problems
# In forecasting


gs_filtered_data <- filtered_final_stock_tbl %>% 
  filter(name == "GS") %>% 
  filter_by_time(
    .start_date = "2009",
    .end_date = "2012"
  ) %>% 
  select(date, name, close)




ma_60day_forecasting <- gs_filtered_data %>% 
  mutate(
    mavg_60_days = slidify_vec(close, .f = ~ mean(.x, na.rm = TRUE), .period = 60, .align = "right")) %>% 
  bind_rows(
    future_frame(., .length_out = 60)
  ) %>% 
  # fill function: replace NA with our moving averages
  fill(
    mavg_60_days,
    .direction = "down"
  )






# Forecasting plot

ma_60day_forecasting %>% pivot_longer(close:mavg_60_days,names_repair="unique") %>%
  rename(
    "type" = "name...3"
  ) %>% 
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=type), size=1) +
  theme_calc() + scale_color_stata() +
  labs(
    title = "60 day Moving Average",
    subtitle = "MA as a Forecasting Technique"
  ) + theme(plot.title = element_text(hjust=0.5))




```
                                 
                                 
                                 
                                 
## Residuals of Forecasting with Moving Average

In this scenario we can see that there was an **uplift** that the moving average was not able to capture. Therefore, **moving average are good during times of stability since it is able to capture the trend.** However, during times of **volatility** you will miss a lot on uplift of stock prices or you will not able to hedge against downward trends in stock prices!. Therefore, it is important to explore other interesting techniques.


```{r}
actual_60days <- filtered_final_stock_tbl %>% 
  filter(name == "GS") %>% 
  filter_by_time(
    .start_date = "2013",
    .end_date = "2013-03-01"
  ) %>% 
  select(date, name, close)



plot_series <- ma_60day_forecasting %>% 
  filter_by_time(
    .start_date = "2013-01-02", .end_date = "2013-03-01"
  ) %>% 
  left_join(actual_60days, by="date") %>% 
  select(date, mavg_60_days, close.y) %>% 
  rename(
    "actual_close_price" = "close.y"
  ) %>% 
  pivot_longer(mavg_60_days:actual_close_price) %>% 
  # Remove weekends from moving average
  drop_na() %>% 
  ggplot(aes(x=date, value)) + geom_line(aes(color=name), size=1) + geom_point(aes(color=name), size=2) + theme_calc() + scale_color_stata() + 
  labs(
    title = "Residuals from 60 day Moving average", 
    subtitle = "GS stock Moving Average"
  ) + theme(legend.position = "bottom") + guides(color = guide_legend(nrow=1, byrow=TRUE))


plot_series

```


## Rolling Correlation
Another way of finding a relationship between two time series is through the use of **Rolling Correlations.** What we do here is find a correlation at different points in time between two time series and determine if the relationship between the both is significant.

**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">APPL vs GOOGL:</span> Is the relationship between the two technological stocks significant enough? </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> Time lag of 1 year:</span> A time lag of one year will be used in our monthly time series (which we created). Do the two stocks tend to move together? </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">End result:</span> In most cases we see a rolling correlation > than 0.5! Which is significant enough and which gives evidence that these two stocks move together. </li>

</ul>

<br>

```{r rolling_correlation}
# We will ise the slidify function
# Turns function into a rolling / sliding function


# We will get the monthly average for each stock 
# And find if there is a correlation
wider_format_stocks_tbl <- filtered_final_stock_tbl %>% 
  filter(name %in% c("AAPL", "GOOGL")) %>% 
  select(date, close, name) %>%
  mutate(
    date = floor_date(date, unit = "month")
  ) %>% 
  group_by(date, name) %>%
  summarise(
    close_avg = mean(close)
  ) %>% 
  ungroup() %>% 
  pivot_wider(names_from = name, values_from = close_avg)


rolling_cor <- slidify(
  .f = ~ cor(.x, .y, use = "pairwise.complete.obs"), 
  .period = 12,
  .align  = "right",
  .partial = FALSE
)



wider_format_stocks_tbl %>% 
  mutate(
    rolling_cor_close_price = rolling_cor(AAPL, GOOGL)
  ) %>% 
  ggplot(aes(x=date, y=rolling_cor_close_price)) + geom_line(size=1, color="#045884") + 
  theme_calc() + scale_color_stata() + geom_smooth(method = "loess", color="red") + 
   scale_x_date(expand = c(0,0)) + 
  labs(
    title = "Rolling Correlation in the Technology Sector",
    subtitle = "AAPL vs GOOGL",
    y = "Rolling Correlation",
    x = "Date"
  ) + theme(plot.title = element_text(hjust=0.5)) + 
  scale_x_date(expand = c(0,0))




```
                            
                                 
## Linear Regression and the use of Log Transfomrations

The main reason why we use log transformations in time series analysis is to reduce the impact of extensive outliers therefore, stabilizing the variance across the time series. Log transformations are required in models like **Linear Regression** in which an outlier can cause a significant impact on the adjusted squared error. Although, in this case we dont have "significant" outliers log transformations can help you mitigate the impact of such. 


**Log Transformation Formula:**

$\large Y = log_b^x$ <br>
$\large b^y = x$ <br>


**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Log1p function: </span> This function is the same as a log transformation + 1. We use this to mitigate the impact of values which are zero. (This is not the case)</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Feature Importance: </span> Notice how most of our months are giving significant importance to reduce our adjusted R-squared. Meaning that the month has a significant impact on determining where the closing price of a stock is heading. This will lead to the question is there some sort of seasonality? </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Getting from log values to actual values?</span> To transform back to our actual values we use the **expm1** function which will allows us to get the orginial values back. We want to definitely know this whenever we are forecasting!  </li>

</ul>


```{r linear_model_log}
# We will pick GS as it is one of the ones with the highest volatility

# GS linear regression model using log transformations
log_gs_lm_plot <- filtered_final_stock_tbl %>% 
  filter(name == "GS") %>% 
  filter_by_time(
    .start_date = "2016-01-01",
    .end_date = "2017-01-01"
  ) %>% 
  plot_time_series_regression(
    .date_var = date,
    .formula = log1p(close) ~ as.numeric(date) + 
      wday(date, label = TRUE) + 
      month(date, label = TRUE),
    .interactive=FALSE,
    .show_summary = TRUE,
    .title = "Log transformations in Linear Regression Models"
  )

log_gs_lm_plot


```


**Transforming back to the original values using expm1 function:**

```{r linear_model_without}

log_transformed_back_plot <- filtered_final_stock_tbl %>% 
  filter(name == "GS") %>% 
  filter_by_time(
    .start_date = "2016-01-01",
    .end_date = "2017-01-01"
  ) %>% 
  plot_time_series_regression(
    .date_var = date,
    .formula = expm1(log1p(close)) ~ as.numeric(date) + 
      wday(date, label = TRUE) + 
      month(date, label = TRUE),
    .interactive=FALSE,
    .show_summary = TRUE,
    .title = "Transforming to actual close price using expm1 function"
  )
                                 
log_transformed_back_plot

```
       
                                 
## Splitting Time Series for Forecasting:

When we talk about implementing machine learning models we usually talk about splitting the dataset into:<br>
<ul>
<li>Training sets</li>
<li> Validation sets </li>
<li>Testing Sets </li>
</ul>

You can compose the training sets of sixty percent of the dataset twenty percent validating and twenty percent the testing sets.However, this distribution should rely on your own logical judgement. Coming to our time series topic, this is also the case for implementing machine learning models in a time series. One of the first steps you will have to do is splitting your time series data. Lets look at how we do that with an example: I will split the time series into a training and testing set and you will see it visually.                    
                                 
       

                                 
                                 
```{r splitted_frame}
# Test is 25% of our data
split_df <- filtered_final_stock_tbl %>%
  filter(name == "GS") %>% 
  time_series_split(
    date_var = date,
    assess = "3 year",
    cumulative = TRUE
  )



splitted_data <- split_df %>% 
  tk_time_series_cv_plan() 


splitted_data %>% 
  ggplot() + geom_line(aes(x=date, y=close, color=.key), size=1) +
  theme_calc() + scale_color_stata() +
  geom_rect(data=data.frame(xmin=as.Date(c("2015-01-02")),
                               xmax=as.Date(c("2017-12-29")),
                               ymin=-Inf,
                               ymax=Inf),
               aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
               fill=palette_light()[2],alpha=0.3) + 
  geom_label(
    label = "Testing Set",
    vjust = 0.5,
    aes(x=as.Date(c("2016-07-02")),
        y = 100)) + 
       geom_rect(data=data.frame(xmin=as.Date(c("2006-01-03")),
                               xmax=as.Date(c("2014-12-31")),
                               ymin=-Inf,
                               ymax=Inf),
               aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
               fill=palette_light()[3],alpha=0.3) + scale_x_date(expand = c(0,0)) + 
    geom_label(
    label = "Training Set",
    vjust = 0.5,
    aes(x=as.Date(c("2012-07-02")),
        y = 220)) + 
  labs(
    title = "Splitting Time Series into Training and Testing Sets",
    subtitle = "Dow Jones 30"
  ) + theme(plot.title = element_text(hjust=0.5), legend.position = "bottom") + 
  guides(color = guide_legend(nrow=1, byrow=TRUE)) + 
  scale_y_continuous(labels = scales::dollar)


```
                                 

## Autoregressive "Integrated" Moving Average (ARIMA) 

**Note:** Still working on the explanation                                 
                                 
Most of us have hear the concept of <span style="background:#fed56f; font-weight:bold; color:black">Autoregressive Integrated Moving Average (ARIMA).</a> Before understanding the concept of ARIMA we should answer the following questions:

<ul>
<li>**What is stationarity?** There is a concept called <span style="background:#fed56f; font-weight:bold; color:black">"Stationarity"</span>/ which basically means the difference of t - t1. For example, in this case the closing price of in Jan 1st 2016 - the closing price Jan 2nd 2016 and so on. </li>
<li>**What is the effect of applying stationarity to a dataset?** Stationary datasets creates a <span style="background:#fed56f; font-weight:bold; color:black">constant mean and variance </span>  which reduces the impact of trend and seasonality which affect the time series at different points in time. The variance and mean should be constant meaning the time series should look basically the same at any point in time. </li>
<li>**Do we need to implement differencing when using ARIMA:** The answer to that question is no, since ARIMA does differencing automatically and this is what the "I" in ARIMA does it implements differencing to make the time series stationary and avoid the impact of trend and seasonality. </li>
</ul>



**What does it mean when we have a flat line in our forecast with ARIMA? (As shown below)**

![flat_line_forecast](https://blogs.sas.com/content/sascom/files/2019/07/Figure-1-Simple-ES-model2.png)

Source: **Blog SaS**

When we have a flat line in our forecast model it means that the model is unable to capture neither a trend nor seasonality. This is due to that the model is unable to capture the different dynamics within our time series. Even though, it does not look as nice as we would want the forecast to be (moving up or down), actually this type of forecast could give a much better results rather than just adding random noise to our forecast.

<br>
**Are there ways to improve the output of the forecast?**
Definitely, there are transformations and feature engineering steps that will better help your model capture any unforeseen trend or seasonality in your time series. I plan to talk more in-depth about ARIMA and other types of transformations and feature engineering processes in another notebook since I would like to keep this notebook as simple as possible for the moment. 
                                 
# Conclusion
I hope this notebook gave you a brief overview of the things we will see in this **time series session**. If you enjoyed going through the notebook I am preparing another one which will help the Kaggle community start deploying time series models for forecasting. If you are interested you can visit [Time Series || Feature Engineering Concepts](https://www.kaggle.com/janiobachmann/time-series-feature-engineering-concepts)