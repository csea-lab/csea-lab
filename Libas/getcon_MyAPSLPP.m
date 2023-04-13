function [] = getcon_MyAPSLPP(filepath)
condvec = []; 
picvec = [];

 p = [1510 1604 2045 ]

 u = [1205 1270 2092 ] 

 n = [1390 1419 1640 2010 2110]

fid = fopen(filepath)
count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, '.');
    index2 = findstr(a, '_');

    if ~isempty(index2)
        picnametmp = a(index2-8:index2-1);
        picname = str2num(picnametmp(1:2:end))
        AIcondition = 20
    else
        picnametmp = a(index1-8:index1-1);
        picname = str2num(picnametmp(1:2:end))
        AIcondition = 10
    end



%  	conletters = deblank(a(index1(1)+17:index1(1)+18));
%                
%             if strcmp(conletters, 'HA'), condvec = [condvec 1]
%             elseif strcmp(conletters, 'NE'), condvec = [condvec 2]
%             elseif strcmp(conletters, 'AN'), condvec = [condvec 3]  
%             elseif strcmp(conletters, 'AF'), condvec = [condvec 4]  
%             end
% 
%  end
% 
% fclose('all')
% 
% contentvec1234 = condvec'; 
% 
% con4EEG = contentvec1234; 
% 
% eval(['save ' filepath '.con con4EEG -ascii'])

end

