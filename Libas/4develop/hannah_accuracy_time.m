function [outmat4Bayesian] = hannah_accuracy_time(filepath)
%
%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);

  RTvec= [];
  accuracyvec = [];
  conditionvec = [];

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


for row = 1:size(table,1)
    cue = table2cell(table(row, 2));
    rt = table2array(table(row, 4))./1000;
    response = table2cell(table(row, 7));
    temp  = cell2mat(cue);
    conditionvec(row) = (str2num(temp(2)));
    USvec_shock(row) = table2array(table(row, 9))


    if strcmp(cue, 'C1')
        if strcmp(response, cues(1))
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 1];
        else
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 0];
        end
    elseif strcmp(cue, 'C2')
        if strcmp(response, cues(2))
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 1];
        else
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 0];
        end
    elseif strcmp(cue, 'C3')
        if strcmp(response, cues(3))
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 1];
        else
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 0];
        end
    elseif strcmp(cue, 'C4')
        if strcmp(response, cues(4))
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 1];
        else
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 0];
        end
    elseif strcmp(cue, 'C5')
        if strcmp(response, cues(5))
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 1];
        else
            RTvec = [RTvec rt];
            accuracyvec = [accuracyvec 0];
        end

    end

end

outmat4Bayesian = [column(conditionvec) column(RTvec) column(accuracyvec) ];

