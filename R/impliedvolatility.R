---
# title: ''
# author: ''
# date: '`r Sys.Date()`'
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

# Executive Summary

Welcome to the second session of the time series analysis! I hope that in this series of the notebooks rmarkdown works better compared to the first one. Nevertheless, if you havent seen the first series of the session I will definitely recommend for you to check the following notebook which gives a hands on understanding of how we approach time series problems. If you are interested please go to [Time Series Analysis || Introduction to the Topic](https://www.kaggle.com/janiobachmann/time-series-analysis-introduction-to-the-topic). <br><br>

**Topics that will be discussed in this notebook:**
<ul>
<li>**Data Exploration through Feature Engineering**  </li>
<li>**Interpreting ACF and PACF** </li>
<li>**Understanding BoxCox Transformations** </li>
<li>**Implementation of the Prophet Library**  </li>
</ul>

<br><br>

<span style="background:#fed56f; font-weight:bold; color:black">One important note: </span> If you really enjoyed going through this notebook, please upvote and provide a constructive criticism (in case you have one), this will help me understand how this notebook could be improved for the Kaggle community.





# Business Case
The dataset consists of the following two columns: <br>
<ul>
<li>**Time:** This columns shows the specific date and time the event occurred. </li>
<li>**Ads:** The number of ads that appeared at a specific point in time. </li>
</ul>

The goal in this notebook will be to come up with an accuracte forecast to find out the number of ads that will appear in time. We will use the **concept of feature engineering and transformations to 
come up with an accurate forecast.**



# Loading Libraries

In this notebook we will use the following libraries to deal with time series.

<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black"> timetk: </span> Library to deal with timeseries data especially for data wrangling and visualization purposes. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">modeltime: </span> This will mainly due to implement forecast for our time series data. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Prophet: </span> We will use this library for forecasting as well, Prophet was developed by developers from Facebook to easily produce accurate forecast when dealing with time series data. </li>
</ul>



```{r loading_libraries}
# Install modeltime
install.packages("modeltime")
install.packages("tidymodels")
install.packages("gghalves")
install.packages("workflows")

# Data Wrangling
library(tidyverse)
library(timetk)
library(lubridate)
library(tidyquant)


# Visualization
library(ggthemes)
library(gghalves)
library(cowplot)

# Modeling
library(modeltime)
library(prophet)
library(tidymodels)

# Pipeline
library(workflows)

```


# Introduction

## Visualizing Time Series
We can clearly see some seasonality patterns at a first glimpse of just looking at our time series visualizations. However, we will confirm this later in the notebooks 
through processes already explained in the Part 1 of this series. However, we will revisit some of those concepts in this time series notebook.




```{r loading_tbl}

df <- read.csv("../input/mlcourse/ads.csv")


hourly_tbl <- df %>% 
  set_names(names(.) %>% str_to_lower()) %>% 
  mutate(
    time = ymd_hms(time)
  )

hourly_tbl %>% 
  ggplot(aes(x=time, y=ads)) + geom_line(size=1, color="#4E79A7") + geom_point(size=0.5, color="#2C3E50") + theme_bw() + 
  scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
  labs(
    title = "Number of ads across time"
  ) + theme(plot.title = element_text(hjust=0.5, face="bold")) 


```
                     
## Seasonality Patterns
The concept of finding out <span style="background:#fed56f; font-weight:bold; color:black"> seasonality patterns </span> is really important if we want to have a better grasp of 
                     what the time series is telling us. In this section we will split our time series into hours and weekday and see how the distribution of 
                     the time series behaves. <br><br>


**Summary:**
<ul>
<li>**Highest distribution of ads by hour:** We see that the highest distribution of ads occurrs at **12, 18 and 19.** </li>
<li>**Lowest distribution of ads by hour:** The lowest distribution of ads occur not surprisingly during the **early morning hours.** </li>
<li>**Highest distribution of ads by Weekday:** We see that the highest distribution of ads occurrs during Sundays followed by Saturdays. </li>
<li>**Lowest distribution of ads by Weekday:** We see that the lowest distribution of ads occurs during the days of **Mondays and Thursdays.** Although, there is not that much variation during the business days.</li>
</ul>

<br><br>

This seasonal diagnostics plot comes from the **timetk** package. I will definitely recommend this if you are interested in dealing with time series data.                 
                     
                     
```{r seasonality_patterns}

hourly_tbl %>% 
  plot_seasonal_diagnostics(
    .date_var = time,
    .value = ads,
    .interactive = FALSE,
    .geom_color = "#4E79A7"
  )
                     
```

                     
                     
## Raincloud Plots

**What are raincloud plots?** <br>

<span style="background:#fed56f; font-weight:bold; color:black"> Raincloud Plots </span> is a way to dig in deeper into the distribution of our dataset. We use a combination of the following: <br>

<ul>
<li>**Boxplot** </li>
<li>**Histogram** </li>
<li>**Violin Plot** </li>
</ul>

<img src="https://miro.medium.com/max/700/1*2c21SkzJMf3frPXPAR_gZA.png">


<br>

**Interpreting a boxplot:** <br>
- We use it in descriptive statistics to understand the distribution of our observations. Boxplots are composed of the following: <br>
<ul>
<li>**Lower Fence:** Q1 - 1.5*IQR</li>
<li>**First Quartile (25th Percentile):** The middle value between the smallest number and the middle value (median). </li>
<li>**Median:** The middle value in our series </li>
<li>**Third Quartile (75th Percentile):** The middle number between the middle value (median) and the highest number </li>
<li>**Interquartile Range (IQR):** Values between the First Quartile and the Third Quartile. </li>
<li>**Upper Fence:** Q3 + 1.5*IQR</li>
<li>**Outliers:** Any observation that falls outside the upper fence or lower fence.</li>
</ul> <br>

The **Histogram** and the **Violin Plot** just shows the overall distributions of the different observations in our dataset.

```{r combination_plots}
weekday_pal <- c("#DBB165", "#DEB18B", "#2E604A", "#27223C", "#D1362F", "#7496D2",
                 "#CECD7B")



hourly_tbl %>% 
  mutate(
    weekday = WEEKDAY(time, label = TRUE, abbr = FALSE), 
    weekday = weekday %>% as_factor() 
  ) %>% 
  ggplot(aes(x=weekday, y=ads)) +
  geom_jitter(aes(color=weekday),
              alpha = 0.5,
              size=0.5,
              show.legend = FALSE) + 
  geom_half_violin(aes(fill=weekday),
                   side = "l",
                   alpha = 0.45,
                   show.legend = FALSE,
                   trim = FALSE) +
  geom_half_boxplot(aes(fill = weekday),
                    side = "r",
                    outlier.size = 3,
                    outlier.color = "red",
                    width = 0.4, 
                    alpha = 0.45,
                    show.legend = FALSE) + 
  stat_summary(fun = mean, geom="line")  +
  theme_bw() + 
  labs(
    title = "Raincloud Plots",
    subtitle = "A more descriptive way of distributions"
  ) + scale_color_manual(values = weekday_pal) + 
  scale_fill_manual(values = weekday_pal) 


```
                     
## AutoCorrelation and Partial Autocorrelation

Going back to this topic as a refresher of the first part of the time series fresher I would like to discuss a bit more in detail the definitions of both **Auto Correlation (ACF)** and **Partial Auto Correlation (PACF)**. Forst, let me say that the reason why I emphasize this is because lags at different points in time could be used as features to improve the predictive accuracy of our models. Before getting into this topic we must understand the following: **It is possible that past values have an influence in the behavior of future values in a time series. ** When this occurs, we say that the current value has a <span style="background:#fed56f; font-weight:bold; color:black"> correlation </span> with past values in the time series.
<br><br>


**Definitions:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Autocorrelation:</span> Autocorrelation is just the correlation between current value and past values. There is an indirect effect in autocorrelation when we find the correlation of lag</li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Partial Autocorrelation (PACF):</span> In shorter terms partial autocorrelation removes any effect of lags that are in between the lags you are evaluating. In other words, at lag k it is the correlation that results after removing the effect of any correlation at a different lags. For instance, if we want to find the correlation of lag k and lag k-3 we remove the effect of lag k-1 and lag k-2 in order to find the correlation of the current value and lag k-3. </li>


</ul>


**Formula:**<br>

$\LARGE r_{k} = \frac{\sum_{i=1}^{N-k}(Y_{i} - \bar{Y})(Y_{i+k} - 
         \bar{Y})} {\sum_{i=1}^{N}(Y_{i} - \bar{Y})^{2} }$
         
<br>        
**Where:**<br>
X = time <br>
Y = Tagret Variable (In this case number of ads) <br>
r = Correlation <br>
k = Lag (Can be lag 1,2,3...)
<br><br>


**Interpretation of ACF and PACF:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Understanding our dataset:</span> Remember, that our dataset is in hours so each lag is a representation hours. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Correlation:</span> We see that there is a positive correlation every 24 hours approximately in the ACF and PACF plot. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">What does this mean?</span> Meaning that at a any given day in the next 24 hours we will see at a specific point in time a similar movement in the number of ads as opposed to that same time in the previous day and hence, there is a positive correlation at every 24 lags. </li>
</ul>

```{r acf_pacf}

color_pal <- c("#5C5C5C", "#EA3B46")


hourly_tbl %>% 
  tk_acf_diagnostics(
    .date_var = time,
    .value = ads
  ) %>% 
  pivot_longer(cols = c("ACF", "PACF")) %>% 
  ggplot(aes(x=lag, y=value, color=name)) + geom_line(size=1) + geom_point(size=0.5) +
  facet_wrap(~name) + theme_bw() + scale_color_manual(values = color_pal) +
  theme(legend.position = "bottom", strip.background =element_rect(fill="#BDBDBD")) + 
  labs(
    title = "Autocorrelation and Partial Auto Correlation",
    color = "Metric"
  )

```




# Feature Engineering

In this section we will start implementing the concept of <span style="background:#fed56f; font-weight:bold; color:black"> feature engineering. </span> I will be using the **timetk** package to extract valuable feature which could enhance the predictability of our model later in the notebook. Timetk is a powerful package that gives you leverage into analyzing time series datasets. I will explain the main features taken out from the feature engineering process we just implemented in order to get associated with the dataset. <br><br>

                     
## Extracting Features

**Summary of the feature engineering process:** 
<ul>
<li>**index.num:** Number of seconds passed since 1970 to the current timestamp. </li>
<li>**Diff:** Number of seconds passed between timestamps. </li>
<li>**half:** Which half of the semester during the year (1 or 2) </li>
<li>**quarter:** Quarter of the year</li>
<li>**month:** Month of the year. </li>
<li>**day:** Day of the moth. </li>
<li>**hour:** Hour of the day </li>
<li>**hour12: ** hour from 0-12 (it restarts in the afternoon) instead of 0-24</li>
<li>**weekday:** Day of the week </li>
<li>**mday:** Day of the month </li>
<li>**qday: ** Day of the quarter </li>
<li>**yday:** Day of the year </li>
</ul>

<br>
**Note:** The features that will have the most significance are most probably the hour and the weekday but we will find these in the upcoming updates.

```{r}

# Feature engineering with one line of code
prepared_hourly_tbl <- hourly_tbl %>% 
  tk_augment_timeseries_signature() %>% 
  mutate(
    ads_transformed = log_interval_vec(ads, limit_lower = 0, offset = 1),
    ads_transformed = standardize_vec(ads_transformed)
  ) %>% 
  select(time, ads, ads_transformed, everything())


prepared_hourly_tbl %>% 
  glimpse()


```

        
## Linear and Non-Linear Regression
Now we will see what impact some of those new features that we extracted from the time column have on a linear model. Before showing you the impact of those features lets just go over the main concepts of <span style="background:#fed56f; font-weight:bold; color:black"> Linear Regression </span>



**Concept of Linear Regression:**
The concept of linear regression can be confusing especially for the individuals getting into the machine learning world. When I think about the concept of linear regression I usually think as of "the best fitted line in a set of observations." Furthermore, a linear model can have "predictors" or a set of features that can help the model reduce the standard of errors.
<br>
<img src="https://i2.wp.com/contentsimplicity.com/wp-content/uploads/2019/05/6e761-1uc_kzaudsalw8mq41oi9hg.png?w=1080&ssl=1" height=400px> 

**Metrics to know of Linear Regression:**
<ul>
<li>**Mean Squared Error (MSE):** The average of the squared differenced between the predicted values and actual values. </li>
<li>**Mean Absolute Error (MAE):** The absolute average between actual values and predicted values.  </li>
<li>**Root Mean Squared Error (RMSE):** This is the squared root of the average of the squared difference of the predicted and actual value. </li>
<li>**Adjusted R Squared:** Measures the variance explained only by independent variables that has a direct effect on dependent variables.  </li>
<li>**Residuals:** Think about it as the "left over" when substracting the actual values - predicted values. </li>
</ul>



**Formulas:**<br>
**1) Mean Squared Error (MSE)**<br>
\begin{align}
\LARGE rmse = \sqrt{(\frac{1}{n})\sum_{i=1}^{n}(y_{i} - x_{i})^{2}}
\end{align}
**2) Mean Absolute Error (MAE)**<br>
\begin{align}
\LARGE \displaystyle\frac{1}{n}\sum_{t=1}^{n}|e_t|
\end{align}


