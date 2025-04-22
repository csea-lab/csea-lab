function [singpicvec_num_sorted, val_sorted, aro_sorted] = getcon_MyAPS2_affspace(filepath)
picvec = [];
condvec4ERP = []; 

trialindex = 1

 p = {'IAPSp01' ; 'IAPSp02' ; 'IAPSp03' ; 'IAPSp04' ; 'IAPSp05' ; 'IAPSp06' ; 'IAPSp07' ; 'IAPSp08' ; 'IAPSp09' ; 'IAPSp10' ; 'IAPSp11' ; 'IAPSp12' ; 'IAPSp13' ; 'IAPSp14' ; 'IAPSp15' ; 'IAPSp16' ; 'IAPSp17' ; 'IAPSp18' ; 'IAPSp19' ; 'IAPSp20' ; 'UGASp21' ; 'UGASp22' ; 'UGASp23' ; 'UGASp24' ; 'UGASp25' ; 'UGASp26' ; 'UGASp27' ; 'UGASp28' ; 'UGASp29' ; 'UGASp30' ; 'UGASp31' ; 'UGASp32' ; 'UGASp33' ; 'UGASp34' ; 'UGASp35' ; 'UGASp36' ; 'UGASp37' ; 'UGASp38' ; 'UGASp39' ; 'UGASp40' ; 'MYPSp01' ; 'MYPSp02' ; 'MYPSp03' ; 'MYPSp04' ; 'MYPSp05' ; 'MYPSp06' ; 'MYPSp07' ; 'MYPSp08' ; 'MYPSp09' ; 'MYPSp10' ; 'MYPSp11' ; 'MYPSp12' ; 'MYPSp13' ; 'MYPSp14' ; 'MYPSp15' ; 'MYPSp16' ; 'MYPSp17' ; 'MYPSp18' ; 'MYPSp19' ; 'MYPSp20' ; 'MYPSp21' ; 'MYPSp22' ; 'MYPSp23' ; 'MYPSp24' ; 'MYPSp25' ; 'MYPSp26' ; 'MYPSp27' ; 'MYPSp28' ; 'MYPSp29' ; 'MYPSp30' ; 'MYPSp31' ; 'MYPSp32' ; 'MYPSp33' ; 'MYPSp34' ; 'MYPSp35' ; 'MYPSp36' ; 'MYPSp37' ; 'MYPSp38' ; 'MYPSp39' ; 'MYPSp40'};
 
 u = {'IAPSu01' ; 'IAPSu02' ; 'IAPSu03' ; 'IAPSu04' ; 'IAPSu05' ; 'IAPSu06' ; 'IAPSu07' ; 'IAPSu08' ; 'IAPSu09' ; 'IAPSu10' ; 'IAPSu11' ; 'IAPSu12' ; 'IAPSu13' ; 'IAPSu14' ; 'IAPSu15' ; 'IAPSu16' ; 'IAPSu17' ; 'IAPSu18' ; 'IAPSu19' ; 'IAPSu20' ; 'UGASu21' ; 'UGASu22' ; 'UGASu23' ; 'UGASu24' ; 'UGASu25' ; 'UGASu26' ; 'UGASu27' ; 'UGASu28' ; 'UGASu29' ; 'UGASu30' ; 'UGASu31' ; 'UGASu32' ; 'UGASu33' ; 'UGASu34' ; 'UGASu35' ; 'UGASu36' ; 'UGASu37' ; 'UGASu38' ; 'UGASu39' ; 'UGASu40' ; 'MYPSu01' ; 'MYPSu02' ; 'MYPSu03' ; 'MYPSu04' ; 'MYPSu05' ; 'MYPSu06' ; 'MYPSu07' ; 'MYPSu08' ; 'MYPSu09' ; 'MYPSu10' ; 'MYPSu11' ; 'MYPSu12' ; 'MYPSu13' ; 'MYPSu14' ; 'MYPSu15' ; 'MYPSu16' ; 'MYPSu17' ; 'MYPSu18' ; 'MYPSu19' ; 'MYPSu20' ; 'MYPSu21' ; 'MYPSu22' ; 'MYPSu23' ; 'MYPSu24' ; 'MYPSu25' ; 'MYPSu26' ; 'MYPSu27' ; 'MYPSu28' ; 'MYPSu29' ; 'MYPSu30' ; 'MYPSu31' ; 'MYPSu32' ; 'MYPSu33' ; 'MYPSu34' ; 'MYPSu35' ; 'MYPSu36' ; 'MYPSu37' ; 'MYPSu38' ; 'MYPSu39' ; 'MYPSu40'};
 
 n = {'IAPSn01' ; 'IAPSn02' ; 'IAPSn03' ; 'IAPSn04' ; 'IAPSn05' ; 'IAPSn06' ; 'IAPSn07' ; 'IAPSn08' ; 'IAPSn09' ; 'IAPSn10' ; 'IAPSn11' ; 'IAPSn12' ; 'IAPSn13' ; 'IAPSn14' ; 'IAPSn15' ; 'IAPSn16' ; 'IAPSn17' ; 'IAPSn18' ; 'IAPSn19' ; 'IAPSn20' ; 'UGASn21' ; 'UGASn22' ; 'UGASn23' ; 'UGASn24' ; 'UGASn25' ; 'UGASn26' ; 'UGASn27' ; 'UGASn28' ; 'UGASn29' ; 'UGASn30' ; 'UGASn31' ; 'UGASn32' ; 'UGASn33' ; 'UGASn34' ; 'UGASn35' ; 'UGASn36' ; 'UGASn37' ; 'UGASn38' ; 'UGASn39' ; 'UGASn40' ; 'MYPSn01' ; 'MYPSn02' ; 'MYPSn03' ; 'MYPSn04' ; 'MYPSn05' ; 'MYPSn06' ; 'MYPSn07' ; 'MYPSn08' ; 'MYPSn09' ; 'MYPSn10' ; 'MYPSn11' ; 'MYPSn12' ; 'MYPSn13' ; 'MYPSn14' ; 'MYPSn15' ; 'MYPSn16' ; 'MYPSn17' ; 'MYPSn18' ; 'MYPSn19' ; 'MYPSn20' ; 'MYPSn21' ; 'MYPSn22' ; 'MYPSn23' ; 'MYPSn24' ; 'MYPSn25' ; 'MYPSn26' ; 'MYPSn27' ; 'MYPSn28' ; 'MYPSn29' ; 'MYPSn30' ; 'MYPSn31' ; 'MYPSn32' ; 'MYPSn33' ; 'MYPSn34' ; 'MYPSn35' ; 'MYPSn36' ; 'MYPSn37' ; 'MYPSn38' ; 'MYPSn39' ; 'MYPSn40'};

