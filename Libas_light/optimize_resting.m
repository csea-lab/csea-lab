function [spec1, spec2, freqs] = optimize_resting(filemat, locations); 

for fileindex = 1:size(filemat,1); 
    
    filepath = deblank(filemat(fileindex,:))
    
        dataraw = ft_read_data(filepath); 

        dataraw = dataraw(1:32,:); 

        % artifact control
         [dataraw] =SCADS_AK(dataraw, locations); disp(size(dataraw))

        dataraw = avg_ref_add(dataraw); 

        dataraw = dataraw(1:32,:)'; 

        [A, B] = butter(4, [0.001 .15]);

        datafilt = filtfilt(A, B, dataraw(:, 1:32))';

        plot(datafilt(10,1:10000)), pause(1)


        %%% first half analysis: 

        firsthalfmat = datafilt(:, 1001:46000); 

        epochmat1 = reshape(firsthalfmat, [32 1000 45]); % 60 segments with 500 sample point = 2 secs
        stdvec1 = squeeze(median(std(epochmat1)))
        badindex1 = find(stdvec1 > median(stdvec1) .* 1.5) 

        % to find out size of the spectrum
        [pow1, phase, freqs] = FFT_spectrum(epochmat1(:, :, 1), 500);
        specmat = zeros(size(pow1)); 

        % perform fft
        for epochindex = 1:45

            [pow, phase, freqs] = FFT_spectrum(squeeze(epochmat1(:, :, epochindex)), 500);
            if ~ismember(epochindex, badindex1)
            specmat = specmat+pow;       
            end
        end

        spec1 = specmat./(45 -length(badindex1));

         fsmapnew = 1000./(500./size(spec1,2));

            [File,Path,FilePath]=SaveAvgFile([filepath '.spec1'],spec1,[],[], fsmapnew);

        %%% second half analysis: 

        sechalfmat = datafilt(:, 46001:91000); 

        epochmat2 = reshape(sechalfmat, [32 1000 45]); % 60 segments with 500 sample point = 2 secs
        stdvec2 = squeeze(median(std(epochmat2)))
        badindex2 = find(stdvec2 > median(stdvec2) .* 1.5) 

        % to find out size of the spectrum
        [pow2, phase, freqs] = FFT_spectrum(epochmat1(:, :, 1), 500);
        specmat = zeros(size(pow2)); 

        % perform fft
        for epochindex = 1:45

            [pow, phase, freqs] = FFT_spectrum(squeeze(epochmat2(:, :, epochindex)), 500);
            if ~ismember(epochindex, badindex2)
            specmat = specmat+pow;       
            end
        end

        spec2 = specmat./(45 -length(badindex2));

      fsmapnew = 1./(freqs(2)-freqs(1)).*1000;

            [File,Path,FilePath]=SaveAvgFile([filepath '.spec2'],spec2,[],[], fsmapnew);

         for x = 1:32, plot(freqs(1:40), spec1(x,1:40)), hold on, plot(freqs(1:40), spec2(x,1:40), 'r'), title(num2str(x)), pause(.4), hold off, end

end % files

