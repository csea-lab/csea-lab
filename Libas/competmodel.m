function [ssveptotal] = competmodel(params,taxis)

ramp = 600;
baseline1 = zeros(1,6000);
baseline2 = zeros(1,6000); 

% params(1) = level1
% params(2) = level2
% params(3) = early response
% params(4) = early interference from distractor
% params(5) = late reciprocal interference

a = [baseline1  params(1) .* cosinwin(ramp, length(taxis))];
b = [baseline2  params(2) .* cosinwin(ramp, length(taxis))];

earlyinterference = [baseline1 cosinwin(ramp, ramp.*3) zeros(1,length(taxis)-ramp.*3)].*params(3); 
lateinterference = [baseline1 zeros(1, ramp.*3) cosinwin(ramp,length(taxis)-ramp.*3)].*params(5); 

ssvep_distractor = a + earlyinterference + lateinterference;  
ssvep_task = b + earlyinterference.*params(4) - lateinterference; 

ssveptotal = [ssvep_distractor ssvep_task]; 


