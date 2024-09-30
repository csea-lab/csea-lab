function [EEGOUT, ArtComps, status] = ica_corr_KM(EEGIN, chan_operation_file, EEG_seg)
% 
% [EEGOUT, ArtComps, status] = ica_corr(EEGIN, chan_operation_file, EEG_seg) 
%
% inputs:  EEGIN                  - EEG structure with ICA weights 
%          chan_operation_file    - Optional. ERPLAB channel operation .txt file (to create corrected bipolar channels). If specified, plot and save EEG with corrected bipolar EOGs. 
%          EEG_seg                - Optional. Segmented EEG data. For plotting erpimage only. 
%
% outputs: EEGOUT    - EEG after user-specified ICs have been removed and ICA-corrected bipolar channels have been added. 
%          ArtComps  - indices of components removed 
%          status    - 0/1. Whether ICA correction was performed. 

% updated by wz on 01/06/2021
% modified by KM with permission on 8/26/24

if nargin < 3
    EEG_seg = EEGIN; 
end 
if nargin < 2 
    chan_operation_file = [];
end

%set color map 
set(groot,'DefaultFigureColormap',jet)

%set "happy" flag 
happy = 0; 

%find channel indices of bipolar EOG channels 
veog_i_temp = find(contains({EEGIN.chanlocs.labels},'VEOG','IgnoreCase',true));
if veog_i_temp > 1
    VEOG_i = veog_i_temp(end);
elseif veog_i_temp == 1
    VEOG_i = veog_i_temp;
else
    error('Can''t find bipolar VEOG channel!');
end

heog_i_temp = find(contains({EEGIN.chanlocs.labels},'HEOG','IgnoreCase',true));
if heog_i_temp > 1
    HEOG_i = heog_i_temp(end);
elseif heog_i_temp == 1
    HEOG_i = heog_i_temp;
else
    error('Can''t find bipolar GEOG channel!');
end

% Preallocate vcorrs and hcorrs to avoid undefined variable issues
vcorrs = zeros(1, size(EEGIN.icaact, 1));
hcorrs = zeros(1, size(EEGIN.icaact, 1));

%find likely IC components 
for ic = 1:size(EEGIN.icaact,1)
vcorrs(ic)=abs(corr(EEGIN.data(VEOG_i,:)',EEGIN.icaact(ic,:)'));
end
VEOG_IC_100_90 = find(vcorrs > 0.90);
VEOG_IC_89_80 = find(vcorrs > 0.80 & vcorrs < 0.89);
VEOG_IC_79_70 = find(vcorrs > 0.70 & vcorrs < 0.79);
VEOG_IC_69_60 = find(vcorrs > 0.60 & vcorrs < 0.69);
VEOG_IC_59_50 = find(vcorrs > 0.50 & vcorrs < 0.59);
VEOG_IC_49_40 = find(vcorrs > 0.40 & vcorrs < 0.49);

for ic = 1:size(EEGIN.icaact,1)
   hcorrs(ic)=abs(corr(EEGIN.data(HEOG_i,:)',EEGIN.icaact(ic,:)'));
end
HEOG_IC_100_90 = find(hcorrs > 0.90);
HEOG_IC_89_80 = find(hcorrs > 0.80 & hcorrs < 0.89);
HEOG_IC_79_70 = find(hcorrs > 0.70 & hcorrs < 0.79);
HEOG_IC_69_60 = find(hcorrs > 0.60 & hcorrs < 0.69);
HEOG_IC_59_50 = find(hcorrs > 0.50 & hcorrs < 0.59);
HEOG_IC_49_40 = find(hcorrs > 0.40 & hcorrs < 0.49);


