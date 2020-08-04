function [ EEG, taxis, faxis, goodtrialvector ] = AndreaWaveletTertiles( filemat, plotflag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for fileindex = 1:size(filemat,1); 
    
    filepath = deblank(filemat(fileindex,:))
    
        EEG = pop_loadset(filepath); 

        datamat = double(EEG.data); 
        
         [datamat] = replacezerochan(datamat); 
        
        [ datamat ] = imputebslandrea( datamat );

        [ datamat ] = scadsAK_3dtrials(datamat);
        
        goodtrialvector(fileindex) =  size(datamat,3); 
        
        NGoodtrials = size(datamat,3); 
        
        firsttertile = 1: round(NGoodtrials./3); 
        sectertile =  round(NGoodtrials./3):2*floor(NGoodtrials./3); 
        thirdtertile = 2*floor(NGoodtrials./3): NGoodtrials; 
        
        disp('n of good trials: ')
        NGoodtrials
        size(datamat)
        disp('tertiles: ')
        round(NGoodtrials./3)
        pause(1)
        

        % perform wavelet analysis 
         %%%  
         % freqs in Hz (what the user wants)
        fstart_Hz = 3;
        fend_Hz = 30;
        fstep_Hz = 1; 

        % metrics computed from data and sanity checks: 
        taxis = EEG.times; 
        elecs = EEG.chanlocs; 
        fsamp = EEG.srate
        NPoints = size(datamat,2)
        timeinms=NPoints .* (1000/fsamp);
        timefromEEGLab = range(taxis)+1000/fsamp;

        if round(timefromEEGLab)~= round(timeinms), error('something is wrong with the timing/epoching'), end; 

        freqRes = 1000/timeinms;
        faxistotal = 0:freqRes:fsamp/2;

        % find real frequency indices: 
        [dummy, fstart]= min(abs(faxistotal-fstart_Hz));
        [dummy, fend]= min(abs(faxistotal-fend_Hz));
        [dummy, fstep] = min(abs(faxistotal-1));

        % this is the actual frequency range in HZ
        faxis = (freqRes.*fstart:freqRes.*fstep:freqRes.*fend) - freqRes

        % find alpha range in this vector: 
        [dummy, alphabegin]= min(abs(faxis-8));
        [dummy, alphaend]= min(abs(faxis-12.5));

        [WaPower1, PLI, PLIdiff, alphapowertrial]  = wavelet_app_mat_tertile(datamat(:, :,firsttertile) , fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  filepath);
        [WaPower2, PLI, PLIdiff, alphapowertrial]  = wavelet_app_mat_tertile(datamat(:, :,sectertile), fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  filepath);
        [WaPower3, PLI, PLIdiff, alphapowertrial]  = wavelet_app_mat_tertile(datamat(:, :,thirdtertile), fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  filepath);

        % find a good baseline segment:
        [dummy, bslbegin]= min(abs(taxis-(-400)))
        [dummy, bslend]= min(abs(taxis-(-60)))

        [powbsl1] = bslcorrWAMat_div(WaPower1, bslbegin:bslend).*100-100;
        [powbsl2] = bslcorrWAMat_div(WaPower2, bslbegin:bslend).*100-100;
        [powbsl3] = bslcorrWAMat_div(WaPower3, bslbegin:bslend).*100-100;

        eval(['save ' filepath '.pow3bsl.1.mat powbsl1'])
       eval(['save ' filepath '.pow3bsl.2.mat powbsl2'])
       eval(['save ' filepath '.pow3bsl.3.mat powbsl3'])

        if plotflag,  
            elecs(19).labels = 'EEG Pz'
        for x = 1:size(WaPower1, 1);
         contourf(EEG.times(100:end-100), faxis, squeeze(powbsl1(x,100:end-100,:))'), colorbar, title(elecs(x).labels), pause(1)
        end
        end
end
% 



