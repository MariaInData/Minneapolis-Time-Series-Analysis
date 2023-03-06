# Minneapolis Time Series Analysis
 <p align="center"><img width="576" alt="image" src="https://user-images.githubusercontent.com/125685678/222930438-f15a878c-362f-4495-829f-02beaba66cf5.png">   </p> 


# Project Goal
The purpose of this analysis is to better understand the data and to predict future crime rates.

# Project Impact
I worked on this project to further my time series analysis. Since COVID-19 hit, crime rates across the US has been rising. I wanted to see if the data was stationary, and if I could better understand crime rates. 

# Overall Process
1. Getting Minneapolis Crime Data
- I found the Open Minneapolis website and found that the city refreshes it's crime dashboard daily. Wanting to understand the trend of data, I downloaded the Minneapolis Crime Data on 3.2.2023.  

Link to data: https://opendata.minneapolismn.gov/search?groupIds=79606f50581f4a33b14a19e61c4891f7

2. Data Preparation
- Removed columns that were unnecessary to my data analysis
- Decided to move my level of analysis from neighborhood to city level to better understand crime rates
- Noticed that by choosing 'Occurance Date' instead of 'Report Date', I got outliers. For example, some crim occurances happened in 1992. To focus on more relevant dates, I plotted the last 10 years of crime. I noticed that before 2018 there was very little crime, which made me believe that the data was only accurately reporting since late 2018. For ease of analysis, I choose the last 4 years (3.2.2019-3.2.2023).
- I aggregated crime based on date.

 <p align="center"> <img width="891" alt="image" src="https://user-images.githubusercontent.com/125685678/222880592-7f00d12e-4b3f-4e06-a648-1df675e244d3.png"> </p> 

3. Time Series Analysis
- First, I viusalized the data
<img width="891" alt="image" src="https://user-images.githubusercontent.com/125685678/222880592-7f00d12e-4b3f-4e06-a648-1df675e244d3.png"> </p> 
- Next, I used ADF to check for stationarity
 <p align="center"><img width="473" alt="image" src="https://user-images.githubusercontent.com/125685678/222880653-f33c8613-e38f-491d-bd35-9650108e7e7c.png">
- With a p-value of < 0.05, I can reject the null hypothesis in favor of the alternative hypothsis. Thus, the time series is stationary.
-Now, I plotted both ACF and PACF to check if the time series was purely AR or purely MA model.
 <p align="center"><img width="702" alt="image" src="https://user-images.githubusercontent.com/125685678/222880700-12693f24-93fd-42f2-9d33-c76966142ff5.png">   </p> 
 <p align="center">Above is the ACF grpah   </p> 

 <p align="center"><img width="705" alt="image" src="https://user-images.githubusercontent.com/125685678/222880711-33026a4c-620a-4883-b1d1-5910e9862b6d.png">   </p> 
 <p align="center">Above is the PACF graph   </p> 
