function [outmat] = supervisedautoenc_LooCV(datafile, Xcols, Ycols, lambda, latentSize)

% inputs: 
% datafile = a cvs file with data
% Xcols = column indices of the psychophys or similar data to be reconstructed (Nvars by N matrix) 
% Ycols = column indices of the to be predicted variables (surveys) 
% lambda = loss function trade-off (how much of the loss is weighted
% towards predictors) 
% all X should be z transformed, Y probably too

parpool('local', 8);

a = readtable(datafile); 

% Inputs:  variables (features)
inputData = table2array(a(:, Xcols));

% Targets: 11 variables to predict
targetData = table2array(a(:, Ycols));

% Replace NaNs with column-wise mean
nanIdx = isnan(inputData);
colMean = mean(inputData, 'omitnan');
inputData(nanIdx) = colMean(ceil(find(nanIdx) / size(inputData, 1)));

nanIdx2 = isnan(targetData);
colMean2 = mean(targetData, 'omitnan');
targetData(nanIdx2) = colMean2(ceil(find(nanIdx2) / size(targetData, 1)));

% Normalize inputs
inputData_z = zscore(inputData); % z_norm was column-wise already
targetData_z = zscore(targetData); % z_norm was column-wise already


% Transpose for deep learning format [features x observations]
X = dlarray(inputData_z', 'CB');
Y = dlarray(targetData_z', 'CB');


%%
% first, compute the overall solution and create the networks
numSamples = size(X,2);
Y_actual_all = zeros(size(Y));
Y_predicted_all = zeros(size(Y));
X_reconstructed_all = zeros(size(X));

%% Define Network Architecture
inputSize = size(X,1);  % 44 in the example
outputSize = size(Y,1); % 11 in the example

% Layers
layersEncoder = [
    featureInputLayer(inputSize, 'Name', 'input')
    fullyConnectedLayer(32, 'Name', 'enc_fc1')
    customSatLin('sat1')  % satlin
    fullyConnectedLayer(latentSize, 'Name', 'latent')
];

layersDecoder = [
    featureInputLayer(latentSize, 'Name', 'decoder_input')   % 
    fullyConnectedLayer(32, 'Name', 'dec_fc1')
    reluLayer('Name', 'dec_relu')
    fullyConnectedLayer(inputSize, 'Name', 'reconstructed')
    customPureLin('recon_out')  % purelin
];

layersPredictor = [
    featureInputLayer(latentSize, 'Name', 'predictor_input')  % 
    fullyConnectedLayer(32, 'Name', 'pred_fc1')
    reluLayer('Name', 'pred_relu')
    fullyConnectedLayer(outputSize, 'Name', 'predicted')
];

lgraph = layerGraph(layersEncoder);
lgraph = addLayers(lgraph, layersDecoder);
lgraph = addLayers(lgraph, layersPredictor);

% Custom dlnetwork
net = dlnetwork(lgraph);
encoderNet = dlnetwork(layersEncoder);
decoderNet = dlnetwork(layerGraph(layersDecoder));
predictorNet = dlnetwork(layerGraph(layersPredictor));

%% Training Settings
numEpochs = 1200;
miniBatchSize = size(X,2);

learningRate = 1e-3;
gradDecay = 0.9;
sqGradDecay = 0.999;
trailingAvg = [];
trailingAvgSq = [];

%% Training Loop
lossHistory = zeros(numEpochs, 1);

for epoch = 1:numEpochs
    [loss, gradientsEnc, gradientsDec, gradientsPred] = ...
        dlfeval(@modelLoss, encoderNet, decoderNet, predictorNet, X, Y, lambda);

    % Update each network separately
    [encoderNet, trailingAvgE, trailingAvgSqE] = adamupdate(encoderNet, gradientsEnc, ...
        trailingAvg, trailingAvgSq, epoch, learningRate, gradDecay, sqGradDecay);
    
    [decoderNet, trailingAvgD, trailingAvgSqD] = adamupdate(decoderNet, gradientsDec, ...
        trailingAvg, trailingAvgSq, epoch, learningRate, gradDecay, sqGradDecay);

    [predictorNet, trailingAvgP, trailingAvgSqP] = adamupdate(predictorNet, gradientsPred, ...
        trailingAvg, trailingAvgSq, epoch, learningRate, gradDecay, sqGradDecay);

    lossHistory(epoch) = extractdata(loss);
    if mod(epoch,50)==0 || epoch==1
        fprintf('Epoch %d, Loss = %.4f\n', epoch, lossHistory(epoch));
    end
end
%% Evaluate: Reconstruction & Prediction
encoded = predict(encoderNet, X);
compressedData = extractdata(encoded)';         % [samples x latent dims]

reconstructed = predict(decoderNet, encoded);
reconstructedData = extractdata(reconstructed)'; % [samples x original dims]

predicted = predict(predictorNet, encoded);

% Reconstruction and Prediction errors
reconError = mse(reconstructed, X);
predError = mse(predicted, Y);

fprintf('\nFinal Reconstruction Error: %.4f\n', reconError);
fprintf('Final Prediction Error: %.4f\n', predError);

%% part 2
% now: the cross-validation
% new sizes and networks: 

% Define Network Architecture
inputSize = size(X,1);  % 44
outputSize = size(Y,1); % 11

% Layers
layersEncoder = [
    featureInputLayer(inputSize, 'Name', 'input')
    fullyConnectedLayer(32, 'Name', 'enc_fc1')
    customSatLin('sat1')  % satlin
    fullyConnectedLayer(latentSize, 'Name', 'latent')
];

layersDecoder = [
    featureInputLayer(latentSize, 'Name', 'decoder_input')   % 
    fullyConnectedLayer(32, 'Name', 'dec_fc1')
    reluLayer('Name', 'dec_relu')
    fullyConnectedLayer(inputSize, 'Name', 'reconstructed')
    customPureLin('recon_out')  % purelin
];

layersPredictor = [
    featureInputLayer(latentSize, 'Name', 'predictor_input')  % 
    fullyConnectedLayer(32, 'Name', 'pred_fc1')
    reluLayer('Name', 'pred_relu')
    fullyConnectedLayer(outputSize, 'Name', 'predicted')
];

%% leave-one out-loop
parfor i = 1:numSamples

    % Split data
    X_test = X(:,i);
    Y_test = Y(:,i);

    X_train = X(:, [1:i-1, i+1:end]);
    Y_train = Y(:, [1:i-1, i+1:end]);

    % Reinitialize networks from scratch each time
    encoderNet_cv = dlnetwork(layerGraph(layersEncoder));
    decoderNet_cv = dlnetwork(layerGraph(layersDecoder));
    predictorNet_cv = dlnetwork(layerGraph(layersPredictor));

    % Reset training hyperparams
    trailingAvgE = []; trailingAvgSqE = [];
    trailingAvgD = []; trailingAvgSqD = [];
    trailingAvgP = []; trailingAvgSqP = [];

    for epoch = 1:1000  % Fewer epochs for speed
        [loss, gradientsEnc, gradientsDec, gradientsPred] = ...
            dlfeval(@modelLoss, encoderNet_cv, decoderNet_cv, predictorNet_cv, X_train, Y_train, lambda);

         [encoderNet_cv, trailingAvgE, trailingAvgSqE] = adamupdate(encoderNet_cv, gradientsEnc, ...
        trailingAvgE, trailingAvgSqE, epoch, learningRate, gradDecay, sqGradDecay);
        
        [decoderNet_cv, trailingAvgD, trailingAvgSqD] = adamupdate(decoderNet_cv, gradientsDec, ...
        trailingAvgD, trailingAvgSqD, epoch, learningRate, gradDecay, sqGradDecay);
        
        [predictorNet_cv, trailingAvgP, trailingAvgSqP] = adamupdate(predictorNet_cv, gradientsPred, ...
        trailingAvgP, trailingAvgSqP, epoch, learningRate, gradDecay, sqGradDecay);

    end

    % Evaluate on held-out sample
    encoded_test = predict(encoderNet_cv, X_test);
    y_pred = predict(predictorNet_cv, encoded_test);
    x_recon = predict(decoderNet_cv, encoded_test);

    Y_predicted_all(:, i) = extractdata(y_pred);
    Y_actual_all(:, i) = extractdata(Y_test);
    X_reconstructed_all(:, i) = extractdata(x_recon);

    if i/10 ==round(i/10), disp(['observation #: ' num2str(i)]), end

end

delete(gcp('nocreate'))

% collect the output
outmat.Y_predicted_all = Y_predicted_all; 
outmat.Y_actual_all = Y_actual_all; 
outmat.X_reconstructed_all = X_reconstructed_all; 
outmat.compressedData = compressedData;

% output overall LOOCV accuracy
predError_LOO_Y = mean((outmat.Y_predicted_all - outmat.Y_actual_all).^2, 1);  % MSE per subject
figure; histogram(predError_LOO_Y); title('Prediction Error (LOOCV)');

outmat.predError_LOO_Y = predError_LOO_Y; 

predError_LOO_X = mean((outmat.X_reconstructed_all - extractdata(X)).^2, 1);  % MSE per subject
figure; histogram(predError_LOO_X); title('Prediction Error (LOOCV)');

outmat.predError_LOO_X = predError_LOO_X; 

%% figures;
% 1- cross-validation accuracy
numOutputs = size(Y_actual_all, 1);
for j = 1:numOutputs
    subplot(ceil(numOutputs/4), 4, j);
    scatter(Y_actual_all(j, :), Y_predicted_all(j, :), 'filled');
    xlabel('Actual Y'); ylabel('Predicted Y');
    title(sprintf('Y Var %d, r = %.2f', j, corr(Y_actual_all(j,:)', Y_predicted_all(j,:)')));
    axis equal; grid on;
end
sgtitle('Cross-Validated Prediction: Actual vs Predicted Y');

% 2- individual reconstruction of left out participant
 figure, 
 GoodnessOfFit = []; 
 for x = 1:size(X,2)
     corcoef = corr(extractdata(X(:,x)), outmat.X_reconstructed_all(:,x)); 
         plot(extractdata(X(:,x))), hold on, plot(outmat.X_reconstructed_all(:,x)), title(num2str(corcoef))
     GoodnessOfFit(x) = corcoef; 
     pause (.1), 
     hold off, 
 end

 outmat.GoodnessOfFit = GoodnessOfFit; 
 
 %  3- individual prediction of left out participants

surveys = extractdata(Y)'; 

for surveyindex = 1:size(surveys,2)
    
    % Create a linear model using fitlm
    mdl = fitlm(compressedData, surveys(:, surveyindex));

    % Display model summary
    disp(mdl);

    % Predicted values
    Y_pred = predict(mdl, compressedData);

    % Optional: R-squared
    R_squared = mdl.Rsquared.Ordinary;
    disp(['R-squared: ', num2str(R_squared)]);

    % scatter observed predicted
    scatter(surveys(:, surveyindex), Y_pred, 60, GoodnessOfFit, "filled"); % 
    title(['R_squared:  ' num2str(R_squared)])
    pause

end

%% LOSS function
function [loss, gradEnc, gradDec, gradPred] = modelLoss(encNet, decNet, predNet, X, Y, lambda)
    % Forward through encoder
    Z = forward(encNet, X);

    % Forward through decoder and predictor
    Xhat = forward(decNet, Z);
    Yhat = forward(predNet, Z);

    % Compute losses
    reconLoss = mse(Xhat, X);
    predLoss = mse(Yhat, Y);
    loss = reconLoss + lambda * predLoss;

    % Compute gradients
    gradEnc = dlgradient(loss, encNet.Learnables, 'RetainData', true);
    gradDec = dlgradient(loss, decNet.Learnables, 'RetainData', true);
    gradPred = dlgradient(loss, predNet.Learnables);

