function [epochmat] = raw2mat(rawfilemat, samples2use)

    for index = 1:size(rawfilemat,1)
        rawfile = deblank(rawfilemat(index,:))
        orig = ft_read_data(rawfile);
        orig = orig(:, samples2use);
        % find bad channels and throw away
        stdvecchan = std(orig'); 
        orig(stdvecchan > 300, :)=0; 
        orig_ar = avg_ref_add(orig); clear orig; 
        orig_ar = orig_ar(:, 1:30000); 
        % if CSD is wanted
%         csdmat = Mat2Csd(orig_ar, 2, '129.ecfg'); clear orig_ar;
%         orig_ar = csdmat; 
        
        %find bad segments
        epochmat = reshape(orig_ar, [129 500 60]); % 60 segments with 500 sample point = 2 secs
        clear csmat;
        stdvec = squeeze(median(std(epochmat)));
        badindex = find(stdvec > median(stdvec) .* 1.4) 
        epochmat(:, :, badindex) = [];
        
        save([rawfile '.mat'], 'epochmat');
    end
 