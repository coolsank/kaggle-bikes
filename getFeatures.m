function X = getFeatures(ds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% select features
% datetime - hourly date + timestamp  
% season -  1 = spring, 2 = summer, 3 = fall, 4 = winter 
% holiday - whether the day is considered a holiday
% workingday - whether the day is neither a weekend nor holiday
% weather - 1: Clear, Few clouds, Partly cloudy, Partly cloudy 
% 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist 
% 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds 
% 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog 
% temp - temperature in Celsius
% atemp - "feels like" temperature in Celsius
% humidity - relative humidity
% windspeed - wind speed
% casual - number of non-registered user rentals initiated
% registered - number of registered user rentals initiated
% count - number of total rentals

spring = (ds.season == 1);
summer = (ds.season == 2);
fall = (ds.season == 3);
winter = (ds.season == 4);

weather_clear = (ds.weather == 1);
mist = (ds.weather == 2);
light_snow = (ds.weather == 3);
heavy_rain = (ds.weather == 4);

m = length(ds);
hours = [0:23];
months = [1:12];

%X = [ds.holiday, ds.workingday, ds.temp, ds.atemp, ds.humidity, ds.windspeed, spring, summer, fall, winter, weather_clear, mist, light_snow, heavy_rain];
X = [ds.temp, ds.atemp, ds.humidity, ds.windspeed];
%normalize numeric features
[X, mu, sigma] = featureNormalize(X);
X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter, weather_clear, mist, light_snow, heavy_rain];
%add months and hours boolean columns
monthsAndHours = [];
for i = 1 : size(X,1)
    month = ds.dateVectors(i,2);
    months = zeros(1,12);
    months(1, month) = 1;
    
    hour = ds.dateVectors(i,4);
    hours = zeros(1,24);
    hours(1, hour+1) = 1;
    monthsAndHours = [monthsAndHours; months hours];
end

X = [X monthsAndHours];

%add bias column
X = [ones(m,1), X];


end

