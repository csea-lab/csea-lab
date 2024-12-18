cd '/Users/admin/Desktop/hengle/New_Wurzburg/csvfiles'
filemat = getfilesindir(pwd, '*.csv');
for x = 1:size(filemat,1)
    [corr_reward_noflip(x), corr_shock_noflip(x), BETA_shock_noflip(x,:), BETA_reward_noflip(x,:), rewardtable, shocktable] = hannah_preproRescorla(deblank(filemat(x,:)), 0); pause
    [corr_reward_flip(x), corr_shock_flip(x), BETA_shock_flip(x,:), BETA_reward_flip(x,:), rewardtable, shocktable] = hannah_preproRescorla(deblank(filemat(x,:)), 1); pause
end
