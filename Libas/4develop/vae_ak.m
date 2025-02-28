% Example matrix with size 219x40 (replace with your data)
cd '/Users/andreaskeil/Desktop'
a = readtable('All_data_rdcd.csv');
data = table2array(a(:,14:72));

% Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(data);
colMean = mean(data, 'omitnan');
data(nanIdx) = colMean(ceil(find(nanIdx) / size(data, 1)));

% Set the size of the compressed (hidden) layer
dimCompressed = 10; % You can adjust this depending on desired compression level

%% Create and train autoencoder
hiddenLayerSize = dimCompressed;
autoenc = trainAutoencoder(data', hiddenLayerSize, ...
    'MaxEpochs', 100, ...  % Number of training epochs
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'ScaleData', true); % Automatically scales input data

% Encode the data into compressed form
compressedData = encode(autoenc, data');


%% Transpose back to have 219x10 (if needed)
compressedData = compressedData';

% Visualize explained variance if needed
explainedVariance = var(compressedData) ./ sum(var(data));
figure;
bar(explainedVariance);
title('Explained Variance by Compressed Components');
xlabel('Component');
ylabel('Variance Explained');

% Decode back to original size if you want to check reconstruction
reconstructedData = predict(autoenc, data');
reconstructedData = reconstructedData';

% Compute reconstruction error
reconstructionError = mse(data, reconstructedData);
disp(['Reconstruction Error: ', num2str(reconstructionError)]);
