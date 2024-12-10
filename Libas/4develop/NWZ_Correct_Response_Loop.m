% this is the script to loop the correct response of NWZ for all subjects

    cd '/Volumes/TOSHIBA EXT/New_Wurzburg/csvfiles'
    
    filemat = getfilesindir(pwd, '*.csv')

    correct_reward = NaN(size(filemat, 1), 93); % subjects by number of trials NaN matrix
    correct_shock = NaN(size(filemat, 1), 93); 
    slopes = NaN(size(filemat, 1), 4);
    
    for subindex = 1:size(filemat, 1)
    
        filepath = deblank(filemat(subindex, :));
        
        [reward_temp, shock_temp, shock_slope, reward_slope] = New_Wurz_Correct_Response(filepath);

        correct_reward(subindex, 1:size(reward_temp, 2))=reward_temp;
        correct_shock(subindex, 1:size(shock_temp, 2))=shock_temp; 
        slopes(subindex, :) = [shock_slope, reward_slope];

    
    end