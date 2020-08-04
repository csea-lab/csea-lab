function raw2csd_spec(filemat)

for fileindex = 1:size(filemat,1)

name = deblank(filemat(fileindex,:))

orig = ft_read_data(name);
orig = orig(:, 175000:end);
orig_ar = avg_ref_add(orig);
csdmat = mat2csd(orig_ar, 2, '129.ecfg');

%determine number of segments

csdmat = csdmat(:,1:30000); 
epochmat = reshape(csdmat, [129 500 60]); % 60 segments with 500 sample point = 2 secs
stdvec = squeeze(median(std(epochmat)))
badindex = find(stdvec > median(stdvec) .* 1.5) 

 [pow, phase, freqs] = FFT_spectrum(epochmat(:, :, 1), 250);
 specmat = zeros(size(pow)); 

% perform fft
for epochindex = 1:60
    
    [pow, phase, freqs] = FFT_spectrum(squeeze(epochmat(:, :, epochindex)), 250);
    if ~ismember(epochindex, badindex)
        
    specmat = specmat+pow;   
    
    end
end

specavg = specmat./(60 -length(badindex));

% scale with frequency 
%specavg= bsxfun(@times, specavg, freqs');

 fsmapnew = 1000./(250./size(epochmat,2));
 
 SaveAvgFile([name '.at.csd.spec'],specavg,[],[], fsmapnew);
 
end