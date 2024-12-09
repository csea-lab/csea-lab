function [effect_dist, null_dist] = boostrap_diffs(mat1,mat2, subjectDim)
% calculates the boostrapped distribution for a difference between 2 matched
% conditions, using paired t-tests.
% input is 3D arrays with sensors, by timepoints, by participants

ndraws = 1000; 

% make bootstrap distributions of differences 
for draw = 1:ndraws

    if draw./100 == round(draw./100), sprintf('%s', ['draw: ' num2str(draw) ' of ' num2str(ndraws)]), end

    %for boostrapped distribution of the null model, scramble the
    %conditions for each subject
    repmat_null = repmat; 
    for sub = 1:31 
        repmat_null(:, bin, sub, :) = repmat_null(:, bin, sub, randperm(12)) ;
    end

    innerprod_null(:, draw) = rangecorrect(squeeze(mean(repmat_null(:, bin, randi(31, 1,31), 1:4), 3))) * generGauss(randperm(4))';

%     % habituation
%     innerprod_hab_sharp(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * sharp';
%     innerprod_hab_gauss(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * generGauss';
%     innerprod_hab_genMcTea(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 1:4), 3)) * generMcteague';

     % acquisition
    innerprod_acq_gen(:, draw) = rangecorrect(squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3))) * generalization';
    innerprod_acq_sharp2(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * sharpening';
    innerprod_acq_cond(:, draw) = squeeze(mean(repmat(:, bin, randi(31, 1,31), 5:8), 3)) * conditioning';
    
     % extinction
    innerprod_ext_gen(:, draw) = rangecorrect(squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3))) * generalization';
    innerprod_ext_sharp2(:, draw) = rangecorrect(squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3))) * sharpening';
    innerprod_ext_cond(:, draw) = rangecorrect(squeeze(mean(repmat(:, bin, randi(31, 1,31), 9:12), 3))) * conditioning';


end


