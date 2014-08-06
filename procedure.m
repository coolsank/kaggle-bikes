clear all;
PLOT_TIMESERIES = 0;
PLOT_TEST = 0; 
PLOT_MONTHS = 0;
CHECK_CONVERGENCE = 1;
LOAD_THETAS = 0;
PERFORM_LINEAR_REGRESSION = 0;
PERFORM_REGRESSION_TREE = 1;
SAVE_RESULTS = 1;
PLOT_RESULTS = 0;

if(exist('./Linear Regression/','dir') ~= 1)
    addpath(genpath('./Linear Regression/'));
end

if(exist('./stackedae_exercise/','dir') ~= 1)
    addpath(genpath('./stackedae_exercise/'));
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

featuresCount = size(X,2);

%split the data into training and test samples
indices = randperm(m);
indicesTrain = indices(1:floor(0.7*m));
indicesTest =indices(~ismember(indices,indicesTrain));
XTrain = X(indicesTrain,:);
XTest = X(indicesTest,:);

consecutiveHoursTest = ds.consecutiveHour(indicesTest);

yCasual = ds.casual;
yTrainCasual = yCasual(indicesTrain,:);
yTestCasual = yCasual(indicesTest,:);

yRegistered = ds.registered;
yTrainRegistered = yRegistered(indicesTrain,:);
yTestRegistered = yRegistered(indicesTest,:);

% Some gradient descent settings
iterations = 6000;
%alpha = [0.01, 0.001, 0.0005, 0.0001, 0.00005, 0.000001];
alpha = 0.005;
cost = [];

if PERFORM_REGRESSION_TREE == 1
    %% Create regression tree model using matlab built-in functions
    
    treeModelCasual = classregtree(XTrain,yTrainCasual);
    predictionsCasual = eval(treeModelCasual, XTest);
    scoreCasual = rmsle(yTestCasual, predictionsCasual);
    
    treeModelRegistered = classregtree(XTrain, yTrainRegistered);
    predictionsRegistered = eval(treeModelRegistered, XTest);
    scoreRegistered = rmsle(yTestRegistered, predictionsRegistered);
    
    scoreTotal = rmsle(yTestCasual+yTestRegistered, predictionsCasual+predictionsRegistered);
    
    if PLOT_RESULTS == 1
        figure
        scatter(consecutiveHoursTest, predictionsCasual, 'rx');
        hold on;
        scatter(consecutiveHoursTest, yTestCasual, 'bx');
        xlabel('Day')
        ylabel('# of rented bikes');
        legend('predicted', 'actual')
        title('Predictions of casual bike rentals')
        
        figure
        scatter(consecutiveHoursTest, predictionsRegistered, 'rx');
        hold on;
        scatter(consecutiveHoursTest, yTestRegistered, 'bx');
        xlabel('Day')
        ylabel('# of rented bikes');
        legend('predicted', 'actual')
        title('Predictions of registered bike rentals')
    end
    
    if SAVE_RESULTS == 1
        dsResults = dataset('File','./data/test.csv','Delimiter',',');
        dsResults = modifyDataset(dsResults);

        XResults = getFeatures(dsResults);

        m = length(dsResults);

        predictionsCasual = eval(treeModelCasual, XResults);
        predictionsCasual(predictionsCasual<0)=0;
        predictionsRegistered = eval(treeModelRegistered, XResults);
        predictionsRegistered(predictionsRegistered<0)=0;
        predictionsTotal = round(predictionsCasual+predictionsRegistered);
        fileID = fopen('results_regression_tree.csv','w');
        fprintf(fileID,'datetime,count\n');
        for i = 1 : length(predictionsTotal)
            fprintf(fileID,'%s,%d\n',char(dsResults.datetime(i)), predictionsTotal(i));
        end
        fclose(fileID);
    end
    
end
    
    
    
    
    

if PERFORM_LINEAR_REGRESSION == 1
    %% Create Linear Regression Model for casual bikes

    

    if(exist('thetaCasual','var') ~= 1)
        thetaCasual = zeros(featuresCount, 1); % initialize fitting parameters
        % compute and display initial cost
        computeCost(XTrain, yTrainCasual, thetaCasual);

        % run gradient descent
        [thetaCasual, JCasualHistory] = gradientDescent(XTrain, yTrainCasual, thetaCasual, alpha, iterations);
        if CHECK_CONVERGENCE == 1 && (exist('JCasualHistory','var') == 1)
            figure
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
    predictionsCasual(predictionsCasual<0) = 0;
    
    scoreCasual = rmsle(yTestCasual, predictionsCasual);
    sprintf('Score for predicting casual bike rental: %0.6f\n', scoreCasual); 
    
    %plot actual and predicted values
    if PLOT_RESULTS == 1
        figure
        scatter(consecutiveHoursTest, predictionsCasual, 'rx');
        hold on;
        scatter(consecutiveHoursTest, yTestCasual, 'bx');
    end


    %% Create Linear Regression Model for regular bikes

    if(exist('thetaRegistered','var') ~= 1)
        thetaRegistered = zeros(featuresCount, 1); % initialize fitting parameters
        % compute and display initial cost
        computeCost(XTrain, yTrainRegistered, thetaRegistered);

        % run gradient descent
        [thetaRegistered, JRegisteredHistory] = gradientDescent(XTrain, yTrainRegistered, thetaRegistered, alpha, iterations);
        if CHECK_CONVERGENCE == 1 && (exist('JRegisteredHistory','var') == 1)
            figure
            plot(1:length(JRegisteredHistory), JRegisteredHistory);
            xlabel('# of iterations')
            ylabel('Prediction Error')
            title('Gradient Descent Convergence Check')
        end
    end

    %check errors
    JTrainRegistered = computeCost(XTrain, yTrainRegistered, thetaRegistered);
    JTestRegistered = computeCost(XTest, yTestRegistered, thetaRegistered);

    predictionsRegistered = XTest * thetaRegistered;
    predictionsRegistered(predictionsRegistered<0)=0;
    
    %plot actual and predicted values
    if PLOT_RESULTS == 1
        figure
        scatter(consecutiveHoursTest, predictionsRegistered, 'rx');
        hold on;
        scatter(consecutiveHoursTest, yTestRegistered, 'bx');
    end
    
    scoreRegistered = rmsle(yTestRegistered, predictionsRegistered);
    sprintf('Score for predicting registered bike rental: %0.6f\n', scoreRegistered); 
    
    save('thetas.mat', 'thetaCasual', 'thetaRegistered');
    
    %check score
    predictedTotal = predictionsCasual + predictionsRegistered;
    actualTotal = yTestCasual + yTestRegistered;
    scoreTotal = rmsle(actualTotal, predictedTotal);
    sprintf('Score for predicting total bike rental: %0.6f\n', scoreTotal); 

    if SAVE_RESULTS == 1
        dsResults = dataset('File','./data/test.csv','Delimiter',',');
        dsResults = modifyDataset(dsResults);

        XResults = getFeatures(dsResults);

        m = length(dsResults);

        predictionsCasual = XResults * thetaCasual;
        predictionsCasual(predictionsCasual<0)=0;
        predictionsRegistered = XResults * thetaRegistered;
        predictionsRegistered(predictionsRegistered<0)=0;
        predictionsTotal = round(predictionsCasual+predictionsRegistered);
        fileID = fopen('results_regression.csv','w');
        fprintf(fileID,'datetime,count\n');
        for i = 1 : length(predictionsTotal)
            fprintf(fileID,'%s,%d\n',char(dsResults.datetime(i)), predictionsTotal(i));
        end
        fclose(fileID);
    end
end
