function [ssveptotal] = competmodel(params,taxis)

ramp = 200
%ramp = int8(abs(round(params(6))));

% params(1) = level1
% params(2) = level2
% params(3) = early response
% params(4) = early interference from distractor
% params(5) = late reciprocal interference

a = cosinwin(ramp, length(taxis)).* params(1);
b = cosinwin(ramp, length(taxis)).* params(2);

% plot(a), pause

earlyinterference = [cosinwin(ramp, ramp.*3) zeros(1,length(taxis)-ramp.*3)].*params(3); 
lateinterference = [zeros(1, ramp.*3) cosinwin(ramp,length(taxis)-ramp.*3)].*params(5); 

%plot(earlyinterference), pause
% plot(lateinterference), pause


ssvep_distractor = a + earlyinterference + lateinterference;  
ssvep_task = b + earlyinterference.*params(4) - lateinterference; 

ssveptotal = [ssvep_distractor; ssvep_task]; 


