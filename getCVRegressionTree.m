function [modelRegistered, modelCasual, scoreTotalBest] = getCVRegressionTree(X,yCasual, yRegistered)
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
        
        treeModelCasual = classregtree(XTrain,yTrainCasual);
        predictionsCasual = eval(treeModelCasual, XTest);
        scoreCasual = rmsle(yTestCasual, predictionsCasual);
    
        treeModelRegistered = classregtree(XTrain, yTrainRegistered);
        predictionsRegistered = eval(treeModelRegistered, XTest);
        scoreRegistered = rmsle(yTestRegistered, predictionsRegistered);
        
        scoreTotal = rmsle(yTestCasual+yTestRegistered, predictionsCasual+predictionsRegistered);
        
        if scoreTotal < scoreTotalBest
            modelCasual = treeModelCasual;
            modelRegistered = treeModelRegistered;
            scoreTotalBest = scoreTotal;
        end       
        
    end
    

end

