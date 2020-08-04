bad = []; 
NUM = 0; 

    onsetactual = onsets229; 

 trialonset = 1:5:250;
 
 for x = 1:80

   % if NUM> 0, back = length(bad); else back = 0; end 
   
   back = length(bad)
    
    plot(template(trialonset(x-back):trialonset(x-back)+4)); 
    hold on 
    plot(diff(onsetactual(trialonset(x-back):trialonset(x-back)+5)), 'r');   
    hold off
    
    disp(trialonset(x-back):trialonset(x-back)+5)
    
    NUM = input('any trigger bad?')
    
    
    if NUM > 0, bad = [bad NUM]; onsetactual = [onsetactual 0]; onsetactual(NUM+1:end) = onsetactual(NUM:end-1); onsetactual(NUM)=onsetactual(NUM-1)+template(NUM);    
    
    end
    
    
    
end