**3) Root Mean Squared Error (RMSE)** <br>
\begin{align}
\LARGE \displaystyle\sqrt{\frac{1}{n}\sum_{t=1}^{n}e_t^2}
\end{align}

**4) Adjusted R Squared:**
\begin{align}
\LARGE R^2_{adj} = 1 - (1 - R^2) \frac{n-1}{n-p-1}
\end{align}

**5) Residuals**<br>
\begin{align}
\LARGE r = y - \hat{y}
\end{align}


<br><br>

**Implementation of Linear Regression in Time Series:**
Although, using linear regression in time series is not the best approach we can somehow evaluate the importance of the features we have extracted. <br><br>


**Summary:**
<ul>
<li>**Linear Regression Model based on time:** As you can see only adding a linear regression model based on time itself is not that useful. We can see that there is only a straight line that is not able to capture the movement of our time series. We can see that we have an adjusted square of -0.002508. </li>
<li>**Using features from Feature Engineering:** However, we see that our linear model improves if we include the feature of **day**, **weekday** and **hour** in our linear formula. We have an adjusted R Squared of 0.2062. A big improvement with just having one flat line in our time series. </li>
<li>**So now what? Is this good enough?** Of course not, this was mainly to show a bit of the power of feature engineering. We will explore further in the notebook other transformation techniques to improve accuracy when forecasting future values. </li>
<li>**So why can Feature engineering help us?** As we saw below, the features we extracted from the time column, help the linear regression model capture the movement of our series and this is what will help our models further in the notebook improve accuracy when it comes to forecasting. </li>
</ul>

