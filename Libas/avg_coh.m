%average spectral coherence or inter-site PLV values in N x N dimensions for specific frequency bands
%rather than doing an arithmetic mean of correlation coefficients, this
%first transforms the data to Z-scores, performs the averaging, then
%re-transforms back to raw coherence coefficients
% Inputs    filemat = the 3d coherence matrix produced by get_spec_coh or
% other connectivity function (current version assumes structure of sensors
% X frequencies X sensors)
%           faxis = the frequency axis produced by get_spec_coh
%           minf = the lower edge of the desired frequency band
%           maxf = the upper edge of the desired frequency band
% Outputs   avg_coh = the 2d N x N coherence matrix for the frequency band
% defined by the user

function[avg_connect] = avg_coh(filemat,faxis,minf,maxf)

%first figure out which frequency bins are needing to be averaged
%calculate lower frequency boundary
min_diff_vec = faxis-minf;
min_diff_vec = abs(min_diff_vec);
act_minf=find(min_diff_vec==min(min_diff_vec)); %the actual bin in the faxis corresponding to the desired lower bound

%calculate higher frequency boundary
max_diff_vec = faxis-maxf;
max_diff_vec = abs(max_diff_vec);
act_maxf=find(max_diff_vec==min(max_diff_vec)); %the actual bin in the faxis corresponding to the desired lower bound

%First transform r-values to Fisher's Z scores
outmat_z = .5 * log((1+(filemat(:,[act_minf:act_maxf],:))) ./ (1- (filemat(:,[act_minf:act_maxf],:)))); 

mean_outmat_z = squeeze(mean(outmat_z,2)); %now average and squeeze out the singleton dimension

%Now transform back to r-values using an inverse Fisher's Z
avg_connect = (exp(2*(mean_outmat_z))-1)./(exp(2*(mean_outmat_z))+1);
avg_connect(isnan(avg_connect)) = 1; %reset NaN diagonals in matrix to 1's

save avg_connectivity avg_connect -mat