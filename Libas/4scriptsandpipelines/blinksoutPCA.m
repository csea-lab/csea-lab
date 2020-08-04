% gets rid of major artifacts using PCA
% read data
% 
filename = 'vespalena_104.EEGnoICA.set'; 

EEG = pop_loadset(filename);

data = EEG.data;

blinks = data(:, 1:5000);

plot(blinks'); 

[coeff, score, latent, tsquared, explained, mu] = pca(blinks');

topomap([coeff(:, 1); 0])

subplot(2,1,1), plot(score(:, 1:128))

subplot(2,1,2), plot(score(:, 2:128))

% great now we have scores for only the blink segment at the beginning, yay
% now we hand compute new scores fro the same components but for the whole
% time series 

scorenew = coeff'*data; % note that coeff is transposed !! it is !! look for the small ' sign 

figure; 

subplot(3,1,1), plot(scorenew(1:128, :)')

subplot(3,1,2), plot(scorenew(2:128, :)')

subplot(3,1,3), plot(scorenew(3:128, :)')

% great now project back to the data without the annoying components. 
% here it is the first 3

scorenew_flip = scorenew'; 

datanew = scorenew_flip(:, 3:128) * coeff(3:128,:); % THis gets rid of the first 2 comps

%datanew = scorenew_flip(:, 2:128) * coeff(2:128,:); % THis gets rid of the
%first component

datanew = datanew'; 





