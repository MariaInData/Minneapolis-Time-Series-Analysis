#analyzing Minneapolis Crime Data
#importing packages
suppressPackageStartupMessages({
  library(TSA)
  library(forecast)
  library(dplyr)
  library(ggplot2)
  library(tseries)
  library(Metrics)
})


#read in the data
  
df <-read.csv("Crime_Data_Minneapolis.csv")

#drop columns list
#get column names
colnames(df)
#drop columns unnecessary for time series analysis
df <- select(df, -c('ï..X','Y','Type', 'Case_Number', 'Case_NumberAlt', 'Reported_Date',
              'NIBRS_Crime_Against', 'NIBRS_Group', 'NIBRS_Code',
              'Offense', 'Problem_Initial', 'Problem_Final',
              'Address' , 'Latitude', 'Longitude',
              'wgsXAnon', 'wgsYAnon', 'Crime_Count', 'OBJECTID', 'Precinct',
              'Neighborhood', 'Ward'))

#geting date from datetime and creating a column
df$date <- as.Date(df$Occurred_Date)

#dropping occurded date column
df <- select(df, -c('Occurred_Date'))
#getting only dates after 3.2.2023
df <- subset(df, date > '2019-03-02' )


head(df)

#aggregate number of crime occurances by date
df <- df %>% group_by(date) %>% summarise(occurances = n())

#ensure that the dataframe is in order by date

sorted_df <- df[,by='date']
tail(sorted_df)


#sorted_df <-select(df, -c('date'))
ts_df <-ts(sorted_df$occurances)

Time Series Analysis

#Step 1: Visualized the data 
autoplot(ts_df) + geom_point(shape = 1, size = 1)


#Step 2: Use ADF to check stationarity

adf.test(ts_df)
#p-value is 0.01. P-value < 0.05 mean I can reject the null hypothesis.
#Thereby, inferring that the series is stationary.

#Step 3: Plot ACF and PACF to check if purely AR or purely MA model

#plotting ACF
acf(ts_df, lag.max = 60) 
#ACF is tailing off


#plotting PACF
pacf(ts_df, lag.max = 60)
#PACF is tailing off

#Conclusion: Both ACF and PACF look likes it is tailing off. It is probably
#an ARMA model.

#To check for ARMA model, I will look at both EACF and auto.arima to see 
#potential combinations for ARMA model

eacf(ts_df)

#using auto.arima() function
auto.arima(ts_df)
#Looking at the auto-arima results shows an ARIMA(1,1,2)
#BIC is 13,503


#comparing some models based on eacf and auto.arima results using BIC
Arima(ts_df, order = c(0,0,1)) #BIC: 13971
Arima(ts_df, order = c(0,0,2)) #BIC: 13831
Arima(ts_df, order = c(1,0,0)) #BIC: 13701
Arima(ts_df, order = c(1,0,1)) #BIC: 13567.17
Arima(ts_df, order = c(2,0,1)) #BIC: 13519
Arima(ts_df, order = c(1,1,2)) #BIC: 13503.06

#while the auto.arima gave the best results of ARIMA(1,1,2). I will go with
#ARIMA(2,0,1) as it has less parameters and difference isn't needed. The 
#difference in BIC is less than 1%, so rather insignificant. 




#Let's try forecasting!

df_for <-sorted_df$occurances
typeof(df_for)

#Let's split the time series into a training set and a test set.
#I'm interested in forecasting the crime rate in the next 7 days.
length(df_for)
ts_train = ts(df_for[1:1454,1], start = 1, end = 1454)
ts_test = ts(df_for[1455:1461], start = 1455, end = 1461)


#Step 1: ARIMA alone
arima0 = auto.arima(ts_train)


#Forecasting crime rate in the next 7 days.
arima0_forecast = forecast(arima0, h=7)
#plotting forecast
autoplot(arima0_forecast) + autolayer(ts_test, series = 'Data') +
  autolayer(arima0_forecast$mean, series = 'Forecasts') +
  labs(title = 'Crimes Per Day Forecasted', y = 'Crime Count')



#calculating the RMSE for ARIMA
rmse_arima = rmse(arima0_forecast$mean, ts_test)
rmse_arima #RMSE = 30.756

#This is a very good RMSE score

#Step 2: Linear Model Alone
# I am going to create two regressors, one is t and the other is t^2.
#for the test set, t starts at 1455
t1 = c(1:1454)
t2 = t1^2
t1_test = c(1455:1461)
t2_test = t1_test^2

#Running linear regression on training set against both t1 and t2

lm0 = lm(ts_train ~ t1 + t2)
summary(lm0)

#extrapolating the results to the test set and visualize them

X_test = data.frame(t1 = t1_test, t2 = t2_test)
lm0_forecast = forecast(lm0, newdata = X_test)

lm0_ts = ts(lm0_forecast$mean, start = 1455, end = 1461)
lm0_fit = ts(lm0$fitted.values, start = 1, end = 1454)

#visualizing
autoplot(ts(df_for)) + autolayer(lm0_ts, series = 'Forecasts') +
  autolayer(lm0_fit, series = 'fitted')

#calculating the RMSE
rmse_lm = rmse(ts_test, lm0_forecast$mean)
rmse_lm #RMSE: 52.85

#Step 3: Linear Model Plus Arima

#extracting the residuals of the linear model above. I'll consider it like
# a new time series for Arima. This is the beginning of the sequential part.

z = lm0$residuals
ts.plot(z)

#running an auto.arima on the residuals and calculating the forecasts on the
#test set
arima1 = auto.arima(z)
arima1 #auto arima choose a ARIM(2,0,1)

z_forecast =forecast(arima1, h =7)$mean

#calculating the forecasts combining both linear model and ARIMA.
#Illustrate the results of the 3 models

y_forecast = z_forecast + lm0_forecast$mean
autoplot(ts_test, series = 'Data') +
  autolayer(ts(lm0_forecast$mean, start = 1455, end = 1461), series = 'LR 
            Forecasts') +
  autolayer((arima0_forecast$mean), series = 'ARIMA0 Forecasts') +
  autolayer((y_forecast), series = 'LR + Arima Forecast')

#calculating the RMSE
rmse_lm_plus_arima = rmse(ts_test, y_forecast)
rmse_lm_plus_arima #32.74


#Looking at the 3 different forecasts models I built, the best one is the
#auto.arima in terms of smallest RMSE.























