
repmat = repeatmat_correctorder;

for run = 1:5000
    
    for subject = 1:67
        
        repmat(:, subject, :) = repeatmat_correctorder(:, subject, randperm(6)); 
    
    end
    
        [Fcontperm,rcontmat,MScont,MScs, dfcs]=contrast_rep(repmat,weights_mexhat);
        
        fmaxvec(run) = quantile(Fcontperm, .99); 
        
        if run./100 == round(run./100), fprintf('.'), end
        
end