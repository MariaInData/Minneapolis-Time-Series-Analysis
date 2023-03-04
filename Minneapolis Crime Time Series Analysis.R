#analyzing Minneapolis Crime Data
#importing packages
suppressPackageStartupMessages({
  library(TSA)
  library(forecast)
  library(dplyr)
  library(ggplot2)
  library(tseries)
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


