function score = rmsle(actual, prediction)
%RMSLE   Computes the root mean squared log error between
%   actual and prediction
%   score = rmsle(actual, prediction)
%
score = sqrt(msle(actual, prediction));