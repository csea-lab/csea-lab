%% dat
function [outmat, false_alarm, discard] = swirl_study4_getcon(path)
% study 2: response to swirl



%% 

data        = load(path);

if size(data,1) ~= 360;
    warning('wrong number of trials in this file');
else
    % use this to determine block
    block       = data(:,2);

    % use these to determine condition
    condition   = data(:,5);
    
    % dependent variable
    rt          = data(:,6);

    matrix = [block, condition, rt];

    %% calculate means by block and trial

    false_alarm = [];
    b1_c1 = []; b1_c2 = []; b1_c3 = []; b1_c4 = []; b1_c5 = []; b1_c6 = [];
    b2_c1 = []; b2_c2 = []; b2_c3 = []; b2_c4 = []; b2_c5 = []; b2_c6 = [];
    b3_c1 = []; b3_c2 = []; b3_c3 = []; b3_c4 = []; b3_c5 = []; b3_c6 = [];

    for id = 1:360
        ts = matrix(id,:);
        block = ts(1);
        con = ts(2);
        rt = ts(3);

        if rt ~= 0
            if block == 1 
                if con == 201
                    b1_c1 = [b1_c1; rt];
                elseif con == 202
                    b1_c2 = [b1_c2; rt];
                elseif con == 203
                    b1_c3 = [b1_c3; rt];
                elseif con == 204
                    b1_c4 = [b1_c4; rt];
                elseif con == 205
                    b1_c5 = [b1_c5; rt];
                elseif con == 206
                    b1_c6 = [b1_c6; rt];
                else
                    false_alarm = [false_alarm; ts];
                end

            elseif block == 2 
                if con == 201
                    b2_c1 = [b2_c1; rt];
                elseif con == 202
                    b2_c2 = [b2_c2; rt];
                elseif con == 203
                    b2_c3 = [b2_c3; rt];
                elseif con == 204
                    b2_c4 = [b2_c4; rt];
                elseif con == 205
                    b2_c5 = [b2_c5; rt];
                elseif con == 206
                    b2_c6 = [b2_c6; rt];
                else
                    false_alarm = [false_alarm; ts];
                end
            elseif block == 3 
                if con == 201
                    b3_c1 = [b3_c1; rt];
                elseif con == 202
                    b3_c2 = [b3_c2; rt];
                elseif con == 203
                    b3_c3 = [b3_c3; rt];
                elseif con == 204
                    b3_c4 = [b3_c4; rt];
                elseif con == 205
                    b3_c5 = [b3_c5; rt];
                elseif con == 206
                    b3_c6 = [b3_c6; rt];
                else
                    false_alarm = [false_alarm; ts];
                end
            end
        end
    end
    
    %% get the number of false alarms
    
    false_alarm = size(false_alarm,1);
    if isempty(false_alarm)
        false_alarm = 0;
    end
    
        %% get rid of values more than 2 std dev away from mean
    
    z_thresh = 2.173;
    discard = 0;
    
    z = zscore(b1_c1);
    outliers = find(abs(z) > z_thresh);
    b1_c1(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b1_c2);
    outliers = find(abs(z) > z_thresh);
    b1_c2(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b1_c3);
    outliers = find(abs(z) > z_thresh);
    b1_c3(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b1_c4);
    outliers = find(abs(z) > z_thresh);
    b1_c4(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b1_c5);
    outliers = find(abs(z) > z_thresh);
    b1_c5(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b1_c6);
    outliers = find(abs(z) > z_thresh);
    b1_c6(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c1);
    outliers = find(abs(z) > z_thresh);
    b2_c1(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c2);
    outliers = find(abs(z) > z_thresh);
    b2_c2(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c3);
    outliers = find(abs(z) > z_thresh);
    b2_c3(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c4);
    outliers = find(abs(z) > z_thresh);
    b2_c4(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c5);
    outliers = find(abs(z) > z_thresh);
    b2_c5(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b2_c6);
    outliers = find(abs(z) > z_thresh);
    b2_c6(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c1);
    outliers = find(abs(z) > z_thresh);
    b3_c1(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c2);
    outliers = find(abs(z) > z_thresh);
    b3_c2(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c3);
    outliers = find(abs(z) > z_thresh);
    b3_c3(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c4);
    outliers = find(abs(z) > z_thresh);
    b3_c4(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c5);
    outliers = find(abs(z) > z_thresh);
    b3_c5(outliers) = [];
    discard = discard + length(outliers);
    
    z = zscore(b3_c6);
    outliers = find(abs(z) > z_thresh);
    b3_c6(outliers) = [];
    discard = discard + length(outliers);
    
    

    outmat = [mean(b1_c1), mean(b1_c2), mean(b1_c3), mean(b1_c4), mean(b1_c5), mean(b1_c6),...
              mean(b2_c1), mean(b2_c2), mean(b2_c3), mean(b2_c4), mean(b2_c5), mean(b2_c6),...
              mean(b3_c1), mean(b3_c2), mean(b3_c3), mean(b3_c4), mean(b3_c5), mean(b3_c6)];
end


      
      
      
      
      
      
      