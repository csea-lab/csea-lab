function [errorvec] = withinerror(inmat)
% calculates the within subjects error for plots and such
% this version does two conditions only
%input given as matrix in which each condition is col and each subject is a
%row
%http://www.cogsci.nl/blog/tutorials/156-an-easy-way-to-create-graphs-with-within-subject-error-bars
data = inmat; 

%first, demean each row and add new (grand)mean
for x = 1:size(inmat,1)
data(x,:) = inmat(x,:)-mean(inmat(x,:))+mean(mean(inmat));
end

% now 
errorvec = std(data)./sqrt(size(inmat,1));


