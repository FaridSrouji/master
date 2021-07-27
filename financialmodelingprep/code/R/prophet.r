library(prophet)
# R
df <- read.csv('/Users/Farid Srouji/Documents/Research/VIXInterplaySentiment/master/financialmodelingprep/data/csv/df.csv')
df1 <- read.csv('/Users/Farid Srouji/Documents/Research/VIXInterplaySentiment/master/financialmodelingprep/data/csv/df1.csv')
m <- prophet(df1)
future <- make_future_dataframe(m, periods = 365)
tail(future)
forecast <- predict(m, future)
tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])
# plot(df1$sentiment,
#           main="The Sine Function",
#           ylab="sin(x)",
#           type="l",
#           col="blue")
plot(m, forecast)
#prophet_plot_components(m, forecast)
# #library(ggplot2)
# x <- seq(-pi,pi,0.1)
# plot(x, sin(x))
# 
# plot(x, sin(x),
#      main="The Sine Function",
#      ylab="sin(x)",
#      type="l",
#      col="blue")
# 
# # plot the data using ggplot
# # ggplot(data = df, aes(x = date, y = sentiment)) +
# #   geom_point() +
# #   labs(x = "Date",
# #     y = "Total Precipitation (Inches)",
# #     title = "Precipitation Data",
# #     subtitle = "Boulder, Colorado 2013")

