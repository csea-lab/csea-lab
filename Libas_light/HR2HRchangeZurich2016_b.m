% ECG2HRchange
function [CON_BPMmat, BPMavgmat8cond_bsl] = HR2HRchangeZurich2016_b(csvfiledata, csvfilejournal)

% for convenience, this reads in the data from an xl .csv file, where
% one column has cycle indices, the next time (clock time), the next one heart rate in BPM in cardiac time
% nd the 4th one has conditions, but these are listed also and less
% ambiguouisly in an accompanying file
% goal: read in data, extract trials and assign to conditions, then
% determine the proportion of each heart beat for each 1 second-bin. one
% trial after the other; loop over trials and conditions, 
% - calculate HR change as per graham 1979 

BPMmat = []; 

m = csvread(csvfiledata, 2); % reads the spreadsheet into variable m with everything in one go, leaves out labels in first and second row

% next: open the journal file

fid = fopen(csvfilejournal); 

% go through its lines and find time stamps and conditions. rename
% conditions to numbers such that they can be used in a matrix

line = fgetl(fid); % first line is the header, we do not need it. 

% now read the actual data form the journal file
index = 1

while line ~= -1; 

    line = fgetl(fid)
 
    if line ~= -1; 
    % find time stamps in seconds
    commaindices= findstr(line, ','); % find commas
    apoindices= findstr(line, '"'); % find apostrophes
   
   
    %read the times in the correct column... this varies between journal
    %files, yay!
    
    % journalmat(index, 1) = str2num(line(commaindices(3)+1:commaindices(4)-1))             
    %  journalmat(index, 1) = str2num(line(commaindices(1)+1:commaindices(2)-1))
      journalmat(index, 1) = str2num(line(6:9))

    % assign conditionnumbers; baseline = 1; learning(first ten) = 2; learning(after first ten) = 3; extiction = 4;
    % gain = 1; loss = 2; AGAIN THIS VARIES BETWEEN JOURNAL FILES :-) 
    % conditionword = line(commaindices(7)+1:apoindices(end)-1); disp('label word:'), disp(conditionword(1:end-1))
    %conditionword = line(commaindices(5)+1:apoindices(end)-1); disp('label word:'), disp(conditionword(1:end-1))
    conditionword = line(commaindices(1)+18:end-1); disp('label word:'), disp(conditionword(1:end-1))
    
      if strcmp(conditionword(1:end-1), 'Label: baseline gain '),  journalmat(index, 2) = 11; 
        elseif strcmp(conditionword(1:end-1), 'Label: baseline loss '),  journalmat(index, 2) = 12; 
        elseif strcmp(conditionword(1:end-1), 'Label: extinction gain '),  journalmat(index, 2) = 41; 
        elseif strcmp(conditionword(1:end-1), 'Label: extinction loss '),  journalmat(index, 2) = 42; 
        elseif strcmp(conditionword(1:end-1), 'Label: g'),  journalmat(index, 2) = 21; 
        elseif strcmp(conditionword(1:end-1), 'Label: l'),  journalmat(index, 2) = 22; 
        elseif strcmp(conditionword(1:end-1), 'Label: g1') | strcmp(conditionword(1:end-1), 'Label: g2') | strcmp(conditionword(1:end-1), 'Label: g3'), journalmat(index, 2) = 31; 
        elseif strcmp(conditionword(1:end-1), 'Label: l1') | strcmp(conditionword(1:end-1), 'Label: l2') | strcmp(conditionword(1:end-1), 'Label: l3') | strcmp(conditionword(1:end-1), 'Label: l4'), journalmat(index, 2) = 32;  
       else disp ('no match. please fix journal file to match most journal files, check for typos in the label names, etc.'), disp(conditionword(1:end-1)), disp(index), pause
      end % inner if
      
      disp(' ')
 
    end % if

index = index+ 1; 
end% while

% DONE with reading the data and turning conditions into numbers

%%% now for the HR
% find trials, calculate HR change in clock time and assign the condition


for trial = 2: size(journalmat,1) 
    
    disp('trial: '), disp(trial)
    trialonsetindex = find(abs(m(:,2) - journalmat(trial,1)) == (min(abs(m(:,2) - journalmat(trial,1))))) % find the start time point of each trial in the data file, m

        if trialonsetindex < 3, 

        BPMmat = [BPMmat; ones(1,9).*60]; 

        elseif trialonsetindex + 12 > size(m,1) 
        BPMmat = [BPMmat; ones(1,9).*60]; 

        else


        Rwavestamps = m(trialonsetindex-2:trialonsetindex+12, 2)-(journalmat(trial,1)-2)

        [BPMvec]  = IBI2HRchange_core(Rwavestamps, 9); length(BPMvec)

        plot(BPMvec), axis([1 length(BPMvec) 40 120]), title([csvfiledata ' ' num2str(trial)]), pause(.1)

        BPMmat = [BPMmat; BPMvec]; 

        end

    
    
  end % for trial
  
  BPMmat = [mean(BPMmat); BPMmat];

% DONE with basic HR calculations; now assign conditions and average and
% write out. 

% generate a matrix with the condition numbers and the BPM data
CON_BPMmat = [journalmat(:,2) BPMmat];

% find indices of trials that belong to a given condition 
indices_11 = find(journalmat(:, 2) == 11);
indices_12 = find(journalmat(:, 2) == 12);
indices_21 = find(journalmat(:, 2) == 21);
indices_22 = find(journalmat(:, 2) == 22); 
indices_31 = find(journalmat(:, 2) == 31); 
indices_32 = find(journalmat(:, 2) == 32);
indices_41 = find(journalmat(:, 2) == 41);
indices_42 = find(journalmat(:, 2) == 42);



BPMavgmat8cond = [mean(BPMmat(indices_11,:)); mean(BPMmat(indices_12,:)); mean(BPMmat(indices_21,:)); mean(BPMmat(indices_22,:)); ...
    mean(BPMmat(indices_31,:)); mean(BPMmat(indices_32,:)); mean(BPMmat(indices_41,:)); mean(BPMmat(indices_42,:))] 

BPMavgmat8cond_bsl = bslcorr(BPMavgmat8cond, 1:2); 

eval(['save ' csvfiledata '.conBPM.mat CON_BPMmat -mat']); 
eval(['save ' csvfiledata '.avgHRchange8con.mat BPMavgmat8cond_bsl -mat']); 













   



