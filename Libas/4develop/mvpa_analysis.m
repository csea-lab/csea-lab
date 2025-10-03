%% mvpa function to extract accuracy space, time, GAL,and GAT
function [accuracyspace, accuracytime, accuracyRandspace, accuracyRandtime, accuracyGAL, accuracyGAT] = mvpa_analysis(con1, con2, timepoints, sensors, perm)

minsize = min(size(con1, 3), size(con2, 3));
dat = cat(3, con1(:,:,1:minsize), con2(:,:,1:minsize));
labels = cat(1, zeros(minsize,1), ones(minsize,1));

% Initialize variables
accuracytime = zeros(timepoints,perm);
accuracyRandtime = zeros(timepoints,perm);
accuracyspace = zeros(sensors,perm);
accuracyRandspace = zeros(sensors,perm);
accuracyGAT = zeros(timepoints,timepoints,perm);
accuracyGAL = zeros(sensors,sensors,perm);


%%
for p = 1:perm
    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for time = 1:timepoints
        model = fitcdiscr(squeeze(datTrain(:,time,:))', labTrain);
        y_hat = model.predict(squeeze(datTest(:,time,:))');
        confusionMat = confusionmat(labTest, y_hat);
        accuracytime(time,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
    end
end

for p = 1:perm

    labels = labels(randperm(length(labels)));

    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for time = 1:timepoints
        model = fitcdiscr(squeeze(datTrain(:,time,:))', labTrain);
        y_hat = model.predict(squeeze(datTest(:,time,:))');
        confusionMat = confusionmat(labTest, y_hat);
        accuracyRandtime(time,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
    end
end

%% %%% Space-resolved approach MVP (using time as features)

for p = 1:perm
    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for ch = 1:sensors
        model = fitcdiscr(squeeze(datTrain(ch,:,:))', labTrain);
        y_hat = model.predict(squeeze(datTest(ch,:,:))');
        confusionMat = confusionmat(labTest, y_hat);
        accuracyspace(ch,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
    end
end

for p = 1:perm

    labels = labels(randperm(length(labels)));

    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for ch = 1:128
        model = fitcdiscr(squeeze(datTrain(ch,:,:))', labTrain);
        y_hat = model.predict(squeeze(datTest(ch,:,:))');
        confusionMat = confusionmat(labTest, y_hat);
        accuracyRandspace(ch,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
    end
end

%%

for p = 1:perm

    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for time1 = 1:timepoints
        time1
        model = fitcdiscr(squeeze(datTrain(:,time1,:))', labTrain);

        for time2 = 1:timepoints
            y_hat = model.predict(squeeze(datTest(:,time2,:))');
            confusionMat = confusionmat(labTest, y_hat);
            accuracyGAT(time1,time2,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
        end
    end
end

%% %%% Cross-decoding in space (Generalization across location)

for p = 1:perm
    % First permutate to have random indices
    totalLength = length(labels);
    permutation = randperm(totalLength);
    datPerm = dat(:,:,permutation);
    labelsPerm = labels(permutation);

    % Second, we split in 80% training and 20% test
    datTrain = datPerm(:,:,1 : floor(totalLength * 0.8) );
    labTrain = labelsPerm(1 : floor(totalLength * 0.8) );
    datTest = datPerm(:,:,floor(totalLength * 0.8) +1 :end );
    labTest = labelsPerm(floor(totalLength * 0.8) +1 :end );

    % Third, we train the model
    for ch1 = 1:sensors
        ch1
        model = fitcdiscr(squeeze(datTrain(ch1,:,:))', labTrain);

        parfor ch2 = 1:sensors
            y_hat = model.predict(squeeze(datTest(ch2,:,:))');
            confusionMat = confusionmat(labTest, y_hat);
            accuracyGAL(ch1,ch2,p) = sum(diag(confusionMat)) ./ sum(sum(confusionMat));
        end
    end
end
end

