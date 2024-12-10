function [effect_dist_bootstrap, nullperm_dist_bootstrap] = bootstrap_diffs(mat1,mat2)
% calculates the boostrapped distribution for a difference between 2 matched
% conditions, using paired t-tests.
% input is 3D arrays  sensors, by timepoints, by participants

ndraws = 2000; 

nsubjects = size(mat1,3);

temparray4perm = cat(4,mat1, mat2); 
temparray4perm_loop = nan(size(temparray4perm));

nullperm_dist_bootstrap = nan( size(mat1,1),  size(mat1,2), ndraws);  
effect_dist_bootstrap = nan( size(mat1,1),  size(mat1,2), ndraws); 

% make bootstrap distributions of differences 
for draw = 1:ndraws
    bootstrapvec = randi(nsubjects, 1,nsubjects)';
    mat1_bootstrap = mat1(:, :, bootstrapvec);
    mat2_bootstrap = mat2(:, :, bootstrapvec);

    if draw/100 == round(draw./100), sprintf('%s', ['draw: ' num2str(draw) ' of ' num2str(ndraws)]), end

    % for the unpermuted data
    % calculate the tvalues between the matrices: 
    [~, ~, ~, stats] = ttest(mat1_bootstrap, mat2_bootstrap, 'Dim', 3); 
    effect_dist_bootstrap(:, :, draw) = stats.tstat;

    %for bootstrapped distribution of the null model, scramble the
    %conditions for each subject
   a = ceil(rand(1,nsubjects).*2)'; b = abs(a*-1 +3);
    permindices = [a b];
   for subindex_perm = 1:nsubjects
    temparray4perm_loop(:, :, subindex_perm, 1:2)= temparray4perm(:, :, subindex_perm, permindices(subindex_perm,:));
   end

   [~, ~, ~, stats_perm] = ttest(squeeze(temparray4perm_loop(:, :, :, 1)), squeeze(temparray4perm_loop(:, :, :, 2)), 'Dim', 3); 
    nullperm_dist_bootstrap(:, :, draw) = stats_perm.tstat;

end


