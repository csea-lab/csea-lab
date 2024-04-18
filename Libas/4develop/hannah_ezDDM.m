function [RT] = hannah_ezDDM(filepath)
%
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);

  RTvec_shock = [];
  RTvec_reward = [];
  RTvec_ntr = [];
  correctvec_shock = [];
  correctvec_reward = [];
  
for row = 1:size(table,1)
    cue = table2cell(table(row, 2)); 
    rt = table2array(table(row, 4));
    key = table(row, 7);
    counterbalanced = table(1, 10);

    % now, discard neutral and keep
    if strcmp(cue, 'C1') || strcmp(cue, 'C2')
        RT.RTvec_shock = [RTvec_shock rt];
    elseif strcmp(cue, 'C3') || strcmp(cue, 'C4')
        RT.RTvec_reward = [RTvec_reward rt];
    elseif strcmp(cue, 'C5')
        RT.RTvec_ntr = [RTvec_ntr rt];

    end


end

meanRT_shock = mean(RT.RTvec_shock); 
meanRT_reward = mean(RT.RTvec_reward); 
meanRT_ntr = mean(RT.RTvec_ntr); 

VarRT_shock = var(RT.RTvec_shock); 
VarRT_reward = var(RT.RTvec_reward); 
VarRT_ntr = var(RT.RTvec_ntr); 




