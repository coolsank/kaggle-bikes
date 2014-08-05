% if(exist('./Logistic Regression/','dir') ~= 1)
%     addpath(genpath('./Logistic Regression/'));
% end
PLOT_TEST = 0; 
PLOT_MONTHS = 0;
CHECK_CONVERGENCE = 0;
LOAD_THETAS = 1

if(exist('./Linear Regression/','dir') ~= 1)
    addpath(genpath('./Linear Regression/'));
end
if LOAD_THETAS == 1 
    load('thetas.mat');
end

fid = fopen('./data/train.csv', 'rt');
ds = dataset('File','./data/train.csv','Delimiter',',');
dateStrings = ds.datetime;
formatIn = 'yyyy-mm-dd HH:MM:ss';

dateNumbers = datenum(dateStrings, formatIn);
ds.dateNumbers = dateNumbers;
ds.dateVectors = datevec(dateStrings,formatIn);
ds = sortrows(ds, 'dateNumbers');
%ds.consecutiveDay = abs(ds.dateNumbers(1) - ds.dateNumbers);
ds.consecutiveDay = floor(daysdif(char(ds.datetime(1)), char(ds.datetime)));
ds.consecutiveHour = round(daysdif(char(ds.datetime(1)), char(ds.datetime)) * 24);
% ts1 = timeseries(ds.registered, ds.consecutiveHour);
% ts1.TimeInfo.Units = 'hours';
% ts1.TimeInfo.StartDate='01-Jan-2011'; % Set start date.
% ts1.TimeInfo.Format = 'mmm dd, yy';
% plot(ts1,'r');
% hold on
% ts2 = timeseries(ds.casual, ds.consecutiveHour);
% ts2.TimeInfo.Units = 'hours';
% ts2.TimeInfo.StartDate='01-Jan-2011'; % Set start date.
% ts2.TimeInfo.Format = 'mmm dd, yy';
% plot(ts2,'b');
% legend('Registrirani uporabniki', 'Neregistrirani uporabniki');

if PLOT_TEST == 1
    %test hourlyUsage
    days = unique(ds.consecutiveDay);
    for i = 1 : 30
        hourlyUsage = getHourlyUsageForDays(ds, days(i));
        plot(hourlyUsage(:,1), hourlyUsage(:,2), 'r');
        hold on;
        plot(hourlyUsage(:,1), hourlyUsage(:,3), 'b--');
    end
    xlim([0, 23])
    xlabel('Hour')
    ylabel('# of rented bikes');

    %test hourly usage monthly cumulative
    JanuaryUsageByHours = getHourlyUsageForMonths(ds, 1);
    figure
    plot(JanuaryUsageByHours(:,1), JanuaryUsageByHours(:,2), 'r');
    hold on;
    plot(JanuaryUsageByHours(:,1), JanuaryUsageByHours(:,3), 'b--');
    xlim([0, 23])
    xlabel('Hour')
    ylabel('# of rented bikes');
    legend('Registered users', 'Casual users');
end

if PLOT_MONTHS == 1
    close all
    for i = 1 : 12
        monthlyAverage = getHourlyUsageForMonths(ds, i);
        figure
        plot(monthlyAverage(:,1), monthlyAverage(:,2), 'r');
        hold on;
        plot(monthlyAverage(:,1), monthlyAverage(:,3), 'b--');
        xlim([0, 23])
        xlabel('Hour')
        ylabel('# of rented bikes');
        legend('Registered users', 'Casual users');
        title(strcat('Month=',num2str(i)));
    end
end


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

clear = (ds.weather == 1);
mist = (ds.weather == 2);
light_snow = (ds.weather == 3);
heavy_rain = (ds.weather == 4);

m = length(ds);
hours = [0:23];
months = [1:12];

X = [ds.holiday, ds.workingday, ds.temp, ds.atemp, ds.humidity, ds.windspeed, spring, summer, fall, winter, clear, mist, light_snow, heavy_rain];

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
%normalize features
[X, mu, sigma] = featureNormalize(X);

%add bias column
X = [ones(m,1), X];

%split the data into training and test samples
indices = randperm(m);
indicesTrain = indices(1:floor(0.6*m));
indicesTest =indices(~ismember(indices,indicesTrain));
XTrain = X(indicesTrain,:);
XTest = X(indicesTest,:);

consecutiveHoursTest = ds.consecutiveHour(indicesTest);

% Some gradient descent settings
iterations = 5000;
%alpha = [0.01, 0.001, 0.0005, 0.0001, 0.00005, 0.000001];
alpha = [0.001];
cost = [];
for i = 1 : length(alpha)

    %% Create Linear Regression Model for casual bikes

    yCasual = ds.casual;
    yTrainCasual = yCasual(indicesTrain,:);
    yTestCasual = yCasual(indicesTest,:);

    if(exist('thetaCasual','var') ~= 1)
        thetaCasual = zeros(51, 1); % initialize fitting parameters
        % compute and display initial cost
        computeCost(XTrain, yTrainCasual, thetaCasual);

        % run gradient descent
        [thetaCasual, JCasualHistory] = gradientDescent(XTrain, yTrainCasual, thetaCasual, alpha(i), iterations);
        if CHECK_CONVERGENCE == 1
            plot(1:length(JCasualHistory), JCasualHistory);
        end
    end

    %check errors
    JTrainCasual = computeCost(XTrain, yTrainCasual, thetaCasual);
    JTestCasual = computeCost(XTest, yTestCasual, thetaCasual);

    predictionsCasual = XTest * thetaCasual;
    
    %plot actual and predicted values
    figure
    scatter(consecutiveHoursTest, predictionsCasual, 'bx');
    hold on;
    scatter(consecutiveHoursTest, yTestCasual, 'bo');


    %% Create Linear Regression Model for regular bikes
    yRegistered = ds.registered;
    yTrainRegistered = yRegistered(indicesTrain,:);
    yTestRegistered = yRegistered(indicesTest,:);

    if(exist('thetaRegistered','var') ~= 1)
        thetaRegistered = zeros(51, 1); % initialize fitting parameters
        % compute and display initial cost
        computeCost(XTrain, yTrainRegistered, thetaRegistered);

        % run gradient descent
        thetaRegistered = gradientDescent(XTrain, yTrainRegistered, thetaRegistered, alpha(i), iterations);
    end

    %check errors
    JTrainRegistered = computeCost(XTrain, yTrainRegistered, thetaRegistered);
    JTestRegistered = computeCost(XTest, yTestRegistered, thetaRegistered);

    predictionsRegistered = XTest * thetaRegistered;
    actualRegistered = yTestRegistered;
    
    %plot actual and predicted values
    figure
    scatter(consecutiveHoursTest, predictionsRegistered, 'rx');
    hold on;
    scatter(consecutiveHoursTest, actualRegistered, 'ro');
    
end