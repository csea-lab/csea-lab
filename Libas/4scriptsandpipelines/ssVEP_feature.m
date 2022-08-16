% Condition descriptions:
% at1 = "no feature" control, all gray circles
% at2 = single feature - color, all red circles
% at3 = attend gray @ 8 Hz, combo gray/red circles
% at4 = attend red @ 12 Hz, combo gray/red circles
% at5 = single feature - shape, all gray squares
% at6 = attend circles @ 8 Hz, combo gray circles/gray squares
% at7 = attend squares @ 12 Hz, combo gray circles /gray squares
% 
% "Sophisticated" control version:
%   Combo 	vs	Control
% at3 @ 8 Hz	vs at1 @ 8 Hz
% at4 @ 12 Hz vs at2 @ 12 Hz
% at6 @ 8 Hz 	vs at1 @ 8 Hz
% at7 @ 12 Hz vs at5 @ 12 Hz
% 
%% shape
trials = [1:32];

data8Hz = snr8;

data12Hz = snr12;
 
attshape = squeeze([nanmean(data8Hz(trials, 6,:)) nanmean(data12Hz(trials, 7,:))])'; % select gray circles (1st col) and red circles
  
referenceshape = (squeeze([nanmean(data8Hz(trials, 1,:)) nanmean(data12Hz(trials, 5,:))])') ; % gray circles unattended and red circles unattended

referencecolor2 = (squeeze([nanmean(data8Hz(trials, 5,:)) nanmean(data12Hz(trials, 1,:))])') ; 

attcolorstd = attcolor ./ (referencecolor); 

ignorecolor = squeeze([nanmean(data8Hz(trials, 7,:)) nanmean(data12Hz(trials, 6,:))])'; 

ignorecolorstd = ignorecolor ./ (referencecolor); 
 
figure

subplot(2,1,1), bar([attcolor(:,1)  ignorecolor(:,1) referencecolor(:,1) referencecolor2(:,1)]),

subplot(2,1,2), bar([attcolor(:,2)  ignorecolor(:,2) referencecolor(:,2) referencecolor2(:,2)]),

outmat1 = [attcolor(:,1)  ignorecolor(:,1) referencecolor(:,1) referencecolor2(:,1)];

outmat2 = [attcolor(:,2)  ignorecolor(:,2) referencecolor(:,2) referencecolor2(:,2)];

outmat = [outmat1 outmat2]

%% color
trials = [1:32];

data8Hz = snr8;

data12Hz = snr12;
 
attcolor = squeeze([nanmean(data8Hz(trials, 3,:)) nanmean(data12Hz(trials, 4,:))])'; % select gray circles (1st col) and red circles
  
referencecolor = (squeeze([nanmean(data8Hz(trials, 1,:)) nanmean(data12Hz(trials, 2,:))])') ; % gray circles unattended and red circles unattended

referencecolor2 = (squeeze([nanmean(data8Hz(trials, 5,:)) nanmean(data12Hz(trials, 1,:))])') ; 

attcolorstd = attcolor ./ (referencecolor); 

ignorecolor = squeeze([nanmean(data8Hz(trials, 4,:)) nanmean(data12Hz(trials, 3,:))])'; 

ignorecolorstd = ignorecolor ./ (referencecolor); 
 
figure

subplot(2,1,1), bar([attcolor(:,1)  ignorecolor(:,1) referencecolor(:,1) referencecolor2(:,1)]),

subplot(2,1,2), bar([attcolor(:,2)  ignorecolor(:,2) referencecolor(:,2) referencecolor2(:,2)]),

outmat1 = [attcolor(:,1)  ignorecolor(:,1) referencecolor(:,1) referencecolor2(:,1)];

outmat2 = [attcolor(:,2)  ignorecolor(:,2) referencecolor(:,2) referencecolor2(:,2)];

outmat = [outmat1 outmat2]

%% shape 
