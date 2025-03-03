% jude analysis of the ssVEP data for COLNE abstract 
clc
% read in the data
clear
load('/Users/andreaskeil/UFL Dropbox/Andreas Keil/JudeGaborgen/CS1.mat')
load('/Users/andreaskeil/UFL Dropbox/Andreas Keil/JudeGaborgen/CS2.mat')
load('/Users/andreaskeil/UFL Dropbox/Andreas Keil/JudeGaborgen/CS3.mat')
load('/Users/andreaskeil/UFL Dropbox/Andreas Keil/JudeGaborgen/CSP.mat')
%% use only sensor 20 (Oz) and smooth with a kernel of 5 points, then baseline correct
smoothwindow = 5;
submatCSp =  movmean(squeeze(matrix_CSP_total(20, :, :)), smoothwindow,1, 'omitnan'); % smoothing
submatCSp = fillmissing(submatCSp, "linear", 1); % interpolate NaNs
submatCSp_bsl = bslcorr(submatCSp', 6:8)'; 

submatCS1 =  movmean(squeeze(matrix_CS1_total(20, :, :)), smoothwindow,1, 'omitnan'); % smoothing
submatCS1 = fillmissing(submatCS1, "linear", 1); % interpolate NaNs
submatCS1_bsl = bslcorr(submatCS1', 6:8)'; 

submatCS2 =  movmean(squeeze(matrix_CS2_total(20, :, :)), smoothwindow,1, 'omitnan'); % smoothing
submatCS2 = fillmissing(submatCS2, "linear", 1); % interpolate NaNs
submatCS2_bsl = bslcorr(submatCS2', 6:8)'; 

submatCS3 =  movmean(squeeze(matrix_CS3_total(20, :, :)), smoothwindow,1, 'omitnan'); % smoothing
submatCS3 = fillmissing(submatCS3, "linear", 1); % interpolate NaNs
submatCS3_bsl = bslcorr(submatCS3', 6:8)'; 

% put into one 3-D array 
 data3D = cat(3, submatCSp_bsl, submatCS1_bsl, submatCS2_bsl, submatCS3_bsl); 
% data3D = cat(3, submatCSp, submatCS1, submatCS2, submatCS3); 

% plot the means
figure, plot(squeeze(mean(data3D, 2))), legend
xline(8), xline(32)

%% look at the effects in the data
% first make bootstraps of mexican hat
mexhat = [1 -2 -1 .5];
mexhatfit = []; 
for time = 1:44
    for bootstrapindex = 1:2000
        subjectindex = randi(23, 1, 23);
        mexhatfit(time, bootstrapindex) =  column(squeeze(mean(data3D(time, subjectindex, 1:4), 2)))' * mexhat';
    end
end

%% compare against nullmodel
mexhat = [1 -2 -1 .5];
mexhatfit_perm = []; 
data3Dperm = data3D;
BFmexhat = [];
for time = 1:44
    for bootstrapindex = 1:2000
        for subject = 1:23
        data3Dperm(time, subject, 1:4) = data3D(time, subject, randperm(4));
        end
        subjectindex = randi(23, 1, 23);
        mexhatfit_perm(time, bootstrapindex) =  column(squeeze(mean(data3Dperm(time, subjectindex, 1:4), 2)))' * mexhat';
    end
end

% BF
for x = 1:44; BFmexhat(x) = bootstrap2BF_z(mexhatfit(x,:),mexhatfit_perm(x,:), 1); end
figure, plot(BFmexhat)
%% compare this against a model with generalization
generalization = [2 1 .5 -.5];
generfit = []; 
for time = 1:44
    for bootstrapindex = 1:2000
        subjectindex = randi(23, 1, 23);
        generfit(time, bootstrapindex) =  column(squeeze(mean(data3D(time, subjectindex, 1:4), 2)))' * generalization';
    end
end
%% compare generalizationagainst nullmodel
generfit_perm = []; 
data3Dperm = data3D;
BFgeneralize = [];
for time = 1:44
    for bootstrapindex = 1:2000
        for subject = 1:23
        data3Dperm(time, subject, 1:4) = data3D(time, subject, randperm(4));
        end
        subjectindex = randi(23, 1, 23);
        generfit_perm(time, bootstrapindex) =  column(squeeze(mean(data3Dperm(time, subjectindex, 1:4), 2)))' * generalization';
    end
end

% BF
for x = 1:44; BFgeneralize(x) = bootstrap2BF_z(generfit(x,:),generfit_perm(x,:), 1); end
figure, plot(BFgeneralize)
