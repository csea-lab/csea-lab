function [specavg,specallmat, freqs] = spatialfreq(picfilemat, visuangle)

%calulates spatial spectrum; plots indiviv spectrum and averages spectra of
%the same size as the first 
% unit is cpd

specsum = []; 
specallmat = []; 
count = 1; 


for index = 1:size(picfilemat, 1)
    
    picturemat = imread(deblank(picfilemat(index,:))); 
    
    if ndims(picturemat) > 2
        picturemat = picturemat(:,:,1); 
    end
    
    fsamp = (size(picturemat,1))./visuangle

% 2-d picturemat
% fsamp is spatial sample rate pet degree, e.g. 615 pixels per 10 degrees: 
% 61.5 pixels per deg 

%fullspectrum = (log10 (mean(abs((fft2(picturemat))).^2 ))); 
fullspectrum = ( (mean(abs((fft2(picturemat))).^2 ))); 
spectrum = fullspectrum(1:length(fullspectrum)./2-1); index

freqs = 0:fsamp/(max(size(picturemat))):fsamp/2; 

spectrum_norm = spectrum./mean(spectrum); 

if index == 1;
    specsum = spectrum_norm; 
else
    if size(spectrum_norm) == size(specsum); 
    specsum = specsum + spectrum_norm; count = count+1; 
    end
end

specallmat = [specallmat; spectrum_norm]; 

figure(1), loglog(freqs(1:50), spectrum_norm(1:50)), title(num2str(index)); 
pause

end

specavg = specsum./count; 