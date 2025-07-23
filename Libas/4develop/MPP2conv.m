function [convmat_stick] = MPP2conv(MPP, gausswinlength)

% make output empty
convmat_stick = zeros(size(MPP,2), 1500); 
convmat_pow = []; 

gwin = gausswin(gausswinlength);


for trialindex = 1:size(MPP,2)
    convmat_stick(trialindex, MPP(trialindex).Trials.tau) = 1; 
end
% 
% % collect all power
% powmat = [];
% for trialindex = 1:size(MPP,2)
%     powmat(trialindex,:) = [powmat(trialindex,:)  MPP(trialindex).Trials.pow];
% end
% 

% 
% % combine tau and power
% taupowervector = zeros(1,1500);
% taupowervector(tauvector) = powvector;
% 
% % convolution 1: power not used
% taustickvector = zeros(1,1500);
% taustickvector(tauvector) = 1;
% tauconvector = conv(taustickvector, gwin, 'same');
% 
% % convolution 2: power used
% taupowerconvector = conv(taupowervector, gwin, 'same');
% convmat_stick = [convmat_stick; tauconvector];
% convmat_pow = [convmat_pow; taupowerconvector];


end % function

% save ([filemat(1, 1:10), '.stickcon.mat'], 'convmat_stick')
% save ([filemat(1, 1:10), '.powcon.mat'], 'convmat_pow')
