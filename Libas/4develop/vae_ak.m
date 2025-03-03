% data
cd '/Users/andreaskeil/Desktop'
a = readtable('All_data_rdcd.csv');
data = table2array(a(:,32:53));

% Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(data);
colMean = mean(data, 'omitnan');
data(nanIdx) = colMean(ceil(find(nanIdx) / size(data, 1)));

% do our own transform because built-in is row-wise which is wrong
data_z = z_norm(data')'; 

% Set the size of the compressed (hidden) layer
dimCompressed = 10; % You can adjust this depending on desired compression level

% Create layers for Variational Autoencoder
inputSize = size(data, 2);
layers = [ 
    featureInputLayer(inputSize, 'Name', 'input')
    fullyConnectedLayer(20, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(2 * dimCompressed, 'Name', 'fc2')
    SamplingLayer('sampling') % Custom sampling layer (create SamplingLayer.m file separately)
    fullyConnectedLayer(dimCompressed, 'Name', 'latent') % Bottleneck layer
    fullyConnectedLayer(20, 'Name', 'fc3')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(inputSize, 'Name', 'fc4')
    regressionLayer('Name', 'output')
];


% Specify training options
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 16, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train VAE
vae = trainNetwork(data_z, data_z, layers, options);

% Encode the data into compressed form
compressedData = predict(vae, data_z);

% Visualize explained variance if needed
explainedVariance = var(compressedData) ./ sum(var(data));
figure;
bar(explainedVariance);
title('Explained Variance by Compressed Components');
xlabel('Component');
ylabel('Variance Explained');

% Decode back to original size if you want to check reconstruction
reconstructedData = predict(vae, data_z);

% Compute reconstruction error
reconstructionError = mse(data_z, reconstructedData);
disp(['Reconstruction Error: ', num2str(reconstructionError)]);

% NOTE: Create a separate file SamplingLayer.m with the custom layer class definition.


%%
figure, for x = 1:214, plot(data_z(x,:)), hold on, plot(reconstructedData(x,:)), pause, hold off, end
