function[m_norm_length, m_raw,surrogate_mean ] = canolty(rawfilemat, srate)

    for index = 1:size(rawfilemat,1)
        rawfile = deblank(rawfilemat(index,:))
         orig = ft_read_data(rawfile);
        orig = orig(:, 175000:end);
        orig_ar = avg_ref_add(orig); clear orig; 
        csdmat = Mat2Csd(orig_ar, 2, '129.ecfg'); clear orig_ar;
        csdmat = csdmat(:,1:30000); 
        
        %find bad segments
        epochmat = reshape(csdmat, [129 500 60]); % 60 segments with 500 sample point = 2 secs
        clear csmat;
        stdvec = squeeze(median(std(epochmat)))
        badindex = find(stdvec > median(stdvec) .* 1.4) 
        epochmat(:, :, badindex) = [];
       matrix = reshape(epochmat, [129 500*(60-length(badindex)) 1]);

        numpoints=length(matrix); 		%% number of sample points in raw signal 
        numsurrogate=200; 			%% number of surrogate values to compare to actual value
        minskip=srate; 			%% time lag must be at least this big
        maxskip=numpoints-srate; 	%% time lag must be smaller than this

        skip=ceil(numpoints.*rand(numsurrogate*2,1)); 
        skip(find(skip>maxskip))=[]; 

        skip(find(skip<minskip))=[]; 
        skip=skip(1:numsurrogate,1); 
        surrogate_m=zeros(numsurrogate,1);


        %% HG analytic amplitude time series, 

        %amplitude=abs(hilbert(eegfilt(x,srate,80,150))); 

        [amplitude, dummy]=steadyHilbertMat(matrix, 25, [], 2, 1, srate);

        %% theta analytic phase time series, uses EEGLAB toolbox 

        %phase=angle(hilbert(eegfilt(x,srate,4,8)));
        [dummy, phase]=steadyHilbertMat(matrix, 7, [], 10, 1, srate);

        %% complex-valued composite signal 
        z=amplitude.*exp(i*phase); 

        %% mean of z over time, prenormalized value 
        m_raw=mean(z, 2); 

        %% compute surrogate values
        surrogate_m_mat = [];
        surrogate_amplitude = []; 
        for s=1:numsurrogate 
        surrogate_amplitude=[amplitude(:, skip(s):end) amplitude(:, 1:skip(s)-1)]; 
        surrogate_m=abs(mean(surrogate_amplitude.*exp(i*phase), 2)); if s/10 == round(s/10), fprintf('.'), end
        surrogate_m_mat = [surrogate_m_mat surrogate_m]; 
        end 

        %% fit gaussian to surrogate data, uses normfit.m from MATLAB Statistics toolbox 
        surrogate_mean = zeros(size(abs(m_raw))); 
        surrogate_std= zeros(size(abs(m_raw))); 
        
        for channel = 1:size(matrix,1); 
        [surrogate_mean(channel),surrogate_std(channel)]=normfit((surrogate_m_mat(channel,:))); 
        end
        

        %% normalize length using surrogate data (z-score) 
        m_norm_length=(abs(m_raw)-surrogate_mean)./surrogate_std; 
        m_norm_phase=angle(m_raw); 
        m_norm=m_norm_length.*exp(i*m_norm_phase);

        % save as emegs2d format
        SaveAvgFile([rawfile '.cfc'],m_norm_length,[],[], 1)
        fclose('all'); 

    end 
