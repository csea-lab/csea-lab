function [con4EEG] = getcon_changeface(filepath);
condvec = []; 

picvec = [];

fid = fopen(filepath)
count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, 'A');
 	conletters = deblank(a(index1(1)+17:index1(1)+18));
               
            if strcmp(conletters, 'HA'), condvec = [condvec 1]
            elseif strcmp(conletters, 'NE'), condvec = [condvec 2]
            elseif strcmp(conletters, 'AN'), condvec = [condvec 3]  
            elseif strcmp(conletters, 'AF'), condvec = [condvec 4]  
            end

 end

fclose('all')

contentvec1234 = condvec'; 

con4EEG = contentvec1234; 

eval(['save ' filepath '.con con4EEG -ascii'])

end

