function [RT, MN, Var, Pc, outvec] = hannah_ezDDMWed(filepath)
%
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);


  RTvec_shock = [];
  RTvec_reward = [];
  RTvec_ntr = [];
  correctvec_shock = [];
  correctvec_reward = [];


% hannah script trying to calculate percentage correct responses
% defining variables 
num_trials = 225
cue_identifiers = {'C1', 'C2', 'C3', 'C4', 'C5'};
cues_counterbalance_1 = {'LeftArrow', 'RightArrow', 'LeftArrow', 'RightArrow', 'LeftArrow'};
cues_counterbalance_2 = {'RightArrow', 'LeftArrow', 'RightArrow', 'LeftArrow', 'RightArrow'};
trial_cue = table2cell(table(:, 2)); % this is actual cue
counterbalance = table(1, 10); % this tells us what the counterbalance is
counterbalance_condition = counterbalance{1, 1};
participant_response = table(:, 7); % this is actual responses e.g leftarrow

if counterbalance_condition == 1
    cues = cues_counterbalance_1;
else 
    cues = cues_counterbalance_2;
end
  

counterC1 = 0; 
counterC2 = 0;
counterC3 = 0;
counterC4 = 0;
counterC5 = 0;

for row = 1:size(table,1)
    cue = table2cell(table(row, 2)); 
    rt = table2array(table(row, 4))./1000;
    response = table2cell(table(row, 7));

    % now, discard neutral and keep
    if strcmp(cue, 'C1')
        counterC1 = counterC1+1; 
        if strcmp(response, cues(1))
        RTvec_shock = [RTvec_shock rt];
        end
    elseif strcmp(cue, 'C2') 
        counterC2 = counterC2+1; 
        if strcmp(response, cues(2))
        RTvec_shock = [RTvec_shock rt];
        end
    elseif strcmp(cue, 'C3') 
        counterC3 = counterC3+1; 
        if strcmp(response, cues(3))
        RTvec_reward = [RTvec_reward rt];
        end
     elseif strcmp(cue, 'C4') 
        counterC4 = counterC4+1; 
        if strcmp(response, cues(4))
        RTvec_reward = [RTvec_reward rt];
        end
    elseif strcmp(cue, 'C5')
        counterC5 = counterC5+1;
        if strcmp(response, cues(5))
        RTvec_ntr = [RTvec_ntr rt];
        end
    end

end

RT.RTvec_ntr = RTvec_ntr; 
RT.RTvec_reward = RTvec_reward;
RT.RTvec_shock = RTvec_shock;

MN.meanRT_shock = mean(RT.RTvec_shock); 
MN.meanRT_reward = mean(RT.RTvec_reward); 
MN.meanRT_ntr = mean(RT.RTvec_ntr); 

Var.VarRT_shock = var(RT.RTvec_shock); 
Var.VarRT_reward = var(RT.RTvec_reward); 
Var.arRT_ntr = var(RT.RTvec_ntr); 

Pc.perCorr_shock = -0.001 + length(RT.RTvec_shock)./ (counterC1 + counterC2);
Pc.perCorr_reward = -0.001 + length(RT.RTvec_reward)./ (counterC3 + counterC4);
Pc.perCorr_ntr = -0.001 + length(RT.RTvec_ntr)./ (counterC5);

[v_shock a_shock Ter_shock] = ezDiffusion(Pc.perCorr_shock, Var.VarRT_shock, MN.meanRT_shock, .1);
[v_reward a_reward Ter_reward] = ezDiffusion(Pc.perCorr_reward, Var.VarRT_reward, MN.meanRT_reward, .1);



outvec = [v_shock a_shock Ter_shock v_reward a_reward Ter_reward Pc.perCorr_shock Pc.perCorr_reward]
