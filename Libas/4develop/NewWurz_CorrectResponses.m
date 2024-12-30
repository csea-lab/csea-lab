% this is the script to loop the correct answer vector
% New_wurz

    cd '/Users/admin/Desktop/hengle/New_Wurzburg/csvfiles'
    
    filemat = getfilesindir(pwd, '*.csv');
    
    for subindex = 1:size(filemat, 1)
    
        filepath = deblank(filemat(subindex, :));
        
       [correct_reward, correct_shock] = New_Wurz_Correct_Response(filepath)
        values = [correct_reward(subindex,:), correct_shock(subindex,:)] 

    

        rep("sub1", size(correct_reward,2))
        
    end