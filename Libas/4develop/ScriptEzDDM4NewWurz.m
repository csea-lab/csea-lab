% this is the script for the EZ diffusion model fit for each subject in
% New_wurz

    cd '/Volumes/TOSHIBA EXT/New_Wurzburg/csvfiles'
    
    filemat = getfilesindir(pwd, '*.csv');

    correct_reward = NaN(size(filemat, 1), 93); % subjects by number of trials NaN matrix
    correct_shock = NaN(size(filemat, 1), 93); 
    
%     subjectmat4Ezparams = nan(size(filemat, 1), 12);
    
    for subindex = 1:size(filemat, 1)
    
        filepath = deblank(filemat(subindex, :));
    
%         [~, ~, ~, ~, outvec] = hannah_ezDDM(filepath); 
        
        [reward_temp, shock_temp] = New_Wurz_Correct_Response(filepath);

        correct_reward(subindex, 1:size(reward_temp, 2))=reward_temp;
        correct_shock(subindex, 1:size(shock_temp, 2))=shock_temp;

    
%         subjectmat4Ezparams(subindex, :) = outvec; 
    
    
    end

    %%
    % the section calculates slope of line
   

counter = 1;
for i = 1:1:size(filemat, 1)
    x = [1:93];
    y = shock_temp;
    line = polyfit(x, y, 1);
    m(counter) = line(1);
    b(counter) = line(2);
    counter = counter +1;
end
meanSlope = mean(m)
meanInt = mean(b)
avgLine = polyfit(meanSlope, meanInt, 1)
