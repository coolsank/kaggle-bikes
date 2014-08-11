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
afternoon = ismember(ds.dateVectors(:,4), [12,13,14,15,16,17,18]);
morning = ismember(ds.dateVectors(:,4), [7,8,9,10,11]);
evening = ismember(ds.dateVectors(:,4), [19,20,21,22,23]);
night = ismember(ds.dateVectors(:,4), [0,1,2,3,4,5,6]);
clearAfternoon = afternoon & weather_clear;
clearMorning = morning & weather_clear;
mistMorning = morning & mist;
mistAfternoon = afternoon & mist;
%clearAfternoonTemperature = clearAfternoon .* ds.temp;
clearMorningHoliday = clearMorning & ds.holiday;
mistMorningHoliday = mistMorning & ds.holiday;
lightSnowMorningHoliday = light_snow & ds.holiday;
clearAfternoonHoliday = clearAfternoon & ds.holiday;
clearMorningWorkingDay = clearMorning & ds.workingday;
clearAfternoonWorkingDay = clearAfternoon & ds.workingday;
clearEightOClock = (ds.dateVectors(:,4) == 8) & weather_clear;
mistEightOClock = (ds.dateVectors(:,4) == 8) & mist;
lightSnowEightOClock = (ds.dateVectors(:,4) == 8) & light_snow;
heavyRainEightOClock = (ds.dateVectors(:,4) == 8) & heavy_rain;
clearSeventeenOClock = (ds.dateVectors(:,4) == 17) & weather_clear;
clearEighteenOClock = (ds.dateVectors(:,4) == 18) & weather_clear;
lightSnowSeventeenOClock = (ds.dateVectors(:,4) == 17) & light_snow;
heavyRainSeventeenOClock = (ds.dateVectors(:,4) == 17) & heavy_rain;
mistEighteenOClock = (ds.dateVectors(:,4) == 18) & mist;
mistSeventeenOClock = (ds.dateVectors(:,4) == 17) & mist;
lightSnowEighteenOClock = (ds.dateVectors(:,4) == 18) & light_snow;
heavyRainEighteenOClock = (ds.dateVectors(:,4) == 18) & heavy_rain;
workCommutes = ismember(ds.dateVectors(:,4), [8,17,18]);

year_2011 =(ds.dateVectors(:,1) == 2011);
year_2012 = (ds.dateVectors(:,1) == 2012);

m = length(ds);
hours = [0:23];
months = [1:12];
%X = [ds.holiday, ds.workingday, ds.temp, ds.atemp, ds.humidity, ds.windspeed, spring, summer, fall, winter, weather_clear, mist, light_snow, heavy_rain];
X = [ds.temp, ds.atemp, ds.humidity, ds.windspeed];
%normalize numeric features
[X, mu, sigma] = featureNormalize(X);

%Score: 0.365255
%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night, clearMorningHoliday, clearAfternoonHoliday, clearMorningWorkingDay,clearAfternoonWorkingDay, clearEightOClock, mistEightOClock,clearSeventeenOClock, clearEighteenOClock, workCommutes, year_2011,year_2012];

%Score: 0.363344
%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night, mistEightOClock,clearSeventeenOClock, clearEighteenOClock, workCommutes, year_2011,year_2012];

%Score: 0.352008
X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night, mistEightOClock,clearSeventeenOClock, clearEighteenOClock, year_2011,year_2012];

%Score: 0.549759
%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night,clearEightOClock, mistEightOClock,clearSeventeenOClock, clearEighteenOClock, year_2011,year_2012];

%Score: 0.543744
%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night,clearEightOClock, mistEightOClock, clearEighteenOClock, year_2011,year_2012];

%Score: 0.359976
%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night, clearEightOClock, mistEightOClock, clearEighteenOClock, mistEighteenOClock, year_2011,year_2012];

%X = [ds.holiday, ds.workingday, X, spring, summer, fall, winter,weather_clear, mist, light_snow, heavy_rain, afternoon, morning, evening,night, clearMorningHoliday, clearAfternoonHoliday, clearMorningWorkingDay,clearAfternoonWorkingDay, clearEightOClock, mistEightOClock,clearSeventeenOClock, mistSeventeenOClock, clearEighteenOClock, mistEighteenOClock, workCommutes, mistMorningHoliday, lightSnowMorningHoliday, lightSnowEightOClock, heavyRainEightOClock, lightSnowSeventeenOClock, heavyRainSeventeenOClock, lightSnowEighteenOClock, heavyRainEighteenOClock, year_2011,year_2012];



%add months and hours boolean columns
monthsAndHours = [];
for i = 1 : size(X,1)
    month = ds.dateVectors(i,2);
    months = zeros(1,12);
    months(1, month) = 1;
    
    hour = ds.dateVectors(i,4);
    hours = zeros(1,24);
    hours(1, hour+1) = 1;
    monthsAndHours = [monthsAndHours; months, hours];
end

weekdays = [];
for i = 1 : size(X,1)
    [dayNumber, dayName] = weekday(ds.datetime(i));
    w = zeros(1,7);
    w(1,dayNumber) = 1;
    weekdays = [weekdays; w];
end

X = [X monthsAndHours weekdays];

%add bias column
X = [ones(m,1), X];


end

