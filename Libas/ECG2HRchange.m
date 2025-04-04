% ECG2HRchange
function [BPM] = ECG2HRchange(filemat); 

% for convenience, this reads in the data from biopac, using settings for
% cardiac defense.... other exps need other front end..

inmat = load(filemat, '-ascii'); 

ECGvec = inmat(:,1);

trigindex = find(inmat(:,2) < -4);

[B,A] = Butter(5,0.02, 'high')

ECGvec1 = (ECGvec(trigindex(1)-800:trigindex(1)+12000,1));
ECGvec2 = (ECGvec(trigindex(2)-800:trigindex(2)+12000,1));

ECGvec1 = filtfilt(B,A,ECGvec1); 
ECGvec2 =  filtfilt(B,A,ECGvec2);

% find R waves interactively/semi-interactively

Rindexvec1 = []; 
Rindexvec2 = [];

axissp = 1:12800; 
figure
screenstartpoints = 1:1279:12800; 

for screenindex = 1:10
    plot(axissp(screenstartpoints(screenindex):screenstartpoints(screenindex+1)), ECGvec1(screenstartpoints(screenindex):screenstartpoints(screenindex+1)))
    
    flag = input('interactive [1] or threshold [2]')
    
    if flag == 1
        x = []; 
        [x,y] = ginput    
        pause
        Rindexvec1 = [Rindexvec1;x]
    else
        x = []; 
        [nouse,threshold] = ginput
        a = [ECGvec1(screenstartpoints(screenindex):screenstartpoints(screenindex+1))];
        timevecsp = axissp(screenstartpoints(screenindex):screenstartpoints(screenindex+1));
        for runindex = 2:length(a)
        if a(runindex)<threshold & a(runindex-1)>threshold, x = [x; timevecsp(runindex)], end
        end
        Rindexvec1 = [Rindexvec1;x]
    end
                
end

Rindexvec1 = round(Rindexvec1);



for screenindex = 1:10
    plot(axissp(screenstartpoints(screenindex):screenstartpoints(screenindex+1)), ECGvec2(screenstartpoints(screenindex):screenstartpoints(screenindex+1)))
   
     flag = input('interactive [1] or threshold [2]')
    
    if flag == 1
        x = [];
        [x,y] = ginput    
        pause
        Rindexvec2 = [Rindexvec2;x]
    else
        x = [];
        [nouse,threshold] = ginput
        a = [ECGvec2(screenstartpoints(screenindex):screenstartpoints(screenindex+1))];
        timevecsp = axissp(screenstartpoints(screenindex):screenstartpoints(screenindex+1));
        for runindex = 2:length(a)
        if a(runindex)<threshold & a(runindex-1)>threshold, x = [x; timevecsp(runindex)], end
        end
        Rindexvec2 = [Rindexvec2;x]
    end
    
end

 Rindexvec2 = round(Rindexvec2);

figure

plot(Rindexvec1(1:length(Rindexvec1)-1), 60./(diff(Rindexvec1)./200) ,'r')
pause
hold on 
plot(Rindexvec2(1:length(Rindexvec2)-1), 60./(diff(Rindexvec2)./200), 'b')
pause

IBI_mat_1 = [diff(Rindexvec1)];

IBI_mat_2 = [diff(Rindexvec2)];

% sample rate is 200 Hz, define latencies of  second bins, each has 200 sample
% points; bins are define relative to onset, in sample points

secbins = [1:200:12800]; 

% determine the proportion of each heart beat for each sec bin. one
% trial after the other

%first trial (Rindexvec1): 
weight1 = zeros(1, length(secbins)-1);

for bin_index = 1:length(secbins)-1
    
    for Rwave1 = 2: length(Rindexvec1)-1
               
         if ismember(Rindexvec1(Rwave1), [secbins(bin_index):secbins(bin_index)+199]);
        
                R_inBintime = find((Rindexvec1(Rwave1) == secbins(bin_index):secbins(bin_index)+199));
            
                weight1(bin_index) =  (200-R_inBintime) ./ IBI_mat_1(Rwave1) + R_inBintime ./IBI_mat_1(Rwave1-1)
                
         end

    end
          
end

figure
plot(weight1), title('witz weight1 raw') 
pause

index_0 = find(weight1 ==0); weight1(index_0) = mean(nonzeros(weight1)); % todo: interpolate first and last point

plot(weight1), title('witz weight1 after') 

pause

BPM.trial1 = 60 .* weight1; 



% second trial

weight2 = zeros(1, length(secbins)-1);

for bin_index = 1:length(secbins)-1
    
    for Rwave1 = 2: length(Rindexvec2)-1
    
         if ismember(Rindexvec2(Rwave1), secbins(bin_index):secbins(bin_index)+199), disp('witz')
        
                R_inBintime = find((Rindexvec2(Rwave1) == secbins(bin_index):secbins(bin_index)+199))
            
                weight2(bin_index) =  (200-R_inBintime) ./ IBI_mat_2(Rwave1) + R_inBintime ./IBI_mat_2(Rwave1-1);
                
         end

    end
          
end

index_0 = find(weight2 ==0); weight2(index_0) = mean(nonzeros(weight2)); % todo: interpolate first and last point

BPM.trial2 = 60 .* weight2; 

save([filemat '.bpm.mat'], 'BPM', '-mat')








