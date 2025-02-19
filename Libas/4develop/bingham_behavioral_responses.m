function [graded_response, percentcorr] = bingham_behavioral_responses(filepath) %filepath should be name of dat file; e.g., 'Facebor15HzGabor_6001.dat'
% this function makes a vector of graded participant responses. 
% 0 = no response
% 1 = correct response (correctly identified shift or no shift)
% 2 = incorrect response (said shift when none occured or said no shift
% when one occured)
% also calculates their percentage correct

table = readtable(filepath);
subtable = table(:, [5,6]);
data = table2array(subtable);
graded_response = zeros(size(data, 1), 1);

for trial = 1:size(data,1)
    participant_response = data(trial, 1);
    orientation_shift = data(trial, 2);

    if (orientation_shift == 1 | orientation_shift == 2) & participant_response == 1
        graded_response(trial) = 1; % participant correctly reports a change in orientation
    elseif (orientation_shift == 1 | orientation_shift == 2) & participant_response == 2
        graded_response(trial) = 2; % particpant incorrectly reports no change in orientation when one occured 
    elseif orientation_shift == 3 & participant_response == 1
        graded_response(trial) = 2; %
    elseif orientation_shift == 3 & participant_response == 2
        graded_response(trial) = 1;
    elseif participant_response == 0
         graded_response(trial) = 0;
    end
end

percentcorr = length(find(graded_response==1))./length(graded_response)