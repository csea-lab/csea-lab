function [activationpattern] = haufemapweights(data,targetvariable)
%computes covariance between data and target variable for each channel, to
%map classification weights according to haufe
% data are 3-d: sensors by time points, by trials
% targetvariable is the labels, as column vector

for timepoint = 1:size(data,2) 
    xt = squeeze(data(:, timepoint, :)); 
    for channel = 1:size(data,1)
    temp = cov(xt(channel, :)', targetvariable); activationpattern(channel, timepoint) = temp(2,1); 
    end
end


