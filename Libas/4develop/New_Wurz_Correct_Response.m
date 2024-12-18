function [correct_reward, correct_shock, shock_slope, reward_slope] = New_Wurz_Correct_Response(filepath)
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);

% hannah script to calculate correct responses
% defining variables 
num_trials = 225;
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

correct_shock = 0; 
correct_reward = 0;

for row = 1:size(table,1)
    cue = table2cell(table(row, 2)); 
    response = table2cell(table(row, 7));

    % now, discard neutral and make correct response vectors for each
    % condition
    if strcmp(cue, 'C1')
        counterC1 = counterC1+1; 
        if strcmp(response, cues(1))
        correct_shock = [correct_shock correct_shock(end)+1];
        else
        correct_shock = [correct_shock correct_shock(end)+0];    
        end
    elseif strcmp(cue, 'C2') 
        counterC2 = counterC2+1; 
        if strcmp(response, cues(2))
        correct_shock = [correct_shock correct_shock(end)+1];
        else
        correct_shock = [correct_shock correct_shock(end)+0];
        end
    elseif strcmp(cue, 'C3') 
        counterC3 = counterC3+1; 
        if strcmp(response, cues(3))
        correct_reward = [correct_reward correct_reward(end)+1];
        else
        correct_reward = [correct_reward correct_reward(end)+0];
        end
     elseif strcmp(cue, 'C4') 
        counterC4 = counterC4+1; 
        if strcmp(response, cues(4))
        correct_reward = [correct_reward correct_reward(end)+1];
        else
        correct_reward = [correct_reward correct_reward(end)+0];
        end
    elseif strcmp(cue, 'C5')
        counterC5 = counterC5+1;
    end

end
clf
figure(101)
plot(correct_reward)
hold on
plot(correct_shock)
legend ('correct_reward', 'correct_shock')
shock_slope = polyfit(1:89,correct_shock(1:89),1)
reward_slope = polyfit(1:89,correct_reward(1:89),1)

save ([filepath '.learn.mat'], 'correct_reward', 'correct_shock', 'shock_slope', 'reward_slope', '-mat')
