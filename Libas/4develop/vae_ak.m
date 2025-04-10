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
%% tsne plot
% Step 1: Get the latent features
latentFeatures = encode(autoenc, data_z')'; % (N x 5) latent space

% Step 2: Apply t-SNE to reduce to 2D
Y = tsne(latentFeatures, 'NumDimensions', 2, 'Perplexity', 30, 'Exaggeration', 12);

% Step 3: Plot t-SNE with color coding for each latent dimension
figure;
tiledlayout(2,3); % 2x3 grid for subplots (5 dimensions + title)

for dim = 1:5
    nexttile;
    scatter(Y(:,1), Y(:,2), 20, latentFeatures(:,dim), 'filled');
    colormap('jet'); % Choose a colormap (e.g., 'jet', 'parula', 'hot')
    colorbar;
    title(['Latent Dimension ', num2str(dim)]);
    xlabel('t-SNE Dim 1');
    ylabel('t-SNE Dim 2');
    grid on;
end

% Add a super title
sgtitle('t-SNE Visualization with Color Coded Latent Dimensions');

%% alternate way
% Step 2: Cluster the latent features
numClusters = 4; % You can adjust this depending on your data
[idx, C] = kmeans(latentFeatures, numClusters, 'Replicates', 10); % Cluster assignments

% Step 3: Plot t-SNE with clusters color-coded
figure;
scatter(Y(:,1), Y(:,2), 40, idx, 'filled'); % Color by cluster index
colormap('parula');
colorbar;
title('t-SNE Visualization with Clustered Groupings');
xlabel('t-SNE Dim 1');
ylabel('t-SNE Dim 2');
grid on;

%% for ESM
 figure, 
 for x = 1:198
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
   %  plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
    % pause, 
     %hold off, 
     fitESM35to56(x) = corcoef;
 end
fitESM35to56 = column(fitESM35to56);
% scatter against the surveys
figure
for surveyindex = 24:34
scatter(fitESM35to56, table2array(a(:,surveyindex )), 'k',  'filled'), pause
end
%% ssvep
figure, 
 for x = 1:198
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
     plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
     pause, 
     hold off, 
     fitssVEP(x) = corcoef;
 end
fitssVEP = column(fitssVEP);
% scatter against the surveys
figure
for surveyindex = 24:34
scatter(fitssVEP, table2array(a(:,surveyindex )), 'k',  'filled'), pause
end
%% phys and ratings
 figure, 
 for x = 1:198
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
     plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
     pause, 
     hold off, 
     fitPhysRat(x) = corcoef;
 end
fitPhysRat = column(fitPhysRat);
% scatter against the surveys
figure
for surveyindex = 24:34
scatter(fitPhysRat, table2array(a(:,surveyindex )), 'k',  'filled'), pause
end
%% everything
 figure, 
 for x = 1:198
     corcoef = corr(data_z(x,:)', reconstructedData(x,:)'); 
     plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), title(num2str(corcoef))
     pause, 
     hold off, 
     fiteverything(x) = corcoef;
 end
fiteverything = column(fiteverything);
% scatter against the surveys
figure
for surveyindex = 24:34
scatter(fiteverything, table2array(a(:,surveyindex )), 'k',  'filled'), pause
end