function[] = ssvep_simulation(avgfilemat,electrode,timewindow,targetfreq,simulation_dur)

%settings
samplingrate = 500;
convlstart = 300;
bsl = [1:50];

%settings for hilbert transform
hilbertbsl = 1:40;
filterorder = 8;
plotflag = 0;


%load matrices, do baselinecorrection and cut out timewindow

no_files = numel(avgfilemat(:,1));
avgmats = cell([no_files,1]);
for file = 1:no_files
    tmpavgmat = ReadAvgFile(avgfilemat(file,:));
    which bslcorr
    [tmpavgmat] = bslcorr(tmpavgmat,bsl);
    tmpavgmat = tmpavgmat(:,timewindow);
    avgmats{1,file} = tmpavgmat;
end;

%calculate interspikeintervals (in SP)
isi = round((1000/targetfreq)/2);

%build vector (simulation_dur in SP)
vect = zeros(1,simulation_dur);
vect(convlstart:isi:end) = 1;




%convolve ERP and vector and calculate hilbert transform
ssveps = cell([no_files,1]);
hilberts = cell([no_files,1]);

for file = 1: no_files
    tmpavgmat = avgmats{1,file};
    tmpssvepmat = conv(vect,tmpavgmat(electrode,:));
    ssveps{1,file} = tmpssvepmat;
    [tmphilbert, phasemat, tempmat]=steadyHilbertMat(tmpssvepmat, targetfreq, hilbertbsl, filterorder, plotflag, samplingrate);
    hilberts{1,file}=tmphilbert;
end;



%plot first two conditions
close all;
figure
plot(hilberts{1,1},'r')
title([ num2str(targetfreq) '  Hz; sensor ' num2str(electrode) '; cond1 = ' avgfilemat(1,:) ' and cond2 = ' avgfilemat(2,:) ])
hold on
plot(hilberts{1,2},'g');
legend('cond1','cond2');





%avgfilemat = ['GM20.at11.ar';'GM20.at21.ar' ]
% GMntr = ReadAvgFile('GM20.at11.ar');
% GMntr = bslcorr(GMntr, [1:50]);
% GMntr = GMntr(:, 51:500);
% ssvep = conv(vector, GMntr(75,:));
% [demodmatntr, phasemat, tempmat]=steadyHilbertMat(ssvep_ntr, 6.66, 1:40, 8, 0, 500);
% 



