function hourlyUsage = getHourlyUsageForMonths(ds, months)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if isscalar(months) == 1
        subset = ds(ds.dateVectors(:,2) == months, :);
    else
        indices = find(ismember(ds.dateVectors(:,2), months));
        subset = ds(indices,:);
    end
    hourlyUsage = [unique(subset.dateVectors(:,4)) grpstats(subset.registered, subset.dateVectors(:,4), {'mean'}) grpstats(subset.casual, subset.dateVectors(:,4), {'mean'})];

    end
