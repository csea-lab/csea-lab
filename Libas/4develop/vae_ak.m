% Example matrix with size 219x40 (replace with your data)
cd '/Users/andreaskeil/Desktop'
a = readtable('All_data_rdcd.csv');
% data = table2array(a(:,14:72));
data = table2array(a(:,32:53));

% Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(data);
colMean = mean(data, 'omitnan');
data(nanIdx) = colMean(ceil(find(nanIdx) / size(data, 1)));

% do our own transform because built is row-wise which is wr
data_z = z_norm(data')'; 

% Set the size of the compressed (hidden) layer
dimCompressed = 3; % You can adjust this depending on desired compression level

%% Create and train autoencoder
hiddenLayerSize = dimCompressed;
autoenc = trainAutoencoder(data_z', hiddenLayerSize, ...
    'MaxEpochs', 1200, ...  % Number of training epochs
    'EncoderTransferFunction','satlin',...
     'DecoderTransferFunction','purelin',...
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'ScaleData', false); % Automatically scales input data

% Encode the data into compressed form
compressedData = encode(autoenc, data_z');


%% Transpose back to have 219x10 (if needed)
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

%%
figure, for x = 1:214, plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), pause, hold off, end
