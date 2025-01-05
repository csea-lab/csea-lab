function [ssveptotal] = DUCmodel(params,taxis)

baselinelength = 500; 
signallength = length(taxis)-baselinelength; 
ramp = 100; % a meta parameter for the duration of the onset
baseline1 = zeros(1,baselinelength); % duration of distractor bsl 
baseline2 = zeros(1,baselinelength); % duration of task bsl 

% params(1) = maximum level1
% params(2) = maximum level2
% params(3) = early response
% params(4) = early interference from distractor
% params(5) = late reciprocal interference

a = [baseline1  params(1) .* cosinwin(ramp, signallength)];
b = [baseline2  params(2) .* cosinwin(ramp, signallength)];

 earlyinterference = [baseline1 cosinwin(ramp, ramp.*3) zeros(1,signallength-ramp.*3)].*params(3); 
lateinterference = [baseline1 zeros(1, ramp.*3) cosinwin(ramp,signallength-ramp.*3)].*params(5); 

% adding a sixth parameter for latency variability makes fits worse
%earlyinterference = [baseline1 cosinwin(ramp, params(6)) zeros(1,signallength-round(params(6))-ramp)].*params(3); 
% lateinterference = [baseline1 zeros(1, round(params(6))) cosinwin(ramp,signallength-params(6))].*params(5); 

ssvep_distractor = a + earlyinterference + lateinterference;  
ssvep_task = b + earlyinterference.*params(4) - lateinterference; 

ssveptotal = [ssvep_distractor ssvep_task]; 


