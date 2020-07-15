function [condvec] = getcon_sheinbug(filepath);

condvec = []; 
correctvec = []; 
RTvec = []; 

fid = fopen(filepath)
count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid);
     
     if a < 0, break, return, end
 	
     index1 = findstr(a, ' ');
    
 	conletters = deblank(a(index1(5)+1:index1(5)+2));
             
    % label conditions with numbers
            if strcmp(conletters, 'AM'), condvec = [condvec; 1]
            elseif strcmp(conletters, 'AF'), condvec = [condvec; 2]
            elseif strcmp(conletters, 'ag'), condvec = [condvec; 3]  
            elseif strcmp(conletters, 'sg'), condvec = [condvec; 4]  
            end
    % get correct (1) or incorrect 0 for each trial         
            correctvec = [correctvec; str2num(a(index1(4)+1:index1(4)+2))]
            
     % get RT for each trial  
            RTvec = [RTvec; str2num(a(index1(3)+1:index1(4)))]
            
     %  get correct and RT by condition
     percentcorrect4cons =   [sum(correctvec(condvec==1))./35 sum(correctvec(condvec==2))./35 sum(correctvec(condvec==3))./35 sum(correctvec(condvec==3))./35]     
     medianRT4cons = [median(RTvec(condvec==1)) median(RTvec(condvec==2)) median(RTvec(condvec==3)) median(RTvec(condvec==4))]

 end

fclose('all')

% contentvec1234 = condvec'; 
% 
% con4EEG = contentvec1234; 
% 
% eval(['save ' filepath '.con con4EEG -ascii'])

end

