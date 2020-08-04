%% RESS empirical example


clear

%% specify parameters

% the experiment had 6 and 8.57 Hz
peakfreq1 = 6; % hz
peakfreq1 = 8.57; % hz

% used for 'best-electrode' analyses
electrode1 = 60;
electrode2 = 69;

% condition number, see below
cond2use  = []; 

%sample rate and channels
EEG.srate = 1000; 
EEG.nbchan = 112; 

% parameters for RESS:
peakwidt  = .5; % FWHM at peak frequency
neighfreq = 1;  % distance of neighboring frequencies away from peak frequency, +/- in Hz
neighwidt = 1;  % FWHM of the neighboring frequencies

%% load in the data

% contains EEG data (in eeglab format) and leadfield information, which is
% used to create the anatomical estimations.

load subj138_20191123_020853.fl30h2.E1.appg.mat

%% condition markers
% for now we use all trials

%% Start RESS 

% FFT parameters

tidx = [1267 3600]; % we use data from .5-10 seconds, to avoid using the stimulus transient
%nfft = ceil( EEG.srate/.1 ); % .1 Hz resolution
nfft = ceil( EEG.srate/(1000./diff(tidx)) ); % native FFT resolution given segment length (Bach/Meigen)

% extract EEG data
data  = outmat(1:2:224,:, :); 
dataX = mean(abs( fft(data(:,tidx(1):tidx(2),:),nfft,2)/diff(tidx) ).^2,3);
hz    = linspace(0,1000,nfft);

