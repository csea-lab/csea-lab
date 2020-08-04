for freq = 1:10
    a = ReadAvgFile(deblank(filemat(freq,:))); 
    peaktopo(:, freq) = mean(a(:, 600:900), 2); 
end

SaveAvgFile('peaktopos_tuning_lowcontrast1to10.at', peaktopo); 
