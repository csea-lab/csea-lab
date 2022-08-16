for x = 1:1695, h6(:,x) = hrf_est(sub10_1_v1(:,x), sub10_1_onsets(:,2), 6); end % estimates the IRF fro each pixel. 

onsets = zeros(1,205);
onsets(sub10_1_onsets(:,2)-1) = 1;
inputs.onsetvec = onsets;  % these three lines just make the onsetvec, in the format the function needs. we could streamline this, by enetering only the onset time stamps. function always knows num of TRs anyway ...

for x = 1:1695, inputs.kernel  = h6(:, x); [BETA6(:,x),R,J,COVB,MSE(x)] = nlinfit(inputs, sub10_1_v1(:,x)', @irf_convolve, ones(1,32)); end  % this line gets the betas (32 magnitudes, 1 for each trial) based on the empirical IRF