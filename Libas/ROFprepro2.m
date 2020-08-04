function [powbsl, faxis, taxis, elecs, badchannels] = ROFprepro2( EEG, components2remove, filepath, plotflag)
% removes bad components from data (from ROFrepro1)
% converts to 3d mat
% does channel and trial clean-up
% performs wavelet analysis

EEG = pop_subcomp( EEG, components2remove, 0);

datamat3d = EEG.data;

% use SCADS to get rid of bad channels first

[outmat3d, interpsensvec] = scadsAK_3dchan(datamat3d, EEG.chanlocs); 
 
% average reference each trial and add Pz back
    
    datamat3d_AR = zeros(size(outmat3d,1)+1, size(outmat3d,2), size(outmat3d,3)); 
    
    for trialind2 = 1:size(outmat3d, 3)
        
        datamat3d_AR(:, :, trialind2) = avg_ref_add(outmat3d(:, :, trialind2)); 
        
    end

% use SCADS to get rid of bad trials now

[ datamat3d_AR, badchannels ] = scadsAK_3dtrials(datamat3d_AR);


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

[WaPower, PLI, PLIdiff, alphapowertrial]  = wavelet_app_mat_plusalpha(datamat3d_AR, fsamp, fstart, fend, fstep, alphabegin, alphaend, [],  filepath);

% find a good baseline segment:
[dummy, bslbegin]= min(abs(taxis-(-800)))
[dummy, bslend]= min(abs(taxis-(-300)))

[powbsl] = bslcorrWAMat_div(WaPower, bslbegin:bslend).*100-100;

eval(['save ' filepath '.pow3bsl.mat powbsl'])

if plotflag,  
    elecs(21).labels = 'EEG Pz'
for x = 1:size(WaPower, 1);
 contourf(EEG.times(100:1600), faxis, squeeze(powbsl(x,100:1600,:))'), colorbar, title(elecs(x).labels), pause
end
end

% 








