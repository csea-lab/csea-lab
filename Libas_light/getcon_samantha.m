% 
% searches condnumbers in *dat file generarted by exp psyctb file

function [totalmat, rtvec] = getcon_samantha(filemat);

 totalmat = []; 

for fileindex = 1 :size(filemat,1)
    
    filepath = deblank(filemat(fileindex,:)); 
    
    lettersidevec = []; %left key/letter = 1, right key/letter = 2; 
    tonesidevec= []; % left tone = 1, both = 0; 
    rtvec = []; 
    respkeyvec = []; 
 
    correctvec = []; 
   
   
fid = fopen(filepath);
header = fgetl(fid)

for trial = 1:90
	
    a = fgetl(fid)
    
end

pause
   
for trial = 1:90
   
       a = fgetl(fid)
    if a > 0
    
        indexvec = findstr(a, ','); % 
        if strcmp(a(1), 'l'), lettersidevec(trial) = 2; elseif  strcmp(a(1), 'a'), lettersidevec(trial) = 1; end
       if strcmp(a(indexvec(2)+1), 'l'), tonesidevec(trial) = 1; elseif  strcmp(a(indexvec(2)+1), 'r'), tonesidevec(trial) = 2; else tonesidevec(trial) = 0; end
       if strcmp(a(indexvec(13)+1), 'l'), respkeyvec(trial) = 1; elseif  strcmp(a(indexvec(13)+1), 'r'), respkeyvec(trial) = 2; end
       rtvec(trial) = str2num(a(indexvec(14)+1:indexvec(15)-1)); 
    end
end

%calccorrect
for x1 = 1:90
    if lettersidevec(x1) ==respkeyvec(x1), correctvec(x1) = 1; else correctvec(x1) = 0; end
end

%overallcorrect = sum(correctvec)./90, pause

size(lettersidevec), size(tonesidevec), size(respkeyvec), size(rtvec), size(rtvec), size(correctvec)
fullmat1 = [lettersidevec' tonesidevec' respkeyvec' rtvec' correctvec']

% calc 6 conditions - correct and RT
% letterside (2) by tonesside (3)

  rt_leftletter_lefttone = mean(fullmat1(fullmat1(:,1)==1&fullmat1(:,2)==1, 4));
  rt_leftletter_bothtone = mean(fullmat1(fullmat1(:,1)==1&fullmat1(:,2)==0, 4));
  rt_leftletter_righttone = mean(fullmat1(fullmat1(:,1)==1&fullmat1(:,2)==2, 4));
  rt_rightletter_lefttone = mean(fullmat1(fullmat1(:,1)==2&fullmat1(:,2)==1, 4));
  rt_rightletter_bothtone = mean(fullmat1(fullmat1(:,1)==2&fullmat1(:,2)==0, 4));
  rt_rightletter_righttone = mean(fullmat1(fullmat1(:,1)==2&fullmat1(:,2)==2, 4));

  outvecRT = [rt_leftletter_lefttone rt_leftletter_bothtone rt_leftletter_righttone rt_rightletter_lefttone rt_rightletter_bothtone rt_rightletter_righttone];
  
 fclose('all')
 
 totalmat = [totalmat; outvecRT]
end


