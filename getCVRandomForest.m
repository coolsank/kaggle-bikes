function [modelRegistered, modelCasual, scoreTotalBest] = getCVRandomForest(X,yCasual, yRegistered, treesCount, test)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if strcmpi(computer,'PCWIN') |strcmpi(computer,'PCWIN64')
       compile_windows
    else
       compile_linux
    end

    total_train_time=0;
    total_test_time=0;
    
    scoreTotalBest = Inf;

indices = crossvalind('Kfold',yCasual,10);

    mtry = 4;
    scoreTotalBest = Inf;
    modelCasual = 0;
    modelRegistered = 0;
    scoreAverage = 0;
    if test == 1
        iterationsCount = 1;
    else
        iterationsCount = 10;
    end
    for i = 1 : iterationsCount
        indicesTest = find(indices == i);
        indicesTrain = find(indices ~= i);
        
        XTrain = X(indicesTrain,:);
        XTest = X(indicesTest,:);
        
        yTrainCasual = yCasual(indicesTrain,:);
        yTestCasual = yCasual(indicesTest,:);
        yTrainRegistered = yRegistered(indicesTrain,:);
        yTestRegistered = yRegistered(indicesTest,:);
        
        mdlCasual = regRF_train(XTrain,yTrainCasual, treesCount, mtry);
        predictionsCasual = regRF_predict(XTest,mdlCasual);
        scoreCasual = rmsle(yTestCasual, predictionsCasual);
        
        mdlRegistered = regRF_train(XTrain,yTrainRegistered, treesCount, mtry);
        predictionsRegistered = regRF_predict(XTest, mdlRegistered);
        scoreRegistered = rmsle(yTestRegistered, predictionsRegistered);
          
        scoreTotal = rmsle(yTestCasual+yTestRegistered, predictionsCasual+predictionsRegistered);
        
        scoreAverage = scoreAverage + scoreTotal;
        
        if scoreTotal < scoreTotalBest
            modelCasual = mdlCasual;
            modelRegistered = mdlRegistered;
            scoreTotalBest = scoreTotal;
        end       
        
    end
    
    scoreAverage = scoreAverage/iterationsCount;
    
    msg = sprintf('Average score for %d trees: %0.6f', treesCount, scoreAverage);
    disp(msg);


end

