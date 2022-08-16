function [SNRmat] = get_SNR_mat(filemat, noisebins)


for fileindex = 1 : size(filemat, 1)

    outname  = [deblank(filemat(fileindex,:)) '.SNR.mat']; 

    a = load(deblank(filemat(fileindex,:))); 

    data = eval(['a.' char(fieldnames(a))]);
        
    SNRmat = data./repmat(mean(data(:, noisebins),2), 1, size(data,2)); 
    
    save(outname, 'SNRmat')
			
	end
		
