function [correctedERP, subtract1, prioreventdist] = Adjar(inputERP, ITIdistribution, NBinsITI)
% Adjar correction, method one, convilution through FFT 
% determine distribution of the pre-stim event intervals
histo = histcounts(ITIdistribution(ITIdistribution<600), NBinsITI, 'normalization', 'probability');
prioreventdist = [histo zeros(1, size(inputERP, 2) -length(histo))]; % the prior event distribution

subtract1 = zeros(size(inputERP));
% now the convolution in the frequency domain
for chan = 1:size(inputERP,1)
    temp = conv(prioreventdist, inputERP(chan,:));
    subtract1(chan,:) = temp(1:length(inputERP(chan,:)));
end

correctedERP = inputERP - subtract1;
