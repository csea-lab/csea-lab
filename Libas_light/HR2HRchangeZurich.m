% ECG2HRchange
function [CON_BPMmat, BPMavgmat8cond_bsl] = HR2HRchangeZurich(csvfiledata, csvfilejournal, threshold)

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
    commaindices= findstr(line, ',') % find commas
    journalmat(index, 1) = str2num(line(commaindices(2)+1:commaindices(3)-1))
    % assign conditionnumbers; baseline = 1; learning(first ten) = 2; learning(after first ten) = 3; extiction = 4;
    % gain = 1; loss = 2; 
    conditionword = line(commaindices(6)+1:end-1); 
      if strcmp(conditionword, 'Label: baseline gain '),  journalmat(index, 2) = 11; 
        elseif strcmp(conditionword, 'Label: baseline loss '),  journalmat(index, 2) = 12; 
        elseif strcmp(conditionword, 'Label: extinction gain '),  journalmat(index, 2) = 41; 
        elseif strcmp(conditionword, 'Label: extinction loss '),  journalmat(index, 2) = 42; 
        elseif strcmp(conditionword, 'Label: g'),  journalmat(index, 2) = 21; 
        elseif strcmp(conditionword, 'Label: l'),  journalmat(index, 2) = 22; 
        elseif strcmp(conditionword, 'Label: g1') | strcmp(conditionword, 'Label: g2') | strcmp(conditionword, 'Label: g3'), journalmat(index, 2) = 31; 
        elseif strcmp(conditionword, 'Label: l1') | strcmp(conditionword, 'Label: l2') | strcmp(conditionword, 'Label: l3'), journalmat(index, 2) = 32;  
       else disp(conditionword), disp(index), disp ('no match. please fix journal file to match most journal files, check for typos in the label names, etc.'), pause
      end % inner if
 
    end % if

index = index+ 1; 
end% while

% DONE with reading the data and turning conditions into numbers

%%% now for the HR
% find trials, calculate HR change in clock time and assign the condition

for trial = 1: size(journalmat,1) 
    trial
    trialonsetindex = find(abs(m(:,2) - journalmat(trial,1)) == (min(abs(m(:,2) - journalmat(trial,1))))) % find the start time point of each trial in the data file, m
    
 if trial >1
     
    Rwavestamps = m(trialonsetindex-2:trialonsetindex+8, 2);
    
    secbins = [Rwavestamps(1):Rwavestamps(1)+10];
        
    IBIvec = diff(Rwavestamps);
    
    leftfornext = 0; 
    
    BPMvec = zeros(1,length(secbins)-1);

    % we always start with the first Rwave as the first time bin start

    for bin_index = 1:length(secbins)-1 % start counting timebins with first time bin until second to last, which has info about the last beat(s)

      %find cardiac events in and around this timebin and where they are
      %first find cardiac events that are located entirely in the time bin

      % ---- 
            RindicesInBin1= find(Rwavestamps >= secbins(bin_index));
            RindicesInBin2 = min(find(Rwavestamps > secbins(bin_index +1)));
            RindicesInBin = min(RindicesInBin1) : RindicesInBin2 -1;

            if ~isempty(RindicesInBin); 
            maxbincurrent = max(RindicesInBin);
            end

            if length(RindicesInBin) == 2, % if there are two Rwaves in this segment, the basevalue is always 1 beat, and more may be added

                    basebeatnum = 1+leftfornext;

                     %  identify remaining time and determine proportion of next IBI that belongs to this
                     % segment
                      proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                      leftfornext = 1-proportion;

            elseif length(RindicesInBin) == 1,% if there is one Rwave in this segment, the basevalue is what remained from the previous beat, and more may be added

                    basebeatnum = leftfornext;

                     % then identify remaining time and determine proportion of next IBI that belongs to this
                     % segment
                       proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                       leftfornext = 1-proportion;

            else % if there is no beat in this segment
                
                basebeatnum = leftfornext;
                
                if length(IBIvec) >= maxbincurrent+1; 
                proportion =  (secbins(bin_index +1) - Rwavestamps(maxbincurrent+1))./IBIvec(maxbincurrent+1);
                else
                    proportion = 1; 
                end

                 leftfornext = abs(proportion);
                 

            end % if length

         BPMvec(bin_index) = (basebeatnum+proportion) .* 60;    
         
    end % for bin index
    
    % artifact handling. 
    BPMvec(BPMvec > 150) = threshold+1; 
    BPMvec(BPMvec > threshold) = BPMvec(BPMvec > threshold)./2;  
    BPMvec(BPMvec > (mean(BPMvec) + 10) | BPMvec < (mean(BPMvec) - 10)) = mean(BPMvec); 
      
    plot(BPMvec), title(num2str(trial)), pause(.2)
      
      BPMmat = [BPMmat; BPMvec]; 

    end % if trial 
        
end % for trial

BPMmat = [mean(BPMmat, 1); BPMmat]; % estimate first trial from overall mean

% DONE with basic HR calculations; now assign conditions and average and
% write out. 

% generate a matrix with the condition numbers and the BPM data
CON_BPMmat = [journalmat(:,2) BPMmat]

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












   



