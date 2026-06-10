% loop script to get # of kept trials and bad channels

files = dir('*artif.mat');

summary = [];

for i = 1:length(files)

    load(files(i).name)

% HAPPY
   % kept trials
    happy_goodtrials = size(artifstruc.artif_happy.badindexmat,2);


    % bad channels
    if isnumeric(artifstruc.artif_happy.BadChanVec) && ...
            ~isempty(artifstruc.artif_happy.BadChanVec)

        happy_badchans = sum(artifstruc.artif_happy.BadChanVec(:));

    else

        happy_badchans = 0;

    end

 % ANGRY
   % kept trials
    angry_goodtrials = size(artifstruc.artif_angry.badindexmat,2);


    % bad channels
    if isnumeric(artifstruc.artif_angry.BadChanVec) && ...
            ~isempty(artifstruc.artif_angry.BadChanVec)

        angry_badchans = sum(artifstruc.artif_angry.BadChanVec(:));

    else

        angry_badchans = 0;

    end


% SAD
    % kept trials
    sad_goodtrials = size(artifstruc.artif_sad.badindexmat,2);

    % bad channels
    if isnumeric(artifstruc.artif_sad.BadChanVec) && ...
            ~isempty(artifstruc.artif_sad.BadChanVec)

        sad_badchans = sum(artifstruc.artif_sad.BadChanVec(:));

    else

        sad_badchans = 0;

    end

subjnames{i} = erase(files(i).name,'.cleaneeg.artif.mat');

% save subject summary   
summary(i,:) = [ ...
        happy_goodtrials happy_badchans ...
        angry_goodtrials angry_badchans ...
        sad_goodtrials sad_badchans];

end
%% summary table
summary_table = array2table(summary, ...
    'VariableNames', { ...
    'Happy_KeptTrials','Happy_BadChans', 'Angry_KeptTrials', 'Angry_BadChans', 'Sad_KeptTrials', 'Sad_BadChans'});

% descriptive stats
mean_row = mean(summary,1);

% convert to tables
mean_table = array2table(mean_row, ...
    'VariableNames', summary_table.Properties.VariableNames);

% combine into one table
summary_table = [mean_table; summary_table];

% row names
summary_table.Properties.RowNames = ...
    ['Mean'; subjnames'];

% save csv
writetable(summary_table, 'artifact_summary.csv', 'WriteRowNames', true)