%%% KALMAN FILTER SCRIPT %%%
% Written based on formulas in Gershman (2015, PLoS Computational Biology)

%% CS and US intensities across trials
% CS: 1 row per CS, 1 column per trial
%csVec = [1 1 1 1 1 0 0 0 0 0; ...
%         1 1 1 1 1 1 1 1 1 1];
% csVec = [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0; ...
%          0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];
% US: 1 column per trial
%outcomeVec = [1 1 1 1 1 1 1 1 1 1];
% outcomeVec = [1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0];
%outcomeVec = [1 0 0 0 1 0 0 0 1 0 1 0 0 0 0 0 1 0 0 0];

csVec = [repmat([0,0,1,1], 1, 100);
         repmat([0,1,0,1], 1, 100)];
csVec = csVec(:,randperm(size(csVec,2)));

% both have to be there
%outcomeVec = floor(sum(csVec,1)/2);

% at least one
outcomeVec = ceil(sum(csVec,1)/2);

% additive
%outcomeVec = sum(csVec,1)/2;

% Creates random CS intensities; US is 0 or 1 and depends on CS intensities (additively)
%  csVec = [(randi(11,[1,20]) - 1) / 10; ...
%           (randi(11,[1,20]) - 1) / 10; ...
%           (randi(11,[1,20]) - 1) / 10];
% 
%  outcomeVec = round(mean(csVec,1));

%% fixed model parameters, as used in Gershman (2015)
% tau-square: variance diffusion parameter; higher values mean faster uncertainty "recovery"/faster "forgetting"
% and lead thereby to higher learning rates; adaptive in more volatile environments
tauSq = .01;
% variance or "noisiness" of (I THINK) stimulus activation/outcome expectations;
% needed for computing Kalman gain (sigma-square[r]); higher values lead to relatively lower gains
% see Gershman Formulas (5) and (11)
varR = 0.20;
% start variances in covariance matrix (aka sigma-square[w], uncertainty associated with single CS)
varW = 1; 

%% initializing variables
nrCS = size(csVec,1);
nrTrials = size(csVec,2);

% w = associative strength
w = NaN(nrCS,nrTrials+1);
% covMat = variances and covariances of CS
covMat = NaN(nrCS,nrCS,nrTrials+1);

% initial associative strengths set to 0
w(:,1) = zeros(nrCS,1);
% initial variances set to 1, covariances set to 0
covMat(:,:,1) = varW * eye(nrCS);

% empty matrices for...
% Kalman gains (each CS has their own)
kGain = NaN(nrCS,nrTrials);
% outcome expectation (combined for all present CS)
v = NaN(nrTrials+1,1);
% prediction error
delta = NaN(nrTrials,1);

%%

for i = 1:nrTrials
    % compute Kalman gains (Gershman: Formula (11))
    kGain(:,i) = ((covMat(:,:,i) + tauSq*eye(nrCS)) * csVec(:,i)) / ...
                 (csVec(:,i)' * (covMat(:,:,i) + tauSq*eye(nrCS)) * csVec(:,i) + varR);

    % update covariance matrix (Gershman: Formula (10))
    covMat(:,:,i+1) = covMat(:,:,i) + tauSq*eye(nrCS) - kGain(:,i) * csVec(:,i)' * (covMat(:,:,i) + tauSq*eye(nrCS));

    % compute outcome expectation (Gershman: Formula (2))
    v(i) = w(:,i)' * csVec(:,i);

    % compute delta (Gershman: Page 3, text after Formula (2))
    delta(i) = outcomeVec(i) - v(i);

    % update associative strength (Gershman: Formula (9))
    w(:,i+1) = w(:,i) + kGain(:,i) * delta(i);
end


%% plot parameters across trials

% Legend entries
legendCS = cell(nrCS,1);
for i = 1:nrCS
    legendCS{i} = ['CS' int2str(i)];
end
legendUS = legendCS;
legendUS{end+1} = 'US';

rowInd = [];
colInd = [];
for i = 1:(nrCS-1)
    rowInd = [rowInd, repmat(i,1,nrCS-i)];
    colInd = [colInd, (i+1):nrCS];
end

legendCov = cell(length(rowInd),1);
for i = 1:length(rowInd)
    legendCov{i} = ['CS' int2str(rowInd(i)) '.CS' int2str(colInd(i))];
end


% actual plotting
figure;

subplot(2,3,1);
title('CS & US intensities');
hold on;
for i = 1:nrCS
    plot(csVec(i,:));
end
plot(outcomeVec, '*')
hold off;
xlabel('in trial i')
legend(legendUS);

subplot(2,3,4);
title('associative strength (w)');
hold on;
for i = 1:nrCS
    plot(w(i,:));
end
hold off;
xlabel('at start of trial i')
legend(legendCS);

subplot(2,3,2);
title('Kalman gain');
hold on;
for i = 1:nrCS
    plot(kGain(i,:));
end
hold off;
xlabel('after outcome i')
legend(legendCS);

subplot(2,3,5);
plot(delta);
title('prediction error (delta)');
xlabel('after outcome i')

subplot(2,3,3);
title('uncertainty (variance)');
hold on;
for i = 1:nrCS
    plot(squeeze(covMat(i,i,:)));
end
hold off;
xlabel('at start of trial i')
legend(legendCS);

subplot(2,3,6);
title('Covariances');
hold on;
for i = 1:length(rowInd)
    plot(squeeze(covMat(rowInd(i),colInd(i),:))');
end
hold off;
xlabel('at start of trial i')
legend(legendCov);