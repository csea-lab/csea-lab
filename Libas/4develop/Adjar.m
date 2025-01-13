function [correctedERP, subtract1, prioreventdist] = Adjar(inputERP, ITIdistribution, NBinsITI, trigpointSP)
% Adjar correction, method one, convilution through FFT 
% determine distribution of the pre-stim event intervals
histo = histcounts(ITIdistribution(ITIdistribution<600), NBinsITI, 'normalization', 'probability');
prioreventdist = [histo zeros(1, size(inputERP, 2) -length(histo))]; % the prior event distribution

subtract1 = zeros(size(inputERP));
% now the convolution in the frequency domain
for chan = 1:size(inputERP,1)
    fft1 = fft([inputERP(chan,trigpointSP:end) zeros(1,size(inputERP,2)-trigpointSP-1) ]);
    fft2 = fft(prioreventdist);
    fftprod = fft1 .* fft2;
    temp = ifft(fftprod);
    subtract1(chan,1:length(temp)) = temp;
end

correctedERP = inputERP - subtract1;
