function [outmatparticipant] = hannahsingtrialscondispa(matfilepath, artiflogfilepath, datfilepath, plotflag)
% for a single subject, takes following INPUTS: 
% path to a file with single trial EEG, "matfilepath" 
% path to a file with trial indices of good trials, "artiflog.mat"
% path to a dat file
% a plotflag (1 or 0 ) to plot output (1) or not (0)


% data file stuff
a = load(matfilepath); % loads that person's data and creates 3_D matrix variable outmat
outmat = a.Mat3D; 

% vectors for data reduction
cluster4ssvep = [62 67 75 72 70 71 74 76 77 81 82 83]; % for the ssvep
cluster4alpha = [72 62 61 67 72 77 78 71 76]; % 
frequencybinsalpha = 8:10; 

% get a condition vector
[conditionvec]=get_condispas(datfilepath);

% get participant # and trial
logfile = readtable(datfilepath);
participantID = table2array(logfile(1:350, 1));
trial = table2array(logfile(1:350, 3));

% index file stuff
temp = load(artiflogfilepath); % load the indices of the good trials
badindexvec = temp.artifactlog.badtrialstotal; % find bad trials

% calculate the power spectrum of the baseline, to be used in many of the
% below analyses; plot if flag is on. 
[trialspecbsl, ~, freqs] = FFT_spectrum3D_singtrial(outmat, 1:400, 500);
[trialspecstim, ~, ~] = FFT_spectrum3D_singtrial(outmat, 601:1000, 500);

if plotflag
    plot(freqs(1:50), squeeze(mean(trialspecbsl(72, 1:50, :),3))), xlabel ('freq in Hz'), ...
    title('Average freq spectrum of the baseline, press space to continue') , pause(1)
end


% calculate the power of the ssVEP using a sliding window
[trialssVEP] = freqtag_slidewin(outmat, 0, 1:500, 401:1400, 15, 600, 500, 'temp' );

% compute actual conditions after artifact rejection
conditionvec_actual=conditionvec; 
conditionvec_actual(badindexvec) = []; 
participantID(badindexvec, :) = [];
trial(badindexvec, :) = [];

%first, we select the ssvep and alpha clusters 
trialssVEP_4out = mean(trialssVEP(cluster4ssvep, :)); 
alphabsl = mean(mean(trialspecbsl(cluster4alpha, frequencybinsalpha, :))); 
alphastim = mean(mean(trialspecstim(cluster4alpha, frequencybinsalpha, :))); 

% put together as column vectors
outmatparticipant = [participantID trial conditionvec_actual column(trialssVEP_4out) column(squeeze(alphabsl)) column(squeeze(alphastim))];


fprintf('.')

disp('end')




