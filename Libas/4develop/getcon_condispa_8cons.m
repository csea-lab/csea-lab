function [convec] = getcon_condispa_8cons(datfilepath)
%% Load Data
data = load(datfilepath); 

% Columns:
participant = data(:,1);
trialLength = data(:,2);
trialNum = data(:,3);
US_loc = data(:,4);        
setSize = data(:,5);       
gabor12 = data(:,6);       
gabor15 = data(:,7);       

%% Initialize output
pairings = []; % [Participant Trial# Condition# Stim1 Stim2 Stim1_Freq]

%% Process each trial
for i = 1:length(participant)

    % Trial info
    partID = participant(i);
    trial = trialNum(i);
    us = US_loc(i);
    g12 = gabor12(i);
    g15 = gabor15(i);

    % Calculate CS_minus
    if abs(us + 4) < 7
        cs_minus = abs(us + 4);
    else
        cs_minus = abs(us + 4) - 6;
    end

    % Adjacent neighbors (hexagon wrap-around)
    USleft = us - 1; if USleft == 0, USleft = 6; end
    USright = us + 1; if USright == 7, USright = 1; end
    CSminusleft = cs_minus - 1; if CSminusleft == 0, CSminusleft = 6; end
    CSminusright = cs_minus + 1; if CSminusright == 7, CSminusright = 1; end

    % Control location (non-adjacent)
    usedLocs = [us, USleft, USright, cs_minus, CSminusleft, CSminusright];
    allLocs = 1:6;
    controlLoc = setdiff(allLocs, usedLocs);
    if isempty(controlLoc)
        continue; % skip trial if no control location
    else
        controlLoc = controlLoc(1);  % Take first if multiple
    end

    % Assign the 8 conditions
    if (g12 == us && (g15 == USleft || g15 == USright))
        pairings = [pairings; partID trial 1 us g15 12];
    elseif (g15 == us && (g12 == USleft || g12 == USright))
        pairings = [pairings; partID trial 2 us g12 15];
    end

    if (g12 == cs_minus && (g15 == CSminusleft || g15 == CSminusright))
        pairings = [pairings; partID trial 3 cs_minus g15 12];
    elseif (g15 == cs_minus && (g12 == CSminusleft || g12 == CSminusright))
        pairings = [pairings; partID trial 4 cs_minus g12 15];
    end

    if (g12 == us && g15 == controlLoc)
        pairings = [pairings; partID trial 5 us controlLoc 12];
    elseif (g15 == us && g12 == controlLoc)
        pairings = [pairings; partID trial 6 us controlLoc 15];
    end

    if (g12 == cs_minus && g15 == controlLoc)
        pairings = [pairings; partID trial 7 cs_minus controlLoc 12];
    elseif (g15 == cs_minus && g12 == controlLoc)
        pairings = [pairings; partID trial 8 cs_minus controlLoc 15];
    end

end

%% Save output
%save('pairings_8conditions.mat', 'pairings')

temp = ones(420,1)*10;
temp(211:end) = 20;

convec = pairings(:, 3)+temp;