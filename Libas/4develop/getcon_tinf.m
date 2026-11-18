function [convec] = getcon_tinf(datfilepath1, modality)

   % Validate the second input argument
    if nargin < 2
        error('Please specify the modality as ''eeg'' or ''pupil''.');
    end

datfilepath2 = datfilepath1; 
datfilepath2(8) = '2';         

datfilepath3 = datfilepath1;
datfilepath3(5:9) = 'Learn'; 

datfilepath4 = datfilepath3;
datfilepath4 = [datfilepath3(1:4) 'test' datfilepath3(10:end)]; 

a = readtable(datfilepath1); %Baseline 1
b = readtable(datfilepath2); %Baseline 2
c = readtable(datfilepath3); %Learn phase
d = readtable(datfilepath4); %Test

% Define the valid categories
categories = {'A','B','C','D','E'};

% Safely map strings to integers 1-5. Any unmatched strings will become NaN
[~, convec1] = ismember(table2cell(a(:,4)), categories);
convec1 = 10+convec1;

[~, convec2] = ismember(table2cell(b(:,4)), categories);
convec2 = 40+convec2;

% Check if there were any unmatched elements causing zeros
if any(convec1 == 0) || any(convec2 == 0)
    warning('Some markers in column 4 did not match A, B, C, D, or E!');
end


%Only use for EEG not pupil (eyetracker does not get response times so no need to
%double these rows); Ask Andreas about an easier way to record this info
% convec3 = repelem(double(c{:,4}), 2);
% convec3 = 20+convec3;
% 
% convec4 = repelem(double(d{:,4}), 2);
% convec4 = 30+convec4;
% 
% convec3 = 20 + c{:,4};
% convec4 = 30 + d{:,4};


   % Calculate Learn (convec3) and Test (convec4) based on modality
    if strcmpi(modality, 'eeg')
        convec3 = repelem(double(c{:,4}), 2);
        convec3 = 20 + convec3;
        convec4 = repelem(double(d{:,4}), 2);
        convec4 = 30 + convec4;
    elseif strcmpi(modality, 'pupil')
        convec3 = 20 + double(c{:,4});
        convec4 = 30 + double(d{:,4});
    else
        error('Invalid modality: "%s". Use ''eeg'' or ''pupil''.', modality);
    end

convec = [convec1; convec3; convec4; convec2]; % in order of phase