```{r linear_model}
# Plot 1

p1 <- prepared_hourly_tbl %>% 
  plot_time_series_regression(
    time,
    .formula = ads_transformed ~ time,
    .interactive=FALSE,
    .show_summary=TRUE,
    .title = "Linear Model Without Implementing Feature Engineering",
    .legend_show = FALSE,
    .line_color = "#D1362F",
    .smooth_color = "#EA3B46",
    .line_size = 1
    )


# Plot 2

seasonality_formula <- as.formula(
  ads_transformed ~ 
    splines::ns(index.num) +
  + day + wday.lbl + hour
)

p2 <- prepared_hourly_tbl %>% 
  plot_time_series_regression(
    time,
    .formula = seasonality_formula,
    .interactive=FALSE,
    .show_summary=TRUE,
    .title = "Linear Model With Feature Engineering",
    .legend_show = FALSE,
    .line_color = "#D1362F", 
    .smooth_color = "#EA3B46",
    .line_size = 1
    )


plot_grid(p1, p2, nrow=2)

```                    
                     





# Data Preparation


## Box Cox Transformations

**Why BoxCox Transformations?** <br>
Briefly, boxcox transformations tries to transform our data into a normal distribution or at least close to a normal distribution. A lot of models have a huge tendency to perform better under normal distributions although there are models that can perfectly perform without a normal distribution. Why some models perform better under a normal distribution? Well, by having a normal distribution we avoid noise in our data which allows our model to perform much better. <br><br>

**BoxCox Transformation Formula:** <br>


<img src="https://miro.medium.com/max/323/1*6Y67MRMCbr5b7hLKeSMxzA.jpeg"><br>
**Where:**
<ul>
<li>$W =$ Transformed Variable </li>
<li>$Y =$ Target Variable (Number of Ads) </li>
<li> $T =$ Time Period 
<li>$lambda =$ Parameter chose </li>
</ul>

**Note:** lambda is important because it is the paramenter that will help us transform our time series to the original values after performing the transformations. **Moreover, lambda is important because the value picked in lambda is the most approximate value to a normal distribution.**

<br><br>

**My personal preference when it comes to transformations:**<br>

Personally, I prefer to use the log transformations since it is much easier to perform inversions with log. We normally use the log function in R or log1p in case you have values of 0s since logs dont perform well when we have values with zeros. When we use logs it is simple to make an inversion by just  using the **expm1** function in R to the transformed log values. 



```{r}
# We use lambda to transform back
lambda <- 0.91150846258978

ts_boxcox_ads_tbl <- hourly_tbl %>% 
  mutate(
    ads_box_cox = box_cox_vec(ads, lambda = "auto")
  )




ts_boxcox_ads_tbl %>% 
    ggplot(aes(x=time, y=ads_box_cox)) + geom_line(size=1, color="#5C5C5C") + geom_point(size=0.5, color="#5C5C5C") + theme_bw() + 
  scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
  labs(
    title = "Number of ads across time",
    subtitle = "Box Cox Transformation"
  ) + theme(plot.title = element_text(hjust=0.5, face="bold")) 


```


## Time Series Split
When fitting a model to a dataset usually we split the data into a training, validation and test set. To make it more visually appealing for the user I will split it into training (approx 80%) of our dataset and test set (approx 20%) of the dataset.
<br><br>

