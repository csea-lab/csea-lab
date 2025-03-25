%% 
clear
clc
rng(1)
cd '/Users/andreaskeil/Desktop/tempdata/'
% a = readtable('Matthiasalldata.csv');
a = readtable('Matthias_data_rdcd.csv'); 
% this is for Matthiasalldata
% data = table2array(a(:,35:end-6)); % just ESM
% data = table2array(a(:, 12:23 )); % just phys and ratings
% data = table2array(a(:,3:8)); % just ssVEP
% data = table2array(a (:, 3:end)); % all data

% this is for Matthias_data_rdcd
dataindexvec = 14:53;

% data = table2array(a (:, 14:27)); % all ratings
% data = table2array(a (:, 32:53)); % skin and EEG
% data = table2array(a (:, 36:53)); % only  EEG

% data = table2array(a (:, 14:53)); % combo that was interesting
data = table2array(a (:, dataindexvec));


% Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(data);
colMean = mean(data, 'omitnan');
data(nanIdx) = colMean(ceil(find(nanIdx) / size(data, 1)));

% do our own transform because built is row-wise which is wr
data_z = z_norm(data')'; 

% Set the size of the compressed (hidden) layer
dimCompressed = 5; % You can adjust this depending on desired compression level % was 3

% Create and train autoencoder
hiddenLayerSize = dimCompressed;
autoenc = trainAutoencoder(data_z', hiddenLayerSize, ...
    'MaxEpochs', 1200, ...  % Number of training epochs
    'EncoderTransferFunction','satlin',...
     'DecoderTransferFunction','purelin',...
    'L2WeightRegularization', 0.01, ...
    'SparsityRegularization', .1, ... % changing this greatly affects outcome :-) 
    'SparsityProportion', 0.01, ... % was 0.05 originally
    'ScaleData', false); % Automatically scales input data

% Encode the data into compressed form
compressedData = encode(autoenc, data_z');

% Transpose back to have 219x dimCompressed(if needed)
compressedData = compressedData';

% Visualize explained variance if needed
explainedVariance = var(compressedData) ./ sum(var(data_z));
figure;
bar(explainedVariance);
title('Explained Variance by Compressed Components');
xlabel('Component');
ylabel('Variance Explained');

% Decode back to original size if you want to check reconstruction
reconstructedData = predict(autoenc, data_z');
reconstructedData = reconstructedData';

% Compute reconstruction error
reconstructionError = mse(data_z, reconstructedData);
disp(['Reconstruction Error: ', num2str(reconstructionError)]);

%% standard visualization
 figure, 
 GoodnessOfFit = []; 
 for x = 1:size(data_z, 1)
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
     plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
     GoodnessOfFit(x) = corcoef; 
     pause (.1), 
     hold off, 
 end

%% tsne with clusters 
% Step 2: Cluster the latent features ONLY FOR Visualization!!!!!!
Y = tsne(compressedData, 'NumDimensions', 2, 'Perplexity', 30, 'Exaggeration', 12);

numClusters = 3; % You can adjust this depending on your data
rng(1)
[idx, C] = kmeans(compressedData, numClusters, 'Replicates', 10); % Cluster assignments

% Step 3: Plot t-SNE with clusters color-coded
figure;
scatter(Y(:,1), Y(:,2), 40, idx, 'filled'); % Color by cluster index
colormap('parula');
colorbar;
title('t-SNE Visualization with Clustered Groupings');
xlabel('t-SNE Dim 1');
ylabel('t-SNE Dim 2');
grid on;

%% now map the dimensional data onto the compressed data
% calculate latent score loadings on data:
figure
componentweights = compressedData' * data_z;
imagesc(componentweights), colorbar

%% alternate figure
b = a(:, dataindexvec);
labels = b.Properties.VariableNames;

% Assume componentweights is a 5xN matrix
% labels is a 1xN cell array of variable names

figure;  % Open a new figure window
hold on; % Keep all plots on the same axes
grid on;

colors = lines(5);  % Generate 5 distinct colors

for compindex = 1:5
    Y = componentweights(compindex, :);
    x = 1:length(Y);
    
    plot(x, Y, '-o', ...
        'Color', colors(compindex, :), ...
        'LineWidth', 2, ...
        'DisplayName', ['latent dimension:  ' num2str(compindex)]);  % For legend
end

% Set labels and ticks (only needs to be done once)
xlabel('Variables');
ylabel('inner product');

xticks(x);
xticklabels(labels);
xtickangle(45);

legend('show');  % Show the legend to label each line
hold off;
%% relate to surveys
 surveydata = table2array(a (:, 65:end)); % the surveys
 figure,

 % Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(surveydata);
colMean = mean(surveydata, 'omitnan');
surveydata(nanIdx) = colMean(ceil(find(nanIdx) / size(surveydata, 1)));

% simply correlate each latent dimension with the BDI 
 corrlatent5withBDI = corr(surveydata(:, end-3), compressedData);

 % simply correlate each latent dimension with the all surveys 
 for index_survey = 1:size(surveydata,2)
 corrlatent_temp= corr(surveydata(:, index_survey), compressedData);
 bar(corrlatent_temp), title(index_survey), pause
 end

 %% important: make linear models predicting each questionnaire from the 5 compressed dimensions
% Assuming:
% Y is your target vector (214x1)
% X is your predictor matrix (214x5)
X = compressedData; 

for surveyindex = 1:8

    Y = surveydata(:, surveyindex); % the surveys

    % Create a linear model using fitlm
    mdl = fitlm(X, Y);

    % Display model summary
    disp(mdl);

    % Predicted values
    Y_pred = predict(mdl, X);

    % Optional: R-squared
    R_squared = mdl.Rsquared.Ordinary;
    disp(['R-squared: ', num2str(R_squared)]);

    % scatter observed predicted
     scatter(Y, Y_pred, 60, GoodnessOfFit, "filled"); % Color by cluster index
    title(['R_squared:  ' num2str(R_squared)])
    pause

end
 

%% vector norm corrrelations
row_norms = vecnorm(compressedData, 2, 2); % questionable in terms of interpretation
close all

component = 2
figure
for index_survey = 1:size(surveydata,2)
    Y = surveydata(:, index_survey); % the surveys

    %scatter(row_norms, Y); % Color by cluster index
    %tempcorr = corr(Y, row_norms, "Type","Spearman");
   
    scatter(compressedData(:,component), Y, 60, GoodnessOfFit, "filled"); % Color by cluster index
     tempcorr = corr(Y, compressedData(:,component), "Type","Spearman");

    title(num2str(tempcorr))
   
   lsline

pause
end

%% questionable but maybe helpful from figure below, select components of interest and form embedding
% calculate latent score  on data:
figure
componentweights = compressedData' * data_z;
imagesc(componentweights), colorbar; 
%
figure

for index_survey = 1:size(surveydata,2)
     Y = surveydata(:, index_survey); % the surveys
       scatter(compressedData(:,1), compressedData(:,2), 40, Y, 'filled'); % Color by cluster index
       scatter3(compressedData(:,1), compressedData(:,2), compressedData(:,5), 40, Y, 'filled'); % Color by cluster index
       pause
end

