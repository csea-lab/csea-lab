function [conditionvec] = getCon_NewWurz_singleTrial_2trigs(filepath)
    % First, read in a new_wurz log file with RTs and everything
    table = readtable(filepath);
    
    % Extract the first column as a vector
    original = table{:,1};
    
    % Preallocate a new vector that is twice as long
    conditionvec = zeros(length(original) * 2, 1);
    
    % Fill the new vector with original and +100 interleaved
    conditionvec(1:2:end) = original;
    conditionvec(2:2:end) = original + 1000;

    conditions2select =  cellstr(string([conditionvec]'))
    % conditionvec = table2array(conditionvec(:, 1));
end