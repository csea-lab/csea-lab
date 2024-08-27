% Clear all variables
clearvars;

% Clear all figures
close all;

% Clear the command window
clc;

eeglab

datapath = "/Users/katemccain/Documents/Konio/Data/konio_512/konio_512.RAW";
logpath = "/Users/katemccain/Documents/Konio/Data/konio_512/koniocondi_512.dat";

%read data into eeglab
EEG = pop_readegi(datapath, [],[],'auto');
EEG = pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp','filetype','autodetect'});
EEG.setname ='temp';
EEG = eeg_checkset( EEG );

%bandpass filter
EEG = pop_eegfiltnew(EEG,4,30);
EEG = eeg_checkset( EEG );

%read conditions from log file
conditionvec = getcon_konio(logpath);

%now get rid fo excess even markers
for indexlat = 1:size(EEG.event,2)
    markertimesinSP(indexlat) = EEG.event(indexlat).latency;
end

tempdiff1 = diff([0 markertimesinSP]);
eventsend = markertimesinSP(tempdiff1>20);
eventsdiscard = (tempdiff1<20);

disp(['a total of ' num2str(length(eventsend)) ' markers were found in the file'])
EEG.event(find(eventsdiscard)) = [];

%replace EEG.event.type with correct triggers
counter = 1; 
      for x = 1:size(EEG.event,2) %  
%           if strcmp(EEG.event(x).type, 'DIN4')
              EEG.event(x).type = num2str(conditionvec(counter)); 
              counter = counter+1;
      end

%replace EEG.urevent.type with correct triggers
counter = 1; 
      for i = 1:size(EEG.urevent,2) %  
%           if strcmp(EEG.event(x).type, 'DIN4')
              EEG.urevent(i).type = num2str(conditionvec(counter)); 
              counter = counter+1;
      end

%make bipolar HEOG and VEOG channels for ocualr IC rejection
%Everytime your run the chanoperator function in erplab it will erase all of the channel locations so you must add the channel location information 
EEG = pop_eegchanoperator( EEG, {'ch129 = ch126 - ch9 label R VEOG (uncorr)', 'ch130 = ((ch1 + ch121 + ch125)/3) - ((ch32 + ch38 + ch128)/3) label HEOG (uncorr)'} , 'ErrorMsg', 'popup', 'KeepChLoc', 'on', 'Warning', 'on' );

%run ICA     
EEG = pop_runica(EEG, [] ,'icatype','sobi','chanind', 1:128); 
EEG = eeg_checkset( EEG );

ica_corr_KM(EEG)

