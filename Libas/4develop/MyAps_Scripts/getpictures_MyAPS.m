function [outmat_1, outmat_2, picvec, valence, arousal, AiVec] = getpictures_MyAPS(filepath)

picvec = [];
trialnums  = []; 
unparsedratings = []; 
arousal = []; 
valence = []; 
AiVec = []; 

trialindex = 1

 p = [4180 2045 4210 2300 2314 2540 4232 4001 2550 4601 4628 4604 7502 4150 4505 4574 7405 7451 4770];

 u = [1270 9491 1205 2092 2900 3016 2110 6211 9075 6940 3101 3230 3051 9140 9570 9300 9630 9900 9905 9909] ;

 n = [1640 1604 1510 2010 9430 2580 2850 2446 2484 2499 5395 5470 5600 7186 5661 5455 5551 5665 5779 1419];
 
 o = [5910 4597]

fid = fopen(filepath)
count = 1;
a = 1;
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, '.');
    index2 = findstr(a, '_');

    if ~isempty(index2)
        picstartindex = index2-8; 
        picnametmp = a(index2-8:index2-1);
        picname = str2num(picnametmp(1:2:end));
        AIcondition = 20000;
    else
        picstartindex = index1-8; 
        picnametmp = a(index1-8:index1-1);
        picname = str2num(picnametmp(1:2:end));
        AIcondition = 10000;
    end

    if ismember(picname, p), concode = 1; 
    elseif ismember(picname, n), concode = 2; 
    elseif ismember(picname, u), concode = 3;
    elseif ismember(picname, o), concode = 4
    end
    
    picvec = [ picvec; picname+AIcondition];
    
    AiVec = [AiVec; AIcondition]; 
    
    % now, the ratngs stuff
    subject = a(1:2:5); 
    
    
    if trialindex < 10, triallength = 1; 
    elseif trialindex > 9 && trialindex < 100, triallength = 2;
    else triallength = 3; 
    end   
        
        trialnumend = 6+triallength*2; 
        
        trialnums = [trialnums str2num(a(7:2:trialnumend))]; 
        
        unparsedratings = [a(trialnumend+1:2:picstartindex-1)];
        
        index3 = findstr(unparsedratings, ';');
        
        arousal = [arousal; str2num(unparsedratings(1:index3-1))]
        valence  = [valence; str2num(unparsedratings(index3+1:end))]
    
        trialindex = trialindex + 1
    

trialnums

 end

 outmat_temp = [picvec valence arousal AiVec]; 
 
 outmat_1_temp = outmat_temp(1:120,:);
 outmat_2_temp = outmat_temp(121:end,:);
 
 outmat_1 = sortrows(outmat_1_temp,1);
 outmat_2 = sortrows(outmat_2_temp,1);

eval(['save ' filepath 'rating1.mat outmat_1'])

eval(['save ' filepath 'rating2.mat outmat_2'])
