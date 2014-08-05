function ds = modifyDataset(ds)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

dateStrings = ds.datetime;
formatIn = 'yyyy-mm-dd HH:MM:ss';

dateNumbers = datenum(dateStrings, formatIn);
ds.dateNumbers = dateNumbers;
ds.dateVectors = datevec(dateStrings,formatIn);
ds.consecutiveDay = floor(daysdif(char(ds.datetime(1)), char(ds.datetime)));
ds.consecutiveHour = round(daysdif(char(ds.datetime(1)), char(ds.datetime)) * 24);


end

