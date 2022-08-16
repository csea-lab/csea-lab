mat3d  = mat4dearly(:, :, 8:14); 

subjects = 29

% mat3d e.g.  129 by   29 people  by  7 conditions (averaged over time) 

% step 1 regularization with group average, to avoid noisy fits
grpavg = (mean(mat3d, 2));

for subject = 1:size(mat3d,2)
    mat3dreg(:, subject, :) = mat3d(:, subject, :) + grpavg; 
end

% step 2 fit the model
for sensor = 1:129

    mat2d = squeeze(mat3d(sensor, :, :)); 

    invec = mat2vec(mat2d'); 

    % divide by the max
    invec = invec./max(invec);

    % the gaussian function
    % where p(1) is the mean and p(2) is the std
    modelFun1 = @(p,x) repmat(exp(-(x-p(1)).^2/2/p(2).^2), [1 subjects]);  

    % starting values for Gaussian
    startingValsGauss = [0 .5 1];

    % do the actual Gaussian fit
    [betagauss(:, sensor),rgauss,J,Sigma,msegauss(sensor)]  = nlinfit(-3:3, invec, modelFun1, startingValsGauss);

end

