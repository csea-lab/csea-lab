%% data
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

% Define the size of the input data
inputSize = 30;    % Number of variables
latentDim = 2;     % Latent space dimension

% Load or generate your dataset (214 x 30)
X = randn(214, inputSize); % Replace this with your actual dataset

% Define the encoder network (mapping input to latent variables)
encoderLayers = [
    featureInputLayer(inputSize, 'Normalization', 'none', 'Name', 'input')
    fullyConnectedLayer(64, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(latentDim * 2, 'Name', 'fc2')  % output mean and log-variance
];

% Define the decoder network (mapping latent variables to reconstructed output)
decoderLayers = [
    featureInputLayer(latentDim, 'Normalization', 'none', 'Name', 'z')
    fullyConnectedLayer(64, 'Name', 'fc3')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(inputSize, 'Name', 'output')
    sigmoidLayer('Name', 'sigmoid')  % Output between 0 and 1
];

% Combine encoder and decoder into a single layer graph
layers = [
    encoderLayers
    decoderLayers
];

% Initialize parameters for the model
params = initializeParameters(inputSize, latentDim); % Pass inputSize and latentDim here

% Training options
epochs = 100;
learningRate = 0.001;
batchSize = 32;
 
% Custom training loop
for epoch = 1:epochs
    % Shuffle the data at each epoch
    idx = randperm(size(X, 1));
    X_shuffled = X(idx, :);
    
    for i = 1:batchSize:size(X, 1)
        % Select mini-batch
        batch = X_shuffled(i:min(i+batchSize-1, end), :);
        
        % Forward pass through encoder
        [mu, logVar] = forwardEncoder(batch, params.encoder, latentDim);
        
        % Sample latent variable z using the reparameterization trick
        epsilon = randn(size(mu));  % Random noise
        z = mu + exp(0.5 * logVar) .* epsilon;
        
        % Forward pass through decoder
        reconX = forwardDecoder(z, params.decoder);
        
        % Compute VAE loss (reconstruction loss + KL divergence loss)
        [reconstructionLoss, klLoss] = vaeLoss(batch, reconX, mu, logVar);
        totalLoss = reconstructionLoss + klLoss;
        
        % Compute gradients (gradient descent with backpropagation)
        gradients = computeGradients(params, batch, reconX, mu, logVar, z);
  
        % Update parameters using gradient descent
     
        params = updateParameters(params, gradients, learningRate);
    end
    
    % Print the loss for the current epoch
    disp(['Epoch: ', num2str(epoch), ' Loss: ', num2str(totalLoss)]);
end

% Define the VAE loss function (Reconstruction loss + KL divergence loss)
function [reconstructionLoss, klLoss] = vaeLoss(X, reconX, mu, logVar)
    % Reconstruction loss (mean squared error)
    reconstructionLoss = mean(sum((X - reconX).^2, 2));
    
    % KL divergence loss (regularizing the latent space)
    klLoss = -0.5 * sum(1 + logVar - mu.^2 - exp(logVar), 2);
end

% Forward pass through encoder
function [mu, logVar] = forwardEncoder(X, encoderParams, latentDim)
    fc1_out = max(0, X * encoderParams.fc1);  % Apply ReLU activation manually using max(0, X)
    output = fc1_out * encoderParams.fc2;
    mu = output(:, 1:latentDim);
    logVar = output(:, latentDim+1:end);
end

% Forward pass through decoder
function reconX = forwardDecoder(z, decoderParams)
    fc3_out = max(0, z * decoderParams.fc3);  % Apply ReLU activation manually using max(0, X)
    reconX = 1 ./ (1 + exp(-(fc3_out * decoderParams.fc4)));   % Apply Sigmoid activation at output layer
end

% Initialize parameters for the model
function params = initializeParameters(inputSize, latentDim)
    % Initialize encoder and decoder layers with random values
    params.encoder.fc1 = randn(inputSize, 64);  % Encoder weights for the first layer
    params.encoder.fc2 = randn(64, latentDim * 2);  % Encoder weights for the second layer (mean and log variance)
    
    params.decoder.fc3 = randn(latentDim, 64);  % Decoder weights for the first layer
    params.decoder.fc4 = randn(64, inputSize);  % Decoder weights for the second layer (output layer)
    % Verify the structure
    disp('Initialized Parameters:');
    disp(params);
end

% Compute gradients (a placeholder, you may need a library or manual implementation for backprop)
% Compute gradients using backpropagation
function gradients = computeGradients(params, X, reconX, mu, logVar, z)
    % Initialize gradients structure
    gradients = struct();

    % Compute gradients for the reconstruction loss (MSE)
 size(reconX), size(X)
    dRecon = 2 * (reconX - X);  % Derivative of reconstruction loss
    
    % Compute gradients for KL divergence loss
    dKL_mu = -mu .* exp(-0.5 * logVar) + exp(0.5 * logVar);
    dKL_logVar = 0.5 * (exp(logVar) - 1 - logVar);
    
    % Combine the gradients of the reconstruction loss and KL divergence
    dLoss = dRecon + dKL_mu + dKL_logVar;
    
    % Compute gradients for decoder parameters (fc3, fc4)
    % Backpropagate through the decoder (gradient w.r.t fc4)
    dDecoder_fc4 = z' * dLoss;  % Gradient for fc4 (decoder output layer)
    dDecoder_fc3 = dLoss * params.decoder.fc4' .* (z > 0);  % Gradient for fc3 (ReLU activation)
    
    % Store gradients for decoder
    gradients.decoder.fc3 = dDecoder_fc3;
    gradients.decoder.fc4 = dDecoder_fc4;
    
    % Backpropagate the gradients through the encoder
    dEncoder_fc2 = dLoss * params.decoder.fc4' * (z > 0);  % Gradient for fc2 (latent to hidden layer)
    dEncoder_fc1 = X' * dEncoder_fc2 .* (X > 0);  % Gradient for fc1 (hidden to input layer)
    
    % Store gradients for encoder
    gradients.encoder.fc1 = dEncoder_fc1;
    gradients.encoder.fc2 = dEncoder_fc2;
    
    % Return gradients structure
    return;
end


% Update parameters using gradient descent
function params = updateParameters(params, gradients, learningRate)
    params.encoder.fc1 = params.encoder.fc1 - learningRate * gradients.encoder.fc1;
    params.encoder.fc2 = params.encoder.fc2 - learningRate * gradients.encoder.fc2;
    params.decoder.fc3 = params.decoder.fc3 - learningRate * gradients.decoder.fc3;
    params.decoder.fc4 = params.decoder.fc4 - learningRate * gradients.decoder.fc4;
end
