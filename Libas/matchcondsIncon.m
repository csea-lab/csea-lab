function [connew] = matchcondsIncon(filemat); 

for index = 1:size(filemat,1)
    
    % read file
    fid = fopen(filemat(index,:)); 
    
    throw = fgetl(fid); 
    
    for x = 1:144; 
        vec(x) = str2num(fgetl(fid)); 
    end
   
   % determin frequency of conditions 
    
   a= hist(vec, 130); 
   
   b = (a(a~=0)); 
   
   if length(b) ~= 12, error('one ore more conditions absent, or bad confile'); break, end

   c = b([1:6; 7:12])
   
   % find min number for each of 6 conditions
   
  minvec = min(c); 
  
  % go through conditions and complete random draw; 
  
  %match 101 and 201; 
  Indexvec101 = find(vec == 101); 
  Indexvec201 = find(vec == 201); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1001; 
    connew(Indexvec201) = 2001; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(1); 
                    connew(Indexvec101) = 1001; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(1)))) = 2001;
                    connew(Indexvec201(randomvec(minvec(1)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(1); 
                    connew(Indexvec201) = 2001; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(1)))) = 1001;
                    connew(Indexvec101(randomvec(minvec(1)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end
  
  %match 102 and 202, use the same indices, to avoid going crazy on variable renaming 
   
  Indexvec101 = []; Indexvec201 = []; 
   
  Indexvec101 = find(vec == 102); 
  Indexvec201 = find(vec == 202); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1002; 
    connew(Indexvec201) = 2002; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(2); 
                    connew(Indexvec101) = 1002; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(2)))) = 2002;
                    connew(Indexvec201(randomvec(minvec(2)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(2); 
                    connew(Indexvec201) = 2002; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(2)))) = 1002;
                    connew(Indexvec101(randomvec(minvec(2)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end
                
                    
  %match 103 and 203, use the same indices, to avoid going crazy on variable renaming 
   
  Indexvec101 = []; Indexvec201 = []; 
   
  Indexvec101 = find(vec == 103); 
  Indexvec201 = find(vec == 203); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1003; 
    connew(Indexvec201) = 2003; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(3); 
                    connew(Indexvec101) = 1003; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(3)))) = 2003;
                    connew(Indexvec201(randomvec(minvec(3)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(3); 
                    connew(Indexvec201) = 2003; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(3)))) = 1003;
                    connew(Indexvec101(randomvec(minvec(3)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end
  
  %match 104 and 204, use the same indices, to avoid going crazy on variable renaming 
   
  Indexvec101 = []; Indexvec201 = []; 
   
  Indexvec101 = find(vec == 104); 
  Indexvec201 = find(vec == 204); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1004; 
    connew(Indexvec201) = 2004; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(4); 
                    connew(Indexvec101) = 1004; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(4)))) = 2004
                    connew(Indexvec201(randomvec(minvec(4)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(4); 
                    connew(Indexvec201) = 2004; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(4)))) = 1004
                    connew(Indexvec101(randomvec(minvec(4)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end
  
    %match 105 and 205, use the same indices, to avoid going crazy on variable renaming 
   
  Indexvec101 = []; Indexvec201 = []; 
   
  Indexvec101 = find(vec == 105); 
  Indexvec201 = find(vec == 205); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1005; 
    connew(Indexvec201) = 2005; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(5); 
                    connew(Indexvec101) = 1005; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(5)))) = 2005;
                    connew(Indexvec201(randomvec(minvec(5)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(5); 
                    connew(Indexvec201) = 2005; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(5)))) = 1005;
                    connew(Indexvec101(randomvec(minvec(5)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end
  
     %match 105 and 205, use the same indices, to avoid going crazy on variable renaming 
   
  Indexvec101 = []; Indexvec201 = []; 
   
  Indexvec101 = find(vec == 106); 
  Indexvec201 = find(vec == 206); 
  
  if length(Indexvec101) == length(Indexvec201), 
      %do nothing, just add new labels
    connew(Indexvec101) = 1006; 
    connew(Indexvec201) = 2006; 
  else

  % assign a random subsample of the longer vec with new labels, leave the
  % other vector alone
                if length(Indexvec101) == minvec(6); 
                    connew(Indexvec101) = 1006; 
                    randomvec = randperm(length(Indexvec201))
                    connew(Indexvec201(randomvec(1:minvec(6)))) = 2006;
                    connew(Indexvec201(randomvec(minvec(6)+1:length(Indexvec201)))) = 5000; 
                elseif length(Indexvec201) == minvec(6); 
                    connew(Indexvec201) = 2006; 
                    randomvec = randperm(length(Indexvec101))
                    connew(Indexvec101(randomvec(1:minvec(6)))) = 1006;
                    connew(Indexvec101(randomvec(minvec(6)+1:length(Indexvec101)))) = 5000; 
                else error('fehler'), return, end
  end

hist(connew,130), pause, 
  
  fid2 = fopen([deblank(filemat(index,:)) 'cf.CON'], 'w');
  fprintf(fid2, '144 1\n');
  for x = 1:144, fprintf(fid2, [num2str(connew(x)) '\n']); end
  
fclose('all'); 
end
  