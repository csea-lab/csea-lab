function [ssveptotal] = BiasedCompmodel(params,taxis)

ramp = 600;
baseline1 = zeros(1,6000);
baseline2 = zeros(1,6000); 

% params(1) = level1, aka drive 1
% params(2) = level2, aka drive 2
% params(3) = early response
% params(4) = gain
% params(5) = bias

a = [baseline1  cosinwin(ramp, length(taxis))];
b = [baseline2  params(2) .* cosinwin(ramp, length(taxis))];

earlyresponse = [baseline1 cosinwin(ramp, ramp.*3) zeros(1,length(taxis)-ramp.*3)].*params(3); 

normalization1 = (a + earlyresponse);
normalization2 = b + earlyresponse;

% figure(2)
% plot(normalization1)
% hold on 
% plot(normalization2)


ssvep_distractor = params(1) .* normalization1 ./ (params(4).*(normalization1 + normalization2));
ssvep_task = params(2) .* normalization2 ./ (params(4).*(normalization1 + normalization2));

ssveptotal = [ssvep_distractor ssvep_task]; 


