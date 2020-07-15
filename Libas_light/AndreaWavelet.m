function [ EEG, taxis, faxis, goodtrialvector ] = AndreaWavelet( filemat, plotflag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for fileindex = 1:size(filemat,1); 
    
    filepath = deblank(filemat(fileindex,:))
    
        EEG = pop_loadset(filepath); 

        datamat = double(EEG.data); 
        
         [datamat] = replacezerochan(datamat); 
        
        [ datamat ] = imputebslandrea( datamat );

        [ datamat, NGoodtrials ] = scadsAK_3dtrials(datamat);
        
        size(datamat)
        
        pause
        
        goodtrialvector(fileindex) = NGoodtrials; 
        
        datamat = avg_ref_3d(datamat);

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

        [WaPower, PLI, PLIdiff, alphapowertrial]  = wavelet_app_mat_plusalpha(datamat, fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  filepath);

        % find a good baseline segment:
        [dummy, bslbegin]= min(abs(taxis-(-400)))
        [dummy, bslend]= min(abs(taxis-(-60)))

        [powbsl] = bslcorrWAMat_div(WaPower, bslbegin:bslend).*100-100;

        eval(['save ' filepath '.pow3bsl.mat powbsl'])

        if plotflag,  
        %    elecs(19).labels = 'EEG Pz'
        for x = 1:size(WaPower, 1);
         contourf(EEG.times(100:end-100), faxis, squeeze(powbsl(x,100:end-100,:))'), colorbar, title(elecs(x).labels), pause(1)
        end
        end
end
% 



