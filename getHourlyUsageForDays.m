function hourlyUsage = getHourlyUsageForDays(ds, consecutiveDays)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if isscalar(consecutiveDays) == 1
        subset = ds(ds.consecutiveDay == consecutiveDays, :);
    else
        indices = find(ismember(ds.consecutiveDay, consecutiveDays));
        subset = ds(indices,:);
    end
    hourlyUsage = [unique(subset.dateVectors(:,4)) grpstats(subset.registered, subset.dateVectors(:,4), {'sum'}) grpstats(subset.casual, subset.dateVectors(:,4), {'sum'})];

    end

