function [corr_reward, corr_shock, BETA_shock, BETA_reward, rewardtable, shocktable] = hannah_preproRescorla(filepath, flipflag, plotflag)
%
if nargin < 3, plotflag = 0; end

%first, read in a new_wurz log file with RTs and everything
table = readtable(filepath);

  RTvec= [];
  accuracyvec = [];
  conditionvec = [];

% hannah script trying to calculate percentage correct responses
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


for row = 1:size(table,1)
    cue = table2cell(table(row, 2));
    rt = table2array(table(row, 4))./1000;
    if flipflag % if , subtracts rt from 1 which flips its direction
    rt = 1- rt; 
    end
    response = table2cell(table(row, 7));
    temp  = cell2mat(cue);
    conditionvec(row) = (str2num(temp(2)));
    USvec_shock(row) = table2array(table(row, 9));
    USvec_reward(row) = table2array(table(row, 8));


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

bigtable = [column(conditionvec) column(RTvec) column(accuracyvec) column(USvec_shock) column(USvec_reward)];

writematrix(bigtable,[filepath '.4RW.csv'])

shockindexvec = find(bigtable(:, 1)< 3); 

shocktable = bigtable(shockindexvec,:);

rewardindexvec = find(bigtable(:, 1)< 5 & bigtable(:, 1)> 2); 

rewardtable = bigtable(rewardindexvec,:);


% now, the model fitting
OPTIONS = statset('MaxIter', 100000, 'FunValCheck', 'off');

% for shock
[BETA_shock,R,J,COVB,MSE] = nlinfit(shocktable(:,4),shocktable(:,2),@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 .2], OPTIONS);

temp = rescorlaWagnerLearnOrigIntcpt(BETA_shock, shocktable(:,4));

RSS = sum(R.^2);

corrtemp = corrcoef(temp,shocktable(:,2)); 
corr_shock = corrtemp(2,1); 

if plotflag 
    figure
    subplot(2,1,1), plot(shocktable(:,2))
    hold on
    plot(temp)
    bar(shocktable(:,4)./10, 'r')
end

% for reward
[BETA_reward,R,J,COVB,MSE] = nlinfit(rewardtable(:,5),rewardtable(:,2),@rescorlaWagnerLearnOrigIntcpt, [0.5 0.5 .2], OPTIONS);

temp = rescorlaWagnerLearnOrigIntcpt(BETA_reward, rewardtable(:,5));

RSS = sum(R.^2);

corrtemp = corrcoef(temp,rewardtable(:,2)); 
corr_reward = corrtemp(2,1);

if plotflag 
subplot(2,1,2), plot(rewardtable(:,2))
hold on
plot(temp)
bar(rewardtable(:,5)./10, 'g')
end


   