**How do we split the dataset in time series?**
- Different from other machine learning problems, time series has the <span style="background:#fed56f; font-weight:bold; color:black"> time component </span> which means that the splitting of the dataset has to keep the order of the time. If we would not keep the order of time then the model will be unable to detect any kind of trend in our dataset. For this reason, when splitting the data in time series problems it is important to keep the order of time series. How to do that? There are many useful functions that will help you achieve this, in this case we will use the **time_series_split()** function which comes from the timetk package. It makes it really easy to split the dataset into training and testing.




```{r}
ts_boxcox_ads_tbl <- ts_boxcox_ads_tbl %>% 
  select(time, ads_box_cox)

# 22% is the testing set
# Splitting dataframe
splitted_df <- time_series_split(ts_boxcox_ads_tbl, assess = "2 days", cumulative = TRUE)

new_colors_pal <- c("#27223C", "#D1362F")
# Extracing training and test sets
train_df <- training(splitted_df)
test_df <- testing(splitted_df)


splitted_df %>% 
  tk_time_series_cv_plan() %>% 
  ggplot(aes(x=time, y = ads_box_cox, color=.key)) + geom_line(size=1) + 
  scale_color_manual(values = new_colors_pal) + theme_bw() + 
  labs(
    title = "Time Series Split",
    subtitle = "Boxcox Value"
  ) +  geom_label(
    label = "Training Set",
    color = "#27223C",
    vjust = 0.5,
    aes(x=AS_DATETIME(c("2017-09-16 21:00:00")),
        y = 65000)) + 
  geom_label(
    label = "Testing Set",
    color = "#D1362F",
    vjust = 0.5,
    aes(x=AS_DATETIME(c("2017-09-20 21:00:00")),
        y = 62500)) +
  theme(legend.position = "none") + scale_x_datetime(expand = c(0,0)) + 
  geom_vline(xintercept = AS_DATETIME(c("2017-09-20 00:00:00")), lty="dashed")




```




# Forecasting with Prophet


## What is Prophet?

**What is Prophet:?** <br>
As described in the official website of Prophet <span style="background:#fed56f; font-weight:bold; color:black"> "Prophet is a procedure for forecasting time series data based on an additive model where non-linear trends are fit with yearly, weekly, and daily seasonality, plus holiday effects. It works best with time series that have strong seasonal effects and several seasons of historical data. Prophet is robust to missing data and shifts in the trend, and typically handles outliers well." </span> Prophet is an open source software desgined by Facebooks Core Data Science team. You can use it both in Python and R.  <br><br>


**Would Prophet work well in our time series?** <br>
Although our time series does not have an extensive historical data, it has a lot of seasonality (hours were we have a high number of ads and other hours where we dont. (Repetitive patterns occur.)) This could help the Prophet model perform well but we will see this in a second. 

**Summary:**
<ul>
<li>**Forecast on Testing Data:** Our forecast seems to capture most of the seasonality and trend of our time series. </li>
<li>**Metrics:** As described below we see that the metrics resembles what the prediction against the actual data show us. </li>
<li>**Forecasting for the next 5 days:** We see that the same seasonality patterns are kept but interesting enough we see a bit of a downward trend in our forecast as seen with the trendline. </li>
<li>**Forecasting with inverted Box Cox Transformation:** To invert the boxcox transformation we had in the previous section, we used lambda to invert to the previous numbers. Remember, we use lambda to approximate the distribution of the observations to a "normal distribution." </li>
</ul>


```{r}

prohet_fit <- prophet_reg() %>% 
  set_engine("prophet") %>% 
  fit(ads_box_cox ~ time, data = ts_boxcox_ads_tbl)


model_tbl <- modeltime_table(
  prohet_fit
)


calibration_tbl <- model_tbl %>% 
  modeltime_calibrate(
    new_data = test_df
  )



forecast_tbl <- calibration_tbl %>% 
  modeltime_forecast(actual_data = ts_boxcox_ads_tbl)


forecast_tbl %>% 
  rename(
    "time" = ".index",
    "value" = ".value"
  ) %>% 
  ggplot(aes(x=time, y=value, color=.key)) + geom_line(size=1) + geom_point(size=0.5) + theme_bw() + scale_color_manual(values=new_colors_pal) + 
  theme(legend.position = "bottom") + 
  labs(
    title = "Forecasting with Prophet",
    subtitle = "Number of Ads",
    y = "BoxCox Transform Value"
  ) + scale_x_datetime(expand = c(0,0)) 





```

## Accuracy Evaluation


```{r}

calibration_tbl %>% 
  modeltime_accuracy() %>% 
  pivot_longer(cols = mae:rsq) %>% 
  mutate(
    name = name %>% as_factor() %>% fct_reorder(value) %>% fct_rev()
  ) %>% 
  ggplot(aes(x=name, y=value, fill=name)) + geom_col(color="black") + 
  theme_bw() + scale_fill_tableau() + theme(legend.position = "bottom") + 
  geom_label(aes(label = round(value,2)), size=3, color="white") + 
  labs(
    title = "Metrics for evaluating Accuracy",
    subtitle = "Prophet Model with BoxCox Transformation"
  )

```

## Forecast with inverted Box Cox 


```{r}
# New color palette for the visualization
# new_color_pal <- c("#456355", "#B62A3D")
# We retrain the model on the actual data
refit_tbl <- calibration_tbl %>% 
  modeltime_refit(data = ts_boxcox_ads_tbl)

# inverting transformation
forecast_ads_tbl <- refit_tbl %>% 
  modeltime_forecast(h = "5 days", actual_data = ts_boxcox_ads_tbl)

forecast_ads_tbl <- forecast_ads_tbl %>% 
  mutate(.value = box_cox_inv_vec(.value, lambda = lambda),
         .conf_lo = box_cox_inv_vec(.conf_lo, lambda = lambda),
         .conf_hi = box_cox_inv_vec(.conf_hi, lambda = lambda))


forecast_ads_tbl %>% 
    rename(
    "time" = ".index",
    "value" = ".value"
  )  %>% 
    ggplot(aes(x=time, y=value, color=.key)) + geom_line(size=1) + 
  theme_bw() + scale_color_manual(values = new_colors_pal) + 
  labs(
    title = "Prophet Forecast for the next 5 days",
    subtitle = "Number of Ads (Boxcox Inverted)",
    y = "Number of Ads",
    caption = str_glue("Lambda: {lambda}")
  ) + 
  scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) + 
  theme(legend.position = "bottom") + geom_smooth(method = "loess", color = "#191919", lty="dashed") + scale_x_datetime(expand = c(0,0)) 



```
                     
