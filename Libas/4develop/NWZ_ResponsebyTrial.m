% this is the script to calculate the correct response per trial in order and add to log file

cd '/Volumes/TOSHIBA EXT/New_Wurzburg/csvfiles'

filemat = getfilesindir(pwd, '*.csv')

correct_response = NaN(225, size(filemat, 1)); % subjects by number of trials NaN matrix

for fileindex = 1:size(filemat,1)


    table = readtable(filemat(fileindex, :));
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


    for row = 1:size(table,1)
        cue = table2cell(table(row, 2));
        response = table2cell(table(row, 7));

        % now, make correct response vector in order of trials
        if strcmp(cue, 'C1')
            if strcmp(response, cues(1))
                correct_response(row, fileindex)=1;
            else
                correct_response(row, fileindex)=0;
            end
        elseif strcmp(cue, 'C2')
            counterC2 = counterC2+1;
            if strcmp(response, cues(2))
                correct_response(row, fileindex)=1;
            else
                correct_response(row, fileindex)=0;
            end
        elseif strcmp(cue, 'C3')
            counterC3 = counterC3+1;
            if strcmp(response, cues(3))
                correct_response(row, fileindex)=1;
            else
                correct_response(row, fileindex)=0;
            end
        elseif strcmp(cue, 'C4')
            counterC4 = counterC4+1;
            if strcmp(response, cues(4))
                correct_response(row, fileindex)=1;
            else
                correct_response(row, fileindex)=0;;
            end
        elseif strcmp(cue, 'C5')
            counterC5 = counterC5+1;
            if strcmp(response, cues(5))
                correct_response(row, fileindex)=1;
            else
                correct_response(row, fileindex)=0;
            end
        end
    end

end
