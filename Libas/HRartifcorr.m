
mat = CSm_HR; 
mat_new = zeros(size(mat)); 

time = 1:18; 

for sub = 1:18
    
    for x =1:60
       
        title([num2str(sub) ' ' num2str(x)]), 
        
        vec = squeeze(mat(sub,x,:));
        
        vec(vec<40)=median(vec(vec>40)); % eliminate non triggers 
        
        vec  = [median(median(mat(sub,:, :)));median(median(mat(sub,:, :))); vec; median(median(mat(sub,:, :))); median(median(mat(sub,:, :)))];
          
        indexlarge = find (diff(vec) > 10); if size(indexlarge,1) ~= 1, indexlarge = indexlarge'; end
        indexsmall = find (diff(vec) < -10); if size(indexsmall,1) ~= 1, indexsmall = indexsmall'; end   
                     
        indexlarge = cat(2, indexlarge, indexlarge+1);
        indexsmall = cat(2, indexsmall, indexsmall+1);
        
        indexreplace = unique([indexlarge indexsmall]);
        
         plot(vec, 'k--'), axis([0 20, 20 100]), hold on 
        
        
        
   % interpolate bad beats
   
           if length(indexreplace) > 12

               NewY = median(vec).* ones(1,16)
              

           else

           vec(indexreplace) = nan; 
           ind=~isnan(vec);
           NewY=interp1(time(ind),vec(ind),time, 'linear');
        
           end
            plot(NewY, 'r'), title([num2str(sub) ' ' num2str(x)]), hold off          
            pause(.1)          
            mat_new(sub,x,:) =  NewY(2:15); 
   
    end
end % sub