% compute covariance matrix at peak frequency
fdatAt = filterFGx(data,EEG.srate,peakfreq1,peakwidt);
fdatAt = reshape( fdatAt(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatAt = bsxfun(@minus,fdatAt,mean(fdatAt,2));
covAt  = (fdatAt*fdatAt')/diff(tidx);

% compute covariance matrix for lower neighbor
fdatLo = filterFGx(data,EEG.srate,peakfreq1+neighfreq,neighwidt);
fdatLo = reshape( fdatLo(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatLo = bsxfun(@minus,fdatLo,mean(fdatLo,2));
covLo  = (fdatLo*fdatLo')/diff(tidx);

% compute covariance matrix for upper neighbor
fdatHi = filterFGx(data,EEG.srate,peakfreq1-neighfreq,neighwidt);
fdatHi = reshape( fdatHi(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatHi = bsxfun(@minus,fdatHi,mean(fdatHi,2));
covHi  = (fdatHi*fdatHi')/diff(tidx);

% perform generalized eigendecomposition. This is the meat & potatos of RESS
[evecs,evals] = eig(covAt,(covHi+covLo)/2);
[~,comp2plot] = max(diag(evals)); % find maximum component
evecs = bsxfun(@rdivide,evecs,sqrt(sum(evecs.^2,1))); % normalize vectors (not really necessary, but OK)

% extract components and force sign
% maps = inv(evecs'); % get maps (this is fine for full-rank matrices)
maps = covAt * evecs / (evecs' * covAt * evecs); % this works either way
[~,idx] = max(abs(maps(:,comp2plot))); % find biggest component
maps = maps * sign(maps(idx,comp2plot)); % force to positive sign

% reconstruct RESS component time series
ress_ts1 = zeros(size(data,2),size(data,3));
for ti=1:size(data,3)
    ress_ts1(:,ti) = evecs(:,comp2plot)'*squeeze(data(:,:,ti));
end

%% compute SNR spectrum

ressx = mean(abs( fft(ress_ts1(tidx(1):tidx(2),:),nfft,1)/diff(tidx) ).^2,2);
elecx = dataX(electrode1,:,:);

[snrR,snrE] = deal(zeros(size(hz)));
skipbins =  5; % .5 Hz, hard-coded!
numbins  = 20+skipbins; %  2 Hz, also hard-coded!

% loop over frequencies and compute SNR
for hzi=numbins+1:length(hz)-numbins-1
    numer = ressx(hzi);
    denom = mean( ressx([hzi-numbins:hzi-skipbins hzi+skipbins:hzi+numbins]) );
    snrR(hzi) = numer./denom;
    
    numer = elecx(hzi);
    denom = mean( elecx([hzi-numbins:hzi-skipbins hzi+skipbins:hzi+numbins]) );
    snrE(hzi) = numer./denom;
end

%% estimate anatomical distribution

beamsource = zeros(3,size(lf.Gain,3));
for voxi=1:size(lf.Gain,3)
    for ori=1:3
        beamsource(ori,voxi) = corr( maps(:,comp2plot) , squeeze(lf.Gain(:,ori,voxi)) );
    end
end
forw_brain = sqrt(sum(beamsource.^2));

%% some plotting...

figure(1), clf
xlim = [3 22];

subplot(241)
plot(hz,snrR,'ro-','linew',1,'markersize',5,'markerface','w')
hold on
plot(hz,snrE,'ko-','linew',1,'markersize',5,'markerface','w')
set(gca,'xlim',xlim)
axis square
xlabel('Frequency (Hz)'), ylabel('SNR')
legend({'RESS';electrode1})

subplot(242)
map2plot = maps(:,comp2plot);
topoplot(map2plot./max(map2plot),EEG.chanlocs,'maplimits',[-.7 .7],'numcontour',0,'conv','on','electrodes','off','shading','interp');
title([ 'RESS for ' num2str(peakfreq1) ' Hz' ])

subplot(243)
map2plot = dataX(:,dsearchn(hz',peakfreq1));
topoplot(map2plot./max(map2plot),EEG.chanlocs,'maplimits',[-.7 .7],'numcontour',0,'conv','on','electrodes','off','emarker2',{find(strcmpi({EEG.chanlocs.labels},electrode1)) 'o' 'w' 4},'shading','interp');
title([ 'RESS for ' num2str(peakfreq1) ' Hz' ])
title([ 'Electrode power at ' num2str(peakfreq1) ' Hz' ])



subplot(244)
% convert scalar colors to RGB
cmap = colormap;
cid = sum(bsxfun(@gt,forw_brain,linspace(0,1,length(cmap))'));
newcol = cmap(cid,:);

% threshold map at >median
thresh = median(forw_brain) + std(forw_brain)*0;
newcol(forw_brain<thresh,:) = repmat(.7,sum(forw_brain<thresh),3);

h = patch(lf.p);
set(h,'FaceVertexCData',newcol,'facecolor','flat','edgecolor','none')
axis image, axis off, rotate3d on

light, lightangle(-90,25), material shiny
view([-30 30])
% zoom(1.4) % computer-dependent

%% now repeat for the other frequency/condition

% compute covariance matrix at peak frequency
fdatAt = filterFGx(data,EEG.srate,peakfreq2,peakwidt);
fdatAt = reshape( fdatAt(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatAt = bsxfun(@minus,fdatAt,mean(fdatAt,2));
covAt  = (fdatAt*fdatAt')/diff(tidx);

% compute covariance matrix for lower neighbor
fdatLo = filterFGx(data,EEG.srate,peakfreq2+neighfreq,neighwidt);
fdatLo = reshape( fdatLo(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatLo = bsxfun(@minus,fdatLo,mean(fdatLo,2));
covLo  = (fdatLo*fdatLo')/diff(tidx);

% compute covariance matrix for upper neighbor
fdatHi = filterFGx(data,EEG.srate,peakfreq2-neighfreq,neighwidt);
fdatHi = reshape( fdatHi(:,tidx(1):tidx(2),:), EEG.nbchan,[] );
fdatHi = bsxfun(@minus,fdatHi,mean(fdatHi,2));
covHi  = (fdatHi*fdatHi')/diff(tidx);

% perform generalized eigendecomposition. This is the meat & potatos of RESS
[evecs,evals] = eig(covAt,(covHi+covLo)/2);
[~,comp2plot] = max(diag(evals)); % find maximum component
evecs = bsxfun(@rdivide,evecs,sqrt(sum(evecs.^2,1))); % normalize vectors (not really necessary, but OK)

% extract components and force sign
% maps = inv(evecs'); % get maps (this is fine for full-rank matrices)
maps = covAt * evecs / (evecs' * covAt * evecs); % this works either way
[~,idx] = max(abs(maps(:,comp2plot))); % find biggest component
maps = maps * sign(maps(idx,comp2plot)); % force to positive sign


% reconstruct RESS component time series
ress_ts2 = zeros(EEG.pnts,size(data,3));
for ti=1:size(data,3)
    ress_ts2(:,ti) = evecs(:,comp2plot)'*squeeze(data(:,:,ti));
end

%% compute SNR spectrum

ressx = mean(abs( fft(ress_ts2(tidx(1):tidx(2),:),nfft,1)/diff(tidx) ).^2,2);
elecx = dataX(strcmpi(electrode2,{EEG.chanlocs.labels}),:,:);


[snrR,snrE] = deal(zeros(size(hz)));
skipbins =  5; % .5 Hz, hard-coded!
numbins  = 20+skipbins; %  2 Hz, also hard-coded!

% loop over frequencies and compute SNR
for hzi=numbins+1:length(hz)-numbins-1
    numer = ressx(hzi);
    denom = mean( ressx([hzi-numbins:hzi-skipbins hzi+skipbins:hzi+numbins]) );
    snrR(hzi) = numer./denom;
    
    numer = elecx(hzi);
    denom = mean( elecx([hzi-numbins:hzi-skipbins hzi+skipbins:hzi+numbins]) );
    snrE(hzi) = numer./denom;
end

%% estimate anatomical distribution

beamsource = zeros(3,size(lf.Gain,3));
for voxi=1:size(lf.Gain,3)
    for ori=1:3
        beamsource(ori,voxi) = corr( maps(:,comp2plot) , squeeze(lf.Gain(:,ori,voxi)) );
    end
end
forw_brain = sqrt(sum(beamsource.^2));

%% some plotting...

subplot(245)
plot(hz,snrR,'ro-','linew',1,'markersize',5,'markerface','w')
hold on
plot(hz,snrE,'ko-','linew',1,'markersize',5,'markerface','w')
set(gca,'xlim',xlim)
axis square
xlabel('Frequency (Hz)'), ylabel('SNR')
legend({'RESS';electrode2})

subplot(246)
map2plot = maps(:,comp2plot);
topoplot(map2plot./max(map2plot),EEG.chanlocs,'maplimits',[-.7 .7],'numcontour',0,'conv','on','electrodes','off','shading','interp');
title([ 'RESS for ' num2str(peakfreq2) ' Hz' ])

subplot(247)
map2plot = dataX(:,dsearchn(hz',peakfreq2));
topoplot(map2plot./max(map2plot),EEG.chanlocs,'maplimits',[-.7 .7],'numcontour',0,'conv','on','electrodes','off','emarker2',{find(strcmpi({EEG.chanlocs.labels},electrode2)) 'o' 'w' 4},'shading','interp');
title([ 'RESS for ' num2str(peakfreq2) ' Hz' ])
title([ 'Electrode power at ' num2str(peakfreq2) ' Hz' ])



subplot(248)
% convert scalar colors to RGB
cmap = colormap;
cid = sum(bsxfun(@gt,forw_brain,linspace(0,1,length(cmap))'));
newcol = cmap(cid,:);

% threshold map at >median
thresh = median(forw_brain) + std(forw_brain)*0;
newcol(forw_brain<thresh,:) = repmat(.7,sum(forw_brain<thresh),3);

h = patch(lf.p);
set(h,'FaceVertexCData',newcol,'facecolor','flat','edgecolor','none')
axis image, axis off, rotate3d on

light, lightangle(-90,25), material shiny
view([-30 30])
% zoom(1.4) % computer-dependent

