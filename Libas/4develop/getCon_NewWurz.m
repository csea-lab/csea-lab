function [conditionvec] = getCon_NewWurz(filepath)
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);


% defining variables 
num_trials = 225;
cue_identifiers = {'C1', 'C2', 'C3', 'C4', 'C5'};
trial_cue = table2cell(table(:, 2)); % this is actual cue
counterbalance = table(1, 10); % this tells us what the counterbalance is
counterbalance_condition = counterbalance{1, 1};


for row = 1:size(table,1)
    cue = table2cell(table(row, 2)); 

    % now, discard neutral and make vectors for each
    % condition
    if strcmp(cue, 'C1') && counterbalance_condition==1
        conditionvec(row)=1;
    elseif strcmp(cue, 'C2') && counterbalance_condition==2
        conditionvec(row)=1;
    elseif strcmp(cue, 'C2') && counterbalance_condition==1
        conditionvec(row)=2;
    elseif strcmp(cue, 'C1') && counterbalance_condition==2
        conditionvec(row)=2;  
    elseif strcmp(cue, 'C3') && counterbalance_condition==1
        conditionvec(row)=3; 
    elseif strcmp(cue, 'C4') && counterbalance_condition==2
        conditionvec(row)=3; 
    elseif strcmp(cue, 'C4') && counterbalance_condition==1
        conditionvec(row)=4; 
    elseif strcmp(cue, 'C3') && counterbalance_condition==2
        conditionvec(row)=4; 
    elseif strcmp(cue, 'C5') && counterbalance_condition==1
        conditionvec(row)=5; 
    elseif strcmp(cue, 'C5') && counterbalance_condition==2
        conditionvec(row)=6; 
    end
end


