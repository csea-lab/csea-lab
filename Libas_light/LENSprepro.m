function [powbsl, faxis, taxis, elecs, badchannels] = LENSprepro(filepath, trialvec, elocsXYZ,plotflag)
%LENSprepro reads bdf file from project lens into matlab, cuts epochs and
%organizes in 3-d format


datamat3d = []; 
EEG = pop_biosig(filepath, 'channels',[1:8 10:16 19:20 22:25] ,'importevent','off');
EEG = eeg_checkset( EEG );

EEG = pop_chanevent(EEG, 21,'edge','leading','edgelen',0);
EEG = eeg_checkset( EEG );
trigname = EEG.event.type

%EEG = pop_epoch( EEG, {  trigname }, [-1  5], 'newname', 'EDF file epochs', 'epochinfo', 'yes'); for 2to 12

EEG = pop_epoch( EEG, {  trigname }, [-1  5], 'newname', 'EDF file epochs', 'epochinfo', 'yes');

EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-1000     0]);
EEG = eeg_checkset( EEG );

EEG = pop_runica(EEG, 'extended',1,'interupt','on');



datamat3d = EEG.data;

badchannels = [];

datamat3d = datamat3d(:,:, trialvec);

% find and interpolate bad channels

[datamat3d, badchannels] = CleanChans3d(datamat3d, elocsXYZ); 


% caluclate three metrics of data quality at the trial level
    
    absvalvec = squeeze(median(median(abs(datamat3d),2'))); % Median absolute voltage value for each trial
    % here on
    stdvalvec = squeeze(median(std(datamat3d,[],2))); % SD of voltage values
    
    maxtransvalvec = squeeze(median(max(diff(datamat3d, 2),[], 2))); % Max diff (??) of voltage values
    
    % calculate compound quality index and discard outlier trials
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec;
    
    badindex = find(qualindex > 2.* median(qualindex)); 
    
    datamat3d(:, :, badindex) = []; 
    
    % calculate remaining number of trials
    qualindex(qualindex > 2.5.* median(qualindex)) = [];
    
    NGoodtrials = length(qualindex)
    
    badchannels = badchannels
    
    % average reference each trial; 
    
    datamat3d_AR = zeros(size(datamat3d,1)+1, size(datamat3d,2), size(datamat3d,3)); 
    
    for trialind2 = 1:size(datamat3d, 3)
        
        datamat3d_AR(:, :, trialind2) = avg_ref_add(datamat3d(:, :, trialind2)); 
        
    end
 
 %% end of artifact correction, NOW:   
% perform wavelet analysis 
 %%%  
 % freqs in Hz (what the user wants)
fstart_Hz = 3;
fend_Hz = 24;
fstep_Hz = 1; 
 
% metrics computed from data and sanity checks: 
taxis = EEG.times; 
elecs = EEG.chanlocs; 
fsamp = EEG.srate
NPoints = size(datamat3d_AR,2)
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

[WaPower] = wavelet_app_mat_plusalpha(datamat3d_AR, fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  [filepath '_' num2str(trialvec(1))]);

% find a good baseline segment:
[dummy, bslbegin]= min(abs(taxis-(-800)))
[dummy, bslend]= min(abs(taxis-(-300)))

[powbsl] = bslcorrWAMat_div(WaPower, bslbegin:bslend).*100-100;

eval(['save ' filepath '.pow3bsl.mat powbsl'])

if plotflag,  
    elecs(21).labels = 'EEG Pz'
for x = 1:size(WaPower, 1);
 contourf(EEG.times(100:1600), faxis, squeeze(powbsl(x,100:1600,:))'), colorbar, title(elecs(x).labels), pause(.1)
end
end

% 

