function [data,fs,elab,marker]=gradcorr_ak(filename,TR)
% [data,fs,elab,marker]=gradcorr(filename,vm,chn);
%   -liest EEG-Daten (.eeg) aus brainamp
%   -korrigiert Gradientenartefakte ohne Volumen-Marker (vm)
%   -benutzt readGenericEEG_raw2.m und readGenericHeader2.m
%
% input:    filename (string without extension)
%           TR in ms
%           EEG-Channel (chn)   --> [] reads all channels
%
% output:   data: electrodes x datapoints (gradient corrected)
%           fs: sampling frequency
%           elab: electrode labels
%           marker: vector with all TR-marker-timepoints used for correction
%
% example: [data fs elab marker]=gradcorr_ot('BR9T_B1',2000,1:16);
%          load channel-data 1:16 from file 'BR9T_B1.eeg' and calculates
%          gradient correction based on TR=2000ms

%--------------------------------------------------------------------
% version:    : 1.0
% Created     : 23.07.2014
% Last Update : 23.07.2014
% Author      : Till Nierhaus
%               2014, Dept. Neurology, Charite, BNIC Berlin
% this version is changed by AK, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------read data
% cnt=readGenericEEG_raw2(filename,chn,'raw');%,6000,428000);
% data=cnt.x';    fs=cnt.fs;  elab=cnt.clab;  clear cnt

data = ft_read_data([filename '.eeg']); 
data = [rand(size(data,1), 20000) data];

hdr = ft_read_header([filename '.vhdr']);
fs = hdr.Fs; 
elab = hdr.label; 

disp('done reading data')
disp('')

dTR=(TR/1000)*fs;   %TR in datapoints
std_all=std(data(1,:));
n=0;
std_x=0;

while std_x<std_all %find segment with artifact onset
    n=n+1;
    std_x=std(data(1,dTR*(n-1)+1:dTR*n));
end

%dTR*(n-1):dTR*n first segment in artifact
dat=data(1,dTR*(n-2)+1:dTR*(n-1));%segment with artifact onset
dat=dat-mean(dat);
max_val=max(abs(dat));
n2=0;
val=0;
while val<max_val/2 %find artifact onset
    n2=n2+1;
    val=dat(n2);
end

firstTR=dTR*(n-2)+n2;

vol=firstTR:dTR:length(data);

vol(end)=[];

n=4;%4
std_x=std(data(1,vol(n):vol(n)+dTR)).*2;
while std_x>std_all %find segment with artifact offset 
    n=n+1;
    std_x=std(data(1,vol(n):vol(n)+dTR)).*2;
end


if n<length(vol)
% --> n-1 is last artifact segment, delete rest
vol(n:end)=[];
end
marker=vol;
clear dat n n2 std*
%---filter---
Wn=[55 (fs-1)/2]/fs*2; %Bandpass breite
[b,a]=butter(3,Wn); %Butterworthfilter 3. Ordnung, Koeffizientenberechnung

%-----check last volume

while length(data)-vol(length(vol))<dTR
    vol(length(vol))=[];
end
dat_vol=zeros(length(vol),dTR);

display('correcting electrode ')
for el=1:length(elab)
    fprintf(1,'%d ',el)
    for i=1:length(vol)
        dat_vol(i,:)=data(el,vol(i):vol(i)+dTR-1);   %without detrend --> DC
    end
    cc=corrcoef(filtfilt(b,a,dat_vol'))'; %correlation of filtered data (physiological data filtered out)
    for i=1:length(vol)
        
%         %%%sliding window
%         nwin=5;
%         if i<=nwin
%             data(el,vol(i):vol(i)+dTR-1)=data(el,vol(i):vol(i)+dTR-1)-mean(dat_vol(find([1:2*nwin+1]~=i),:));
%         elseif i>length(vol)-5
%             data(el,vol(i):vol(i)+dTR-1)=data(el,vol(i):vol(i)+dTR-1)-mean(dat_vol(find([length(vol)-2*nwin:length(vol)]~=i),:));
%         else
%             data(el,vol(i):vol(i)+dTR-1)=data(el,vol(i):vol(i)+dTR-1)-mean(dat_vol([i-nwin:i-1 i+1:i+nwin],:));
%         end

        %%%korrelations-methode
        if i<length(vol)
            dd=vol(i+1)-vol(i); %length of vol(i)
            if dd>dTR %Outlier!!
                dd=dTR;
            end
        else dd=dTR;
        end
        [val ind]=sort(cc(i,:),'descend');
        data(el,vol(i):vol(i)+dd-1)=data(el,vol(i):vol(i)+dd-1)-mean(dat_vol(ind(2:20),1:dd));
        
    end
end
display(' --> done')
data = data(:, 20001:end); 


