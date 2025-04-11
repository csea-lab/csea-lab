%% 
%% Load and Preprocess Data
clear; clc; rng(1);
cd '/Users/andreaskeil/Desktop/tempdata/'
a = readtable('Matthiasalldata.csv');

% Inputs: 45 variables (features)
inputData = table2array(a(:, [3:23 35:end-5]));

% Targets: 11 variables to predict
targetData = table2array(a(:, 24:34));

% Replace NaNs with column-wise mean
nanIdx = isnan(inputData);
colMean = mean(inputData, 'omitnan');
inputData(nanIdx) = colMean(ceil(find(nanIdx) / size(inputData, 1)));

% Normalize inputs
inputData_z = zscore(inputData); % z_norm was column-wise already
data_z = inputData_z;

% Transpose for deep learning format [features x observations]
X = dlarray(inputData_z', 'CB');
Y = dlarray(targetData', 'CB');

%% Define Network Architecture
inputSize = size(X,1);  % 45
latentSize = 4;
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

lgraph = layerGraph(layersEncoder);
lgraph = addLayers(lgraph, layersDecoder);
lgraph = addLayers(lgraph, layersPredictor);


% Custom dlnetwork
net = dlnetwork(lgraph);
encoderNet = dlnetwork(layersEncoder);
decoderNet = dlnetwork(layerGraph(layersDecoder));
predictorNet = dlnetwork(layerGraph(layersPredictor));

%% Training Settings
numEpochs = 800;
miniBatchSize = size(X,2);
lambda = 1;  % Weighting for prediction loss

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
colormap('jet');
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
b = a(:, [3:23 35:end-5]);
labels = b.Properties.VariableNames;

% Assume componentweights is a 5xN matrix
% labels is a 1xN cell array of variable names

figure;  % Open a new figure window
hold on; % Keep all plots on the same axes
grid on;

colors = lines(5);  % Generate 5 distinct colors

for compindex = 1:latentSize
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
 surveydata = table2array(a (:, 24:34)); % the surveys
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

 %% important: make a linear model predicting each questionnaire from the 5 compressed dimensions
% Assuming:
% Y is your target vector (214x1)
% X is your predictor matrix (214x5)
X = compressedData; 

for surveyindex = 1:11

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
       scatter3(compressedData(:,1), compressedData(:,2), compressedData(:,3), 40, Y, 'filled'); % Color by cluster index
       pause
end

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
end
