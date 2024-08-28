function [ssveptotal] = BiasedCompmodel(params,taxis)

ramp = 600;
baseline1 = zeros(1,6000);
baseline2 = zeros(1,6000); 

% params(1) = level1, aka drive 1
% params(2) = level2, aka drive 2
% params(3) = early response
% params(4) = gain
% params(5) = bias/scaling factor

a = [baseline1  params(1) .*cosinwin(ramp, length(taxis))];
b = [baseline2  params(2) .* cosinwin(ramp, length(taxis))];

earlyresponse = [baseline1 cosinwin(ramp, ramp.*3) zeros(1,length(taxis)-ramp.*3)].*params(3); 

normalization1 = (a + earlyresponse.*params(4) ).* params(5);
normalization2 = (b + earlyresponse).* -params(5);
 
 ssvep_distractor =  normalization1;
 ssvep_task =  normalization2; 
 
ssveptotal = [ssvep_distractor ssvep_task]; 

