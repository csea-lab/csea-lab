function [convec] = getcon_gaborgen24_day2(datfilepath)
% read a dat file for the gaborgen study and generates a vector of numbers
% corresponding to the condition of eacha trial and block: 
% 11 to 14 habituation CS+ through GS3
% 21 to 24 acquition CS+ through GS4 unpaired/ 25 for paired in acq
% 31 to 34 extinction CS+ through GS4

fid = fopen(datfilepath);

convec = []; 

line = fgetl(fid);

while line > 0
    
      line = fgetl(fid);
        
      if length(line) > 1
     
       commaindices = strfind(line, ',');

        blockindex = str2num(line(commaindices(1)+1)); 
        conditionindex = str2num(line(commaindices(3)+1)); 
          
        convec = [convec; conditionindex.*10 ];
        
      end

end

% dlmwrite
