%horseifant
clear all

fclose('all'); 

fid = fopen('transposehorse.csv'); 
%fid = fopen('weanlings.csv'); 

numberhorses = 104; 

%%
outarray = []; 

for horse = 1:numberhorses
    temp = fgetl(fid);
    
    %find commas
    INDcomma = strfind(temp,','); 
    
    % find startle time
    indcolon = strfind(temp,':'); 
    if isempty(str2num(temp(1)))
    startletime_sec = str2double(temp(2:indcolon-1)).*60 + str2double(temp(indcolon+1:indcolon+2));
    else
    startletime_sec = str2double(temp(1:indcolon-1)).*60 + str2double(temp(indcolon+1:indcolon+2));    
    end
 
    disp (['horse: ' num2str(horse)])
    disp(startletime_sec) 
    
    
    % get all of HR in IBIs
    HRtimeseries = temp(INDcomma(1):end); 
    HRtimeseries(strfind(HRtimeseries, ',')) = ' '; 
    HRtime = str2num(HRtimeseries);
 
    % find the relevant segment
    findstartlevec = cumsum(HRtime);
    startindex = min(find(findstartlevec>startletime_sec));         
    
    if startindex > length(HRtime)-26
        HRchange20sec = HRtime(end-30:end-6)
    else
        HRchange20sec = HRtime(startindex:startindex + 25)
    end
    
    if isempty(HRchange20sec)
        HRchange20sec = HRtime(end-30:end-6)
    end
           
    % artifacts
    testvec1 = diff(HRchange20sec); 
    index1 = find(abs(testvec1) > .5) + 1;
    HRchange20sec(index1) = mean(HRchange20sec); 
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2; 
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2;
    HRchange20sec(HRchange20sec<.5) = HRchange20sec(HRchange20sec<.5).*2;
    HRchange20sec(HRchange20sec>2) = log(HRchange20sec(HRchange20sec>2));
    
    figure(1)
    %plot(HRchange20sec.*60), hold on
    
    BPMvec = IBI2HRchange_halfsec(HRchange20sec, 22); 
    
    BPMvec = movmean(BPMvec,3);
    
    plot(BPMvec(1:16)), pause, hold off
       
    outarray(horse,:) = BPMvec(1:20); 
    
    
end
%%
% z-transform
for x = 1:numberhorses
outarray2(x,:) = (outarray(x,:)-nanmean(outarray(x,:)))./std(outarray(x,:));
end

% k-means
[IDX, C, SUMD, D] = kmeans(outarray2, 3);
outarraybsl = bslcorr(outarray, 1:2); 

figure
plot(mean(outarraybsl(IDX==1, :))), hold on
plot(mean(outarraybsl(IDX==2, :)))
plot(mean(outarraybsl(IDX==3, :)))

%%
for x = 1:numberhorses
HRdec(x) = min(outarray(x,1:6)-nanmean(outarray(x,2:2)))'
end

for x = 1:numberhorses
HRAcc(x) = max(outarray(x,1:12)-nanmean(outarray(x,2:4)))'
end

for x = 1:numberhorses
HRrange(x) = range(outarray(x,4:12)-nanmean(outarray(x,2:4)))'
end
%%