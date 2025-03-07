%% 
cd '/Users/andreaskeil/Desktop/tempdata/'
% a = readtable('Matthiasalldata.csv');
a = readtable('Matthias_data_rdcd.csv'); 
% this is for Matthiasalldata
% data = table2array(a(:,35:end-6)); % just ESM
% data = table2array(a(:, 12:23 )); % just phys and ratings
% data = table2array(a(:,3:8)); % just ssVEP
% data = table2array(a (:, 3:end)); % all data

% this is for Matthias_data_rdcd
%data = table2array(a (:, 14:27)); % all ratings
 data = table2array(a (:, 32:53)); % all EEG
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
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', .5, ... % changing this greatly affects outcome :-) 
    'SparsityProportion', 0.05, ... % was 0.05 originally
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
 for x = 1:size(data_z, 1)
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
     plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
     pause, 
     hold off, 
 end

%% tsne with clusters 
% Step 2: Cluster the latent features
Y = tsne(compressedData, 'NumDimensions', 2, 'Perplexity', 30, 'Exaggeration', 12);

numClusters = 4; % You can adjust this depending on your data
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

%% relate to BDI
 surveydata = table2array(a (:, end-7:end)); % the surveys
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

%% use clusters for examining surveys
% simply correlate each latent dimension with the all surveys 
figure
groupindexvec = unique(idx);
 for index_survey = 1:size(surveydata,2)
     for x = 1:length(groupindexvec)
      meanvec(x)= mean(surveydata(idx==groupindexvec(x), index_survey));
     end
 bar(meanvec), title(index_survey), pause
 end
