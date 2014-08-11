function [modelRegistered, modelCasual, scoreTotalBest] = getCVBoostTree(X,yCasual, yRegistered)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
indices = crossvalind('Kfold',yCasual,10);
    scoreTotalBest = Inf;
    modelCasual = 0;
    modelRegistered = 0;
    for i = 1 : 10
        indicesTest = find(indices == i);
        indicesTrain = find(indices ~= i);
        
        XTrain = X(indicesTrain,:);
        XTest = X(indicesTest,:);
        
        yTrainCasual = yCasual(indicesTrain,:);
        yTestCasual = yCasual(indicesTest,:);
        yTrainRegistered = yRegistered(indicesTrain,:);
        yTestRegistered = yRegistered(indicesTest,:);
        
        ensCasual = fitensemble(XTrain,yTrainCasual,'bag',100,'Tree', 'type', 'regression');
        predictionsCasual = abs(ensCasual.predict(XTest));
        scoreCasual = rmsle(yTestCasual, predictionsCasual);
        
    
        ensRegistered = fitensemble(XTrain, yTrainRegistered,'bag',100,'Tree', 'type', 'regression');
        predictionsRegistered = abs(ensRegistered.predict(XTest));
        scoreRegistered = rmsle(yTestRegistered, predictionsRegistered);
        
        scoreTotal = rmsle(yTestCasual+yTestRegistered, predictionsCasual+predictionsRegistered);
        
        if scoreTotal < scoreTotalBest
            modelCasual = ensCasual;
            modelRegistered = ensRegistered;
            scoreTotalBest = scoreTotal;
        end       
        
    end
    

end