# Fourier Series <br>
<img src = "https://d18l82el6cdm1i.cloudfront.net/uploads/RXlzIMQnAJ-trianglefourier.gif"> <br>


## Introduction to Fourier Series 
Now we will talk about an interesting topic that could help improve our model predictability. **Fourier Series** are a great day to deal with multiple seasonality (which surprisingly enough this is the case). Before going into what is Fourier Series, lets revisit our data with what we know so far.

**Summary of our Dataset:** <br>
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black"> What did the lags tell us? </span> As we have seen in the ACF and PACF plots, there is a strong correlation every 24 hours which mean that at a specific hour the next day the tendency of the number of ads will be similar to the date of the previous day. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> 24 hour periods: </span> This time interval in our time series will be important to determine seasonality movements in our time series. </li>
</ul>

<br>

## What are Fourier Series <br>

**Fourier Series** helps us represent periodic periods through the use of sine and cosine functions.
To make it more simple to the beginner users think of it as a distribution at a specific period of time. We will use a 24 hour distribution since it seems that it will be helpful for our model since we have a strong autocorrelation during the 24 hour interval. <br><br>

**Reference for Fourier Series:**
If you are interested finding out more about Fourier Series, I really enjoyed this explanation but there are tons of other sources that could better explain why Fourier Series are important. 
[Fourier Series contributors Matt DeCross, Steve the Philosophist and Jlmln Khlm](https://brilliant.org/wiki/fourier-series/) <br><br>


**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">24 hour distribution: </span> We see that the 24 hour cosine and sin functions has a positive impact in the regression model. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> V shape form: </span> As you can see in the distribution there is a V shape form which makes sense since somehow we are trying to replicate those seasonality movements we have in our time series data. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Regression model without vs with Fourier Series: </span> The **Adjusted R-Squared** improved from <span style="background:#fed56f; font-weight:bold; color:black">0.2062 </span> to <span style="background:#fed56f; font-weight:bold; color:black">0.8282</span> which is a massive improvement in our regression model.  </li>
</ul>
<br>

**Fourier Series representation of a periodic Function:** <br>
$\LARGE f(t)= a_{v} + \sum_{n=1 }^{\infty }a_{n}\cos (n\omega _{0}t) + b_{n}\sin (n\omega _{0}t)$ <br>

**Where:** <br><br>
$\large N$ = integer sequence 1,2,3 ... <br><br>
$\large a_v$ = Fourier Coefficient <br><br>
$\large a_n$ = Fourier Coefficient <br><br>
$\large b_n$ = Fourier Coefficient <br><br>
$\large \frac{2\pi }{T}$ = Fundamental Frequency<br><br>
$\large 2\omega _{0}, 3\omega _{0}, 4\omega _{0}$ = harmonic frequencies <br><br>

More information how fourier series work in detail in [Learn about Fourier Coefficients by Donald Krambeck](https://www.allaboutcircuits.com/technical-articles/the-fourier-coefficients/)


## Fourier Distributions

```{r show_fourier, fig.height=6}

fourier_hourly_tbl <- prepared_hourly_tbl %>%
  tk_augment_fourier(time, .periods = c(24), .K = 2)


# -matches("(hour)|(minute)|(second)|(am.pm)")


# color: #76A08A

fourier_col_palletes <- c("#D1362F", "#27223C", "#2E604A", "#E6A2C5")  

fourier_hourly_tbl %>% select(matches("(cos24)|(sin24)")) %>% 
  pivot_longer(cols = 1:4) %>% 
  ggplot(aes(x=value, color=name, fill=name)) + geom_density(alpha=0.3) + 
  facet_wrap(~name, scales = "free_x") + theme_bw() + 
    theme(plot.title = element_text(face = "bold", color = "black", size=14),
        plot.subtitle = element_text(face = "bold", color = "black", size=12),
        axis.text = element_text(color = "black"), legend.text = element_text(size=10),
        legend.title = element_text(size = 12), legend.position = "bottom",
        strip.background =element_rect(fill="#76A08A"), strip.text = element_text(color="white", face="bold")) + 
  labs(
    title = "Fourier Series Distribution",
    subtitle = "24 hour Fourier Series"
  ) + scale_x_continuous(expand = c(0,0)) + 
  scale_color_manual("Fourier Legend", values = fourier_col_palletes) + 
  scale_fill_manual("Fourier Legend", values = fourier_col_palletes) + 
  guides(color = guide_legend(ncol=2, bycol=TRUE))
  

```

## Adjusted R-Squared Improvement with Fourier Series


```{r plot_fourier}

model_formula_fourier <- as.formula(
  ads ~ splines::ns(index.num) + day + wday.lbl + hour + 
    time_sin24_K1 + time_cos24_K1 + time_sin24_K2 + time_cos24_K2 
   
)


fourier_hourly_tbl %>%
  plot_time_series_regression(
    .date_var = time,
    .formula = model_formula_fourier,
    .show_summary = TRUE,
    .interactive=F,
    .line_size = 1
  ) + theme_bw() + 
  theme(plot.title = element_text(face = "bold", color = "black", size=14),
        plot.subtitle = element_text(face = "bold", color = "black", size=12),
        axis.text = element_text(color = "black"), legend.text = element_text(size=10),
        legend.title = element_text(size = 12), legend.position = "bottom") + 
  scale_color_manual(values = new_colors_pal) + scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) + 
  labs(
    title = "Regression Model using Fourier Series",
    subtitle = "Capturing seasonality with Fourier 24",
    y = "Number of Ads", 
    x = "Time of the Day"
  )

```   

# Adding Lagged Features
As discussed before we use lags to see if there is a correlation between the **time column** and the target variable in this case the number of ads. We want to see if past data has some influence on what the number of ads will be in the future. Just to recap this is what we found out:
<ul>
<li>**Positive correlation between lags:** We found out that every 24 hours there is a positive influence in the number of ads. </li>
<li>**Interpreting correlation of lags:** For instance, we can expect that the number of ads will increase at 5 in the afternoon every single day since we see a positive autocorrelation every 24 hours for the number of lags. </li>
</ul>
<br>

**Now we will see how to add rolling lagged features in order for us to detect the overall trend in the number of ads.** 


<img src="https://www.business-science.io/assets/lag-explanation.PNG" align="center"> <br>
 **source: Business Science**
 
## Rolling Averages of Lagged Features
The purpose of using rolling averages in lagged features is to detect the overall trend of our data. What we will do below is to shift down our data 72 hours (3 days) and get the rolling average of that lag of 72 days. By using this strategy we can shift not only our dataset by 72 hours but we can also better capture the trend by taking the moving average of that lagged feature. This is good if we would want our model to better capture the trend as to where the time series is probably "heading".<br>

**Summary:**
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Future Horizon: </span> The future horizon we will use in this sample is 72 hours. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> What lag will we use? </span> The lag will be the same as the future horizon or 72 hours. </li>
<li><span style="background:#fed56f; font-weight:bold; color:black">Capturing an upward trend: </span> Rolling lag features of 24 and 48 hours are able to capture an upward trend, make sense since in the lag 72 feature is at the end of the low number of ads cycle.</li>
</ul>

**What we learn from this?** Lag features can be a good source for detecting trend which could help your model improve the overall accuracy when forecasting.


```{r rolling_lags}

# 3 days horizon
horizon <- 24*3
lag_period <- 24*3
rolling_periods <- c(24, 48, 72)


lags_prepared_tbl <- prepared_hourly_tbl %>% 
    # Add future windows
    bind_rows(
        future_frame(.data = ., .date_var = time, .length_out = horizon)
    ) %>% 
    tk_augment_lags(ads, .lags = lag_period) %>% 
    tk_augment_slidify(
        .value = ads_lag72,
        .f = mean,
        .period = rolling_periods, 
        .align = "center",
        .partial = TRUE
    ) %>% 
  # Add lag at the beginning of every column name
  rename_with(.cols = contains("lag"), .fn = ~ str_c("lag_", .))
    


lags_prepared_tbl %>%
  select(time, contains("lag"), ads) %>% 
    pivot_longer(-time) %>% 
    plot_time_series(time, value, name, .smooth=F, .interactive=F, .line_size=1) + 
  theme_fivethirtyeight() + theme(plot.background = element_rect(fill="white"),
                                  panel.background = element_rect(fill="white"),
                                  legend.background = element_rect(fill="white"),
                                  legend.key = element_rect(fill="white")) +
  scale_color_calc() + 
  labs(
    title = "Rolling Lags",
    subtitle = "A method for capturing trend (Future Horizon: 3 days)",
    y = "Number of Ads",
    x = "Date"
  ) +   guides(color = guide_legend(ncol=2, bycol=TRUE))

```
            
# The Workflow Way

<img src="https://2s7gjr373w3x22jf92z99mgm5w-wpengine.netdna-ssl.com/wp-content/uploads/2018/09/WD_3.png">
**source: datanami** 

A workflow is a way of putting together different steps in the modeling process. These include:
<ul>
<li>**Preprocessing** </li>
<li>**Modeling** </li>
<li>**Postprocessing** </li>
</ul>


This make the pipeline process much easier to track and to implement when it comes to the modeling phase. <br>


**What is the logic of the Recipes package?** <br>
The recipes package allows us to preprocess our data which is an essential part before modeling. Usually, some of the preprocessing steps include turning categorical variables into dummy variables, scaling numeric columns, removing columns, combining different columns etc.<br><br>

**The logic of the recipes package works as follows:**

<ul>
<li>**Build the recipe:** Add all the necesarry steps in the preprocessing steps (scaling, encoding, removing), on your training dataset </li>
<li>**Prepare the recipe**  </li>
<li>**Bake the recipe:** Execute the steps of the recipe </li>
</ul>

<br><br>

<span style="background:#fed56f; font-weight:bold; color:black"> To summarize what has been done I have impemented basically all the preprocessing steps implemented before with the exception that I added an interaction (combination of columns) to add predictive capability to our model. </span>

## Feature Engineering with the Recipes Package

```{r}

# 22% is the testing set
# Splitting dataframe
prepared_hour_split_tbl <- time_series_split(prepared_hourly_tbl, assess = "2 days", cumulative = TRUE)

# Extracing training and test sets
train_df <- training(prepared_hour_split_tbl)
test_df <- testing(prepared_hour_split_tbl)




# Preparing our recipe
# We used the time signature from the timetk package so no need to use it in
# recipes
recipe_book <- recipe(ads_transformed ~ . , data = train_df) %>%
  # Remove unecessary features
  step_rm(matches("(iso)|(xts)|(quarter)|(year)|(month)|(qday)|(diff)")) %>% 
  step_normalize(matches("(index.num)|(yday)")) %>% 
  step_dummy(all_nominal(), one_hot = TRUE) %>% 
  # Combine features
  step_interact(~ matches("am.pm") * matches("wday.lbl")) %>% 
  step_fourier(time, period = c(24, 48, 76), K=2)


 # A glimpse of our recipe
recipe_book %>% prep() %>% juice() %>% glimpse()

```



## Creating a Pipeline with WorkFlow

When creating a workflow pipeline we implement three main steps:
<ul>
<li>**Setting up the model:** I use the parsnip model for this, in this example we will use a random forest model. We need to set the model and the type of problem (in this case) regression it could also be use for classification problems. </li>
<li>**Establish the workflow: ** Here we establish first the model, and then the recipe we previously prepared. The recipes does all the preprocessing step on the training data. </li> 
<li>**Fit the model on the training data: ** Finally, we must fit our model to be ready for it to predict against the testing set. </li>
</ul>


```{r}

rf_model <- rand_forest() %>% 
  set_engine("randomForest") %>% 
  set_mode("regression")


workflow_model <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(recipe_book) %>% 
  fit(train_df)

workflow_model
```


## Predicting with Random Forest
 <img src="https://miro.medium.com/max/700/0*f_qQPFpdofWGLQqc.png"><br>
 
 **Source:** Afroz Chakure (Medium Article)
 
 <br><br>
 
 Not to get to in detail as to what is a Random Forest model, I would just summarise it as a technique that runs different decision trees in parallel (which can be computationally expensive). In the case of classification the final result of the prediction will be the mode of all the decision trees while in regression (in this case), it takes the mean as the final output. <br><br>
 
<span style="background:#fed56f; font-weight:bold; color:black"> Note: I have not discussed the topic of cross validation since I plan to write a different notebook only on this and other topics probably in the next part. </span> 

<br>

As for all machine learning problems, cross validation is an important step in order to avoid overfitting.<br><br>


**Summary:**
<ul>
<li>**Mean Squared of Residuals:** This is our error metric and as we can see it is pretty low meaning that the model is performing well on the test set. (This does not mean it is not overfitting!) </li>
<li>**Residuals Plot: ** The residuals plot shows prove of the minimum standard error. The model is able to captture well the actual observations. </li>
</ul>


```{r}

predict_tbl <- workflow_model %>% 
  predict(test_df) %>% 
  bind_cols(test_df) %>% 
  select(time, .pred, ads_transformed) %>% 
  pivot_longer(.pred:ads_transformed)


predict_tbl %>% 
  ggplot(aes(x=time, y=value)) + geom_line(aes(color=name), size=1) +  theme_fivethirtyeight() +
  theme(plot.background = element_rect(fill="white"),
                                  panel.background = element_rect(fill="white"),
                                  legend.background = element_rect(fill="white"),
                                  legend.key = element_rect(fill="white")) + scale_color_manual(values = c("#D1362F", "#2E604A")) +
  labs(
    title = "Random Forest Model",
    subtitle = "Feature Engineering with the Recipes Package",
    caption = "Note: Cross Validation not implemented, prone to overfitting"
  )



```

## Residuals Plot

```{r}

residuals_tbl <- predict_tbl %>%
  pivot_wider(names_from = name, values_from = value) %>% 
  mutate(
    residuals = ads_transformed - .pred
  )


residuals_tbl %>% 
  ggplot(aes(x=time, y=residuals)) + geom_point(color="red") + 
  geom_hline(yintercept = 0, color="black", size=1.5) + 
  scale_y_continuous(limits =  c(-0.4, 0.4)) +
  theme_fivethirtyeight() + 
    theme(plot.background = element_rect(fill="white"),
                                  panel.background = element_rect(fill="white"),
                                  legend.background = element_rect(fill="white"),
                                  legend.key = element_rect(fill="white")) + scale_color_manual(values = c("#D1362F", "#2E604A")) +
  labs(
    title = "Residuals Plot",
    subtitle = "Random Forest Model",
    caption = "Mean of squared residuals: 0.01474173"
  )


```



## Comparing Different Models

Now let's put what we have done above in our notebook and let's start some model comparison. I will introduce the use of the **modeltime** package which allow us to compare different models in the same plot. In order to do this we would need to create two workflows for each of our models. Remember a workflow is comprised of setting a model and then preprocessing the data through the recipes package. Just to recap we have used the following models: <br>
<ul>
<li><span style="background:#fed56f; font-weight:bold; color:black">Linear Models </span> </li>
<li><span style="background:#fed56f; font-weight:bold; color:black"> Random Forest Models </span> </li>
</ul>


Moreover, here is a summary of our main findings: <br>
<ul>
<li>**Test Set:** Our test set starts as of the 19th of September. </li>
<li>****Random Forest Model: ** The Random Forest Model looks much more accurate than our linear model. </li>
<li>**Metrics:** We can observe that the Random Forest model outperforms the linear model (See metrics below) and the explanation for those metrics we saw it above in our notebook. </li>
</ul>




```{r}
# Split the original df
final_split_df <- time_series_split(hourly_tbl, assess = horizon, cumulative = TRUE)

final_split_df %>% 
  tk_time_series_cv_plan() %>% 
  plot_time_series_cv_plan(time, ads, .interactive=FALSE, .line_size=1) + 
  theme_fivethirtyeight() + 
      theme(plot.background = element_rect(fill="white"),
                                  panel.background = element_rect(fill="white"),
                                  legend.background = element_rect(fill="white"),
                                  legend.key = element_rect(fill="white"),
            strip.background =element_rect(fill="#F8FAFB")) +
  scale_color_manual(values = c("#2E604A", "#D1362F")) +
  
  labs(
    title = "Splitting the orginal dataframe"
  )

```


```{r model_comparison}

# Preparing the linear model before combining before other models
linear_model <- linear_reg() %>% 
  set_engine("lm")


# 3 days horizon
horizon <- 24*3
lag_period <- 24*3
rolling_periods <- c(24, 48, 72)


# 22% is the testing set
# Splitting dataframe
prepared_hour_split_tbl <- time_series_split(prepared_hourly_tbl, assess = horizon, cumulative = TRUE)

# Extracing training and test sets
train_df <- training(prepared_hour_split_tbl)
test_df <- testing(prepared_hour_split_tbl)


recipe_base <- recipe(ads_transformed ~ . , data = train_df) %>%
  # Remove unecessary features
  step_rm(matches("(iso)|(xts)|(quarter)|(year)|(month)|(qday)|(diff)")) %>% 
  step_normalize(matches("(index.num)|(yday)")) %>% 
  step_dummy(all_nominal(), one_hot = TRUE) %>% 
  # Combine features
  step_interact(~ matches("am.pm") * matches("wday.lbl")) %>% 
  step_fourier(time, period = c(24, 48, 76), K=2) 
  


first_recipes <- recipe_base %>% 
  step_rm(time) %>% 
  step_ns(ends_with("index.num"), deg_free=2) 




# Bulding the workflow
lm_workflow_fitted <- workflow() %>% 
  add_model(linear_model) %>% 
  add_recipe(first_recipes) %>% 
  fit(train_df)

# modeltime

final_calibration_tbl <- modeltime_table(
  workflow_model, 
  lm_workflow_fitted
) %>% modeltime_calibrate(
  new_data = test_df)



final_calibration_tbl %>% 
  modeltime_forecast(new_data = test_df,
                     actual_data = prepared_hourly_tbl) %>% 
  plot_modeltime_forecast(.interactive = F, .line_size=1) + 
    theme_fivethirtyeight() + 
      theme(plot.background = element_rect(fill="white"),
                                  panel.background = element_rect(fill="white"),
                                  legend.background = element_rect(fill="white"),
                                  legend.key = element_rect(fill="white"),
            strip.background =element_rect(fill="#F8FAFB")) + 
  scale_color_calc() + 
  labs(
    title = "Measuring accuracy of our Models", 
    subtitle = "Linear and Random Forest Models"
  )

```


```{r accuracy_of_models}

accuracy_tbl <- final_calibration_tbl %>% 
  modeltime_accuracy()


```



```{r}

accuracy_tbl %>% 
  pivot_longer(mae:rsq) %>% 
  mutate(
    name = name %>% as_factor() %>% fct_reorder(value) %>% fct_rev(),
    value_txt = str_glue("{round(value, 2)}%") %>% as.character()
  ) %>% 
  ggplot(aes(x=name, y=value)) + geom_col(aes(fill=.model_desc), color="black") + facet_wrap(~ .model_desc) + 
  scale_fill_calc() + 
  geom_label(aes(label = value_txt), size=3, color="black") + 
  theme_fivethirtyeight() +
  theme(legend.position = "bottom",
        plot.background = element_rect(fill="white"),
        panel.background = element_rect(fill="white"),
        legend.background = element_rect(fill="white"),
        legend.key = element_rect(fill="white")) + 
  labs(
    title = "Comparison of Model Accuracy"
  )

```
                                                                   
                                                                   
                                                                   
                                                                   
     
# Part 3 (Coming up in the foreseen future!)
So we conclude this notebook, and I know we have seen so many different concepts in one notebook that we might be a bit lost after looking at just the theory. In the next notebook which I will put the link below once I start working on it my goal is to **Create a simple workflow for time series forecasting** and how through experimenting and with the concepts we learn in this one we can come with descent forecast. I would leave below a simple workflow how this can happen neverthless, in part 3 we will get much into detail. See you soon!




## Transformations 


```{r}

# Prepare our Data
hourly_tbl <- df %>% 
  set_names(names(.) %>% str_to_lower()) %>% 
  mutate(
    time = ymd_hms(time)
  ) %>% as_tibble()

# Find mean and standard deviation of logs 
# This is to do the inversion at the end
log_ads <- hourly_tbl %>%
    mutate(ads_log = log(ads))


inversion_values <- log_ads %>% 
    summarise(
        std_mean = mean(ads_log),
        std_mean = format(round(std_mean, 13), nsmall = 13),
        std_sd = sd(ads_log),
        std_sd = format(round(std_sd, 13), nsmall = 13)
        
    )


# Values for inverting our time series target variable (ads.)
std_mean <- inversion_values$std_mean
std_sd <- inversion_values$std_sd




# Transformed table
prepared_hourly_tbl <- hourly_tbl %>% 
  mutate(
    ads_transformed = log(ads),
    ads_transformed = standardize_vec(ads_transformed)
  ) 






# transactions_trans_weekly_tbl <- transactions_weekly_tbl %>%
#     mutate(revenue = log(revenue)) %>%
#     mutate(revenue = standardize_vec(revenue))


# Preparing the full dataset it saved headaches
# - Extend to Future Window

# Establish horizon from the beginning
horizon <- 24*3


# Split the dataframe the data prepared table


splits <- time_series_split(prepared_hourly_tbl, assess = horizon, cumulative = TRUE)


```



## Setting our Models


```{r}
# 1. Prophet

model_fit_prophet <- prophet_reg(seasonality_daily = TRUE) %>% 
  set_engine("prophet")


# 2. Random Forest 
model_spec_rf <- rand_forest(trees = 500, min_n = 50) %>% 
  set_engine("randomForest")



```


## Preprocessing for Feature Engineering



```{r}
recipe_spec_base <- recipe(ads_transformed ~ time, training(splits)) %>% 
  step_timeseries_signature(time) %>% 
  step_rm(matches("(iso)|(xts)|(second)|(year)|(quarter)|(month)")) %>% 
  step_fourier(time, period = c(12, 24, 36, 48), K=2) %>% 
  step_dummy(all_nominal())



recipe_spec_base %>% prep() %>% juice() %>% glimpse()


```



## Adding Workflows



```{r}

# 1. Workflow Random Forest

workflow_fit_rf <- workflow() %>%
  add_model(model_spec_rf) %>%
  add_recipe(recipe_spec_base %>% step_rm(time)) %>%
  fit(training(splits))


# 2. Prophet Workflow
workflow_fit_prophet <- workflow() %>% 
  add_model(model_fit_prophet) %>% 
  add_recipe(recipe_spec_base) %>% 
  fit(training(splits))



# Combine models together
# Combined models with modeltime

model_table <- modeltime_table(
  workflow_fit_rf,
  workflow_fit_prophet
)

# Building the calibration table
calibration_table <- model_table %>% 
  modeltime_calibrate(testing(splits))

calibration_table


```


## Evaluate against the test set

```{r}

calibration_table %>% 
  modeltime_forecast(actual_data = prepared_hourly_tbl) %>% 
  plot_modeltime_forecast(.interactive=FALSE)

```



```{r}

# Accuracy of testing set
calibration_table %>% 
  modeltime_accuracy() %>% 
  table_modeltime_accuracy(.interactive=FALSE)

```



## Forecasting


```{r}


calibration_table %>% 
  modeltime_refit(prepared_hourly_tbl) %>% 
  modeltime_forecast(h = horizon, actual_data = prepared_hourly_tbl) %>% 
  plot_modeltime_forecast(.interactive = FALSE, .line_size=1)




```
                                                                   
                                                                   
                                                                   
                                                                   
                                                                   
                                                                   