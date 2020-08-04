%horseifant
fclose('all'); 

fid = fopen('Weanling 4-5-19 name wo spaces.csv'); 
header = fgetl(fid); 

outarray = nan(80, 16); 

for horse = 1:80
    temp = fgetl(fid);
    IND = strfind(temp,','); %find commas
    % find startle time
    startletimestring = temp(IND(7)+1 : IND(8)-1); ind2 = strfind(startletimestring,':'); 
    startletime_ms = (str2double(startletimestring(1:ind2-1)).*60 + str2double(startletimestring(2+1:end))).*1000
    % find HR
    temp2 = temp(IND(25)+1:end); % HR segment
    temp2(strfind(temp2, ',')) = ' '; 
    HRtime = str2num(temp2);
    
    if ~isempty(HRtime) && ~isnan(startletime_ms)
        if HRtime(1) < 300 % it is already BPM ! convert back to ms IBIs only for finding start time   
        findstartlevec = cumsum((60./[HRtime]).*1000);
        startindex = min(find(findstartlevec>startletime_ms./5)); 
        BPMvec = HRtime(startindex:startindex + 17); 
        else
        findstartlevec = cumsum(HRtime);
        startindex = min(find(findstartlevec>startletime_ms));         
        HRchange20sec = HRtime(startindex:startindex + 20);
        BPMvec = IBI2HRchange_core(cumsum(HRchange20sec./1000), 20); 
        end
         plot(BPMvec(2:15)), pause(.3)
    else       
    BPMvec = nan(1,16); 
    end
    
   
    
    outarray(horse,:) = BPMvec(1:16); 
    
    
end

for x = 1:80
outarray2(x,1:12) = (outarray(x,1:12)-nanmean(outarray(x,1:12)))./nan_std(outarray(x,1:12));
end

for x = 1:80
HRdec(x) = min(outarray(x,1:6)-nanmean(outarray(x,2:2)))'
end

for x = 1:80
HRAcc(x) = max(outarray(x,1:12)-nanmean(outarray(x,2:4)))'
end

for x = 1:80
HRrange(x) = range(outarray(x,4:12)-nanmean(outarray(x,2:4)))'
end