fid = fopen(filepath);
count = 1;
a = 1;
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	index1 = findstr(a, 'IAPS');
    index2 = findstr(a, 'UGAS');
    index3 = findstr(a, 'MYPS');

    if ~isempty(index1)
        picnametmp = a(index1:index1+6);
        picname = char(picnametmp)
        AIcondition = 10;
    elseif ~isempty(index2)
        picnametmp = a(index2:index2+6);
        picname = char(picnametmp)
        AIcondition = 10;
    elseif ~isempty(index3)
        picnametmp = a(index3:index3+6);
        picname = char(picnametmp)
        AIcondition = 20;
    end
   
    
    if sum(contains(picname, p)) > 0, concode = 1;
    elseif sum(contains(picname, n)) > 0, concode = 2; 
    elseif sum(contains(picname, u)) > 0, concode = 3;
    end
    
    picvec = [ picvec; picname];
    
    condvec4ERP = [condvec4ERP; AIcondition+concode]; 
    
 end
 
 numvecStr = (picvec(:, end-1:end));
 singpicvec_string = [ num2str(condvec4ERP) numvecStr];
 singpicvec_num = str2num(singpicvec_string);
 
 tbl = readtable(filepath);
 arousal = table2array(tbl(:, 3));
 valence = table2array(tbl(:, 4));
 
 % now, we sort the pictures and apply the sorting order to val and arousal
 
 [singpicvec_num_sorted, indices4sort] = sort(singpicvec_num); 
 
 aro_sorted = arousal(indices4sort); 
 val_sorted = valence(indices4sort); 
 
 
 
 
 
 