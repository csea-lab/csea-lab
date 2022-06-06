function [con] = dat2con_gaborgen24(datfilepath)

fid = fopen(datfilepath);

fgetl(fid) % read header

temp = [1 1]; 

convec = []; 

while temp > 0
    
      temp = fgetl(fid);
        
      if length(temp) > 1
        temp2 = str2num(temp); %#ok<ST2NM>
        if temp2(4) == 11
            convec = [convec; 10];%#ok<AGROW>
        else
            convec = [convec; temp2(4)];%#ok<AGROW>
        end
        
      end

end

fclose(fid);

if length(convec) == 228

    block = [ones(40,1).*100; ones(128,1).*200; ones(60,1).*300];

    con = block + convec;
    
else
   
    block = [ones(72, 1).*100; ones(72,1).*200];
    
    con = block + convec;
    
end



