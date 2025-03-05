% data
clear
cd '/Users/andreaskeil/Desktop'
a = readtable('All_data_rdcd.csv');
data = table2array(a(:,32:53));

% Replace NaNs with column-wise mean to handle missing values
nanIdx = isnan(data);
colMean = mean(data, 'omitnan');
data(nanIdx) = colMean(ceil(find(nanIdx) / size(data, 1)));

% do our own transform because built-in is row-wise which is wrong
data_z = z_norm(data')'; 
% Generate synthetic data (replace this with your actual data matrix)
X = rand(219, 40);  % Replace this with your actual dataset

% Define the autoencoder architecture
hiddenSize = 10;  % Number of neurons in the hidden layer (compressed dimension)

% Create and train the autoencoder
autoenc = trainAutoencoder(X', hiddenSize, ...
    'MaxEpochs', 100, ...            % Number of training epochs
    'L2WeightRegularization', 0.0001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'UseGPU', false);                % Set to true if you want to use GPU acceleration

% Get the encoder weights and bias
encodedData = encode(autoenc, X');  % Encoded representation of the data

% To get the compressed data
compressedData = encodedData';  % Transpose back to 219xN (where N is the compressed dimension)

% Display the size of the compressed data
disp(size(compressedData));
