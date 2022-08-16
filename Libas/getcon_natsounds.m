function [convec] = getcon_natsounds(datfilepath)
% read a dat file for the natsounds study and generates a vector of numbers
% corresponding to the condition of eacha trial: 1 pleasant, 2 ntr, 3 upl,
% 4 miso

fid = fopen(datfilepath);

convec = []; 

line = [1 1]; 

while line > 0
    
      line = fgetl(fid);
        
      if length(line) > 1
        letter = line(length(line)-22);
        if letter == 'P', convec = [convec; 1]; 
        elseif letter == 'N', convec = [convec; 2]; 
        elseif letter == 'U', convec = [convec; 3]; 
        elseif letter == 'M', convec = [convec; 4];
        end
        
      end

end




