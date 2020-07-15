function [percentcorrect, accuracybycond] = getcon_intermodaltask(datfilemat)
%gets behavioral accuracy (and eventually more) for intermodaltask

for findex = 1:size(datfilemat)
    
    a = load(deblank(datfilemat(findex,:))); 
   
    resp = a(:,4); 
    actual = a(:,5);
    
    condition = a(:,7); 
    
    resp(resp~=37) = 0; 
    resp(resp==37) = 1; 
       
    actual(actual>0) = 1; 
    
    correctvec = zeros(120,1); 
    
    for x = 1:120
        if actual(x) == resp(x), correctvec(x) = 1; 
        else correctvec(x) = 0;
        end
    end
    
    percentcorrect(findex) = sum(correctvec)./120; 
    
    % find accuracy by content
    % blips during neutral
    only11 = correctvec(condition==11); 
    only12 = correctvec(condition==12);
    only21 = correctvec(condition==21);    
    only22 = correctvec(condition==22); 

   
   accuracybycond(findex,1) = sum(only11)./length(only11) ;
   accuracybycond(findex,2) = sum(only12)./length(only12); 
   accuracybycond(findex,3) = sum(only21)./length(only21);
   accuracybycond(findex,4) = sum(only22)./length(only22); 
    
end

percentcorrect = percentcorrect'; 
