clear all;
PLOT_TIMESERIES = 0;
PLOT_TEST = 0; 
PLOT_MONTHS = 0;
CHECK_CONVERGENCE = 1;
LOAD_THETAS = 0;
WRITE_RESULTS = 1;
PLOT_RESULTS = 0;

if(exist('./Linear Regression/','dir') ~= 1)
    addpath(genpath('./Linear Regression/'));
end
if LOAD_THETAS == 1 
    load('thetas.mat');
end

fid = fopen('./data/train.csv', 'rt');
ds = dataset('File','./data/train.csv','Delimiter',',');
ds = modifyDataset(ds);

ds = sortrows(ds, 'dateNumbers');
if PLOT_TIMESERIES == 1
    ts1 = timeseries(ds.registered, ds.consecutiveHour);
    ts1.TimeInfo.Units = 'hours';
    ts1.TimeInfo.StartDate='01-Jan-2011'; % Set start date.
    ts1.TimeInfo.Format = 'mmm dd, yy';
    plot(ts1,'r');
    hold on
    ts2 = timeseries(ds.casual, ds.consecutiveHour);
    ts2.TimeInfo.Units = 'hours';
    ts2.TimeInfo.StartDate='01-Jan-2011'; % Set start date.
    ts2.TimeInfo.Format = 'mmm dd, yy';
    plot(ts2,'b');
    legend('Registered users', 'Casual users');
    xlabel('time')
    ylabel('# of rented bikes')
end

if PLOT_TEST == 1
    close all
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


%% create matrix with feature rows
X = getFeatures(ds);
m = size(X,1);

%split the data into training and test samples
indices = randperm(m);
indicesTrain = indices(1:floor(0.7*m));
indicesTest =indices(~ismember(indices,indicesTrain));
XTrain = X(indicesTrain,:);
XTest = X(indicesTest,:);

consecutiveHoursTest = ds.consecutiveHour(indicesTest);

% Some gradient descent settings
iterations = 80000;
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
        if CHECK_CONVERGENCE == 1 && (exist('JCasualHistory','var') == 1)
            plot(1:length(JCasualHistory), JCasualHistory);
            xlabel('# of iterations')
            ylabel('Prediction Error')
            title('Gradient Descent Convergence Check')
        end
    end

    %check errors
    JTrainCasual = computeCost(XTrain, yTrainCasual, thetaCasual);
    JTestCasual = computeCost(XTest, yTestCasual, thetaCasual);

    predictionsCasual = XTest * thetaCasual;
    
    %plot actual and predicted values
    if PLOT_RESULTS == 1
        figure
        scatter(consecutiveHoursTest, predictionsCasual, 'bx');
        hold on;
        scatter(consecutiveHoursTest, yTestCasual, 'bo');
    end


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
    if PLOT_RESULTS == 1
        figure
        scatter(consecutiveHoursTest, predictionsRegistered, 'rx');
        hold on;
        scatter(consecutiveHoursTest, actualRegistered, 'ro');
    end
    
    save('thetas.mat', 'thetaCasual', 'thetaRegistered');
    
end

if WRITE_RESULTS == 1
    dsResults = dataset('File','./data/test.csv','Delimiter',',');
    dsResults = modifyDataset(dsResults);

    XResults = getFeatures(dsResults);
    
    m = length(dsResults);
    
    predictionsCasual = XResults * thetaCasual;
    predictionsRegistered = XResults * thetaRegistered;
    predictionsTotal = round(predictionsCasual+predictionsRegistered);
    predictionsTotal(predictionsTotal<0)=0;
    fileID = fopen('results.csv','w');
    fprintf(fileID,'datetime,count\n');
    for i = 1 : length(predictionsTotal)
        fprintf(fileID,'%s,%d\n',char(dsResults.datetime(i)), predictionsTotal(i));
    end
    fclose(fileID);
end
