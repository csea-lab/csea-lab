% master script for konio
% preprocessing wqs as follows:
% filtering lowpass (BUTTER, Order 23, FPass 40, FStop 50, RPass 3, RStop 45) and highpass (BUTTER, Order 1, FPass 3, FStop 0.05, RPass 1, RStop 18) ...
% extracting epochs from 300 points before to 1900 points after trigger onset...
% Total number of triggers: 160
%
taxis = -600:2:3800;
%% the postprocessing starts with the at and app files from the above, after artifact control and averaging

% this is the default spectrum, applied across the whole segment
cd '/Users/andreaskeil/Desktop/Konio6people/atfiles'
[spec] = get_FFT_atg(pwd, 301:2100);
filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 4, 'GM6.spec');

%% this is for the hilbert transform
cd '/Users/andreaskeil/Desktop/Konio6people/atfiles'
filemat = getfilesindir(pwd, '*.ar');
[demodmat, phasemat]=steadyHilbert(filemat, 7.5, 200:300, 9, 1, 75);
cd '/Users/andreaskeil/Desktop/Konio6people/hampfiles'
filemat = getfilesindir(pwd, '*.hamp*');
mergemulticons(filemat, 4, 'GM6.hamp');

%%
cd '/Users/andreaskeil/Desktop/Konio6people/appfiles'
filemat = getfilesindir(pwd, '*.app*');
wavelet_app_dft(filemat, 15, 180, 3, []);