OcularICs_100_90 = union(VEOG_IC_100_90,HEOG_IC_100_90);
OcularICs_89_80 = union(VEOG_IC_89_80,HEOG_IC_89_80);
OcularICs_79_70 = union(VEOG_IC_79_70,HEOG_IC_79_70);
OcularICs_69_60 = union(VEOG_IC_69_60,HEOG_IC_69_60);
OcularICs_59_50 = union(VEOG_IC_59_50,HEOG_IC_59_50);
OcularICs_49_40 = union(VEOG_IC_49_40,HEOG_IC_49_40);

%plot IC topography, IC activation, and ICA-corrected EEG data and repeat until happy == 1 
iteration = 1;

while happy ~= 1 
       
    %temporarily remove suggested ICs (on 1st iteration) or user-inputted ICs (subsequent iterations) 
    if iteration == 1
        ArtComps = [OcularICs_100_90, OcularICs_89_80, OcularICs_79_70, OcularICs_69_60, OcularICs_59_50, OcularICs_49_40];
    else
        prompt = 'Artifact ICs?';
        ArtComps = input(prompt); 
    end

    % Initialize the reject field if it doesn't exist
    if ~isfield(EEGIN.reject, 'gcompreject') || isempty(EEGIN.reject.gcompreject)
        EEGIN.reject.gcompreject = zeros(1, size(EEGIN.icaweights, 1)); % Initialize with zeros
    end

    % Mark the selected components for rejection
    EEGIN.reject.gcompreject(ArtComps) = 1;

    % Apply subcomponent removal
    EEGtemp = pop_subcomp(EEGIN, ArtComps, 0);

    %create corrected bipolars, if bin operation file is available 
    if ~isempty(chan_operation_file) 
        EEGtemp = eeg_checkset(EEGtemp);
        EEGtemp = pop_eegchanoperator(EEGtemp,chan_operation_file);
    end
    
    %plot EEG (after temporary ICA-correction)    
    eegplot(EEGtemp.data,'srate',EEGtemp.srate,'title', EEGtemp.setname,'position',[800 400 1500 800],'eloc_file',EEGtemp.chanlocs,'events',EEGtemp.event,'spacing',100);
    
    %plot IC activation (in black) + bipolar EOGs (in blue) 
    linecolors = cell(1,size(EEGIN.icaact,1)+3);
    linecolors(1:size(EEGIN.icaact,1)) = {'k'};
    linecolors([size(EEGIN.icaact,1)+1:length(linecolors)]) = {'b'};
    eegplot([EEGIN.icaact; 0.2*EEGIN.data([VEOG_i HEOG_i],:)],'color',linecolors,...
        'spacing',20,'srate',EEGIN.srate,'events',EEGIN.event,'position',[100 400 1500 800],'title','IC Activation (black) + Bipolar EOGs (blue)');
 
    %print suggested ICs to remove 
    fprintf(2,['(Suggested Ocular ICs: '  '100-90 Correlated = ' num2str(OcularICs_100_90) '; 89-80 Correlated = ' num2str(OcularICs_89_80) '; 79-70 Correlated = ' num2str(OcularICs_79_70) '; 69-60 Correlated = ' num2str(OcularICs_69_60) '; 59-50 Correlated = ' num2str(OcularICs_59_50) '; 49-40 Correlated = ' num2str(OcularICs_49_40) ')' ' '])

    %plot IC topography     
    assignin('base','EEG_seg',EEG_seg)
%     pop_selectcomps(EEG_seg,1:size(EEGIN.icaact,1));
    pop_selectcomps(EEG_seg);

    %ask user for input 
    prompt = 'save EEG (1), redo IC correction (0), or skip (-999)?';
    happy = input(prompt); 
    while isempty(happy) || ~ismember(happy,[0 1 -999])
        prompt = 'save EEG (1), redo IC correction (0), or skip (-999)?';
        happy = input(prompt); 
    end
    
    iteration = iteration+1;
    
    close all
    
    if happy == -999
        break
    end

end

if happy~= -999
    EEGOUT = EEGtemp; 
    status = 1;
else
    EEGOUT = EEGIN;
    ArtComps = []; 
    status = 0;
end
