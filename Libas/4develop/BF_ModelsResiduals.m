
cd '/home/laura/Documents/Gaborgen24/raw eeg files/app/new_app_CSD'
                                                                                
conditions = [11:14 20 22 23 24 31:34]; % This code separate each condition in different filemat objects
for x = 1:12 % 12 conditions
    
    string = ['*.app' num2str(conditions(x)) '.csdamp.at'];

    eval(['filemat' num2str(conditions(x)) ' = getfilesindir(pwd, string)'])
    
end

%% For acquisition (sensor 75)

% Baysian analysis agains models (Ricker and Gaussian) residuals and a null model

options.MaxIter = 100000;
% step 2: make new grand means as described above
for draw = 1:1000
    
    selectionvec = randi(31,1, 31);
    
    temp20 = filemat20(selectionvec,:);
    temp22 = filemat22(selectionvec,:);
    temp23 = filemat23(selectionvec,:);
    temp24 = filemat24(selectionvec,:);
    
    CSp = avgavgfiles(temp20);
    GS1 = avgavgfiles(temp22);
    GS2 = avgavgfiles(temp23);
    GS3 = avgavgfiles(temp24);
    
    data4fit = [ CSp(75, 1) GS1(75, 1) GS2(75, 1) GS3(75, 1)];
    data4fit_scl = rangecorrect(data4fit);

    
    [betaacq(draw), ~, ~, ~, mseacq(draw)] = nlinfit(0.25:0.25:1,data4fit_scl',@Ricker, .1, options); 
    fit_acq(draw,:) = Ricker(0.25:0.25:1, betaacq(draw)); 
    residualsRicker_acq(draw) = mean(fit_acq(draw,:)-data4fit_scl.^2);
    residualsNull_acq(draw) = mean(data4fit_scl.^2);

    [betaacqG(draw), ~, ~, ~, mseacqG(draw)] = nlinfit(0.25:0.25:1,data4fit_scl,@Gaussian, .1, options); 
    fit_acqG(draw,:) = Gaussian(betaacqG(draw), 0.25:0.25:1); 
    residualsGaussian_acq(draw) = mean(fit_acqG(draw,:)-data4fit_scl.^2);

    if draw/10 == round(draw/10), fprintf('--------'), end

end

% For the Ricker model

posteriorsigned_acq = length(find(residualsNull_acq(1,:) > residualsRicker_acq(1,:)))./length(residualsRicker_acq(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_acq = posteriorsigned_acq./(1-posteriorsigned_acq); % converts likelihoods to odds   
Bayesmat_acq = posteriorOdds_acq./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

% For the Gaussian model

posteriorsigned_acqG = length(find(residualsNull_acq(1,:) > residualsGaussian_acq(1,:)))./length(residualsGaussian_acq(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_acqG = posteriorsigned_acqG./(1-posteriorsigned_acqG); % converts likelihoods to odds   
Bayesmat_acqG = posteriorOdds_acqG./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

%% For extinction (sensor 75)

% Baysian analysis agains models (Ricker and Gaussian) residuals and a null model

options.MaxIter = 100000;
% step 2: make new grand means as described above
for draw = 1:1000
    
    selectionvec = randi(31,1, 31);
    
    temp31 = filemat31(selectionvec,:);
    temp32 = filemat32(selectionvec,:);
    temp33 = filemat33(selectionvec,:);
    temp34 = filemat34(selectionvec,:);
    
    CSp = avgavgfiles(temp31);
    GS1 = avgavgfiles(temp32);
    GS2 = avgavgfiles(temp33);
    GS3 = avgavgfiles(temp34);
    
    data4fit = [ CSp(75, 1) GS1(75, 1) GS2(75, 1) GS3(75, 1)];
    data4fit_scl = rangecorrect(data4fit);

    
    [betaext(draw), ~, ~, ~, mseext(draw)] = nlinfit(0.25:0.25:1,data4fit_scl',@Ricker, .1, options); 
    fit_ext(draw,:) = Ricker(0.25:0.25:1, betaext(draw)); 
    residualsRicker_ext(draw) = mean(fit_ext(draw,:)-data4fit_scl.^2);
    residualsNull_ext(draw) = mean(data4fit_scl.^2);

    [betaextG(draw), ~, ~, ~, mseextG(draw)] = nlinfit(0.25:0.25:1,data4fit_scl,@Gaussian, .1, options); 
    fit_extG(draw,:) = Gaussian(betaextG(draw), 0.25:0.25:1); 
    residualsGaussian_ext(draw) = mean(fit_extG(draw,:)-data4fit_scl.^2);

    if draw/10 == round(draw/10), fprintf('--------'), end

end

% For the Ricker model

posteriorsigned_ext = length(find(residualsNull_ext(1,:) > residualsRicker_ext(1,:)))./length(residualsRicker_ext(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_ext = posteriorsigned_ext./(1-posteriorsigned_ext); % converts likelihoods to odds   
Bayesmat_ext = posteriorOdds_ext./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

% For the Gaussian model

posteriorsignedG_ext = length(find(residualsNull_ext(1,:) > residualsGaussian_ext(1,:)))./length(residualsGaussian_ext(1,:)); % how likely is con1 < 2 given the data
posteriorOddsG_ext = posteriorsignedG_ext./(1-posteriorsignedG_ext); % converts likelihoods to odds   
Bayesmat_extG = posteriorOddsG_ext./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

%% Early and Later Acquisition

filemat = getfilesindir(pwd, '*amp2part.csd.at');  % should be 372 files


conditions = [11:14 20 22 23 24 31:34]; % This code separate each condition in different filemat objects
for x = 1:12 % 12 conditions
    
    string = ['*.app' num2str(conditions(x)) '.amp2part.csd.at'];

    eval(['filemat' num2str(conditions(x)) ' = getfilesindir(pwd, string)']);
    
end


options.MaxIter = 100000;
% step 2: make new grand means as described above
for draw = 1:1000
    
    selectionvec = randi(31,1, 31);
    
    temp20 = filemat20(selectionvec,:);
    temp22 = filemat22(selectionvec,:);
    temp23 = filemat23(selectionvec,:);
    temp24 = filemat24(selectionvec,:);
    
    CSp = avgavgfiles(temp20);
    GS1 = avgavgfiles(temp22);
    GS2 = avgavgfiles(temp23);
    GS3 = avgavgfiles(temp24);

    data4fit1 = [ mean(CSp([70,71,74,75,76,81,82,83], 1)) mean(GS1([70,71,74,75,76,81,82,83], 1)) mean(GS2([70,71,74,75,76,81,82,83], 1)) mean(GS3([70,71,74,75,76,81,82,83], 1))]; % early trials in occipital midline sensors
    data4fit1_scaling = rangecorrect(data4fit1);
    data4fit2 = [ mean(CSp([70,71,74,75,76,81,82,83], 2)) mean(GS1([70,71,74,75,76,81,82,83], 2)) mean(GS2([70,71,74,75,76,81,82,83], 2)) mean(GS3([70,71,74,75,76,81,82,83], 2))]; % later trials in occipital midline sensors
    data4fit2_scaling = rangecorrect(data4fit2);

    bootsData_acq1(draw,:) = data4fit1_scaling;
    bootsData_acq2(draw,:) = data4fit2_scaling;    

    [betaacq1(draw), ~, ~, ~, mseacq1(draw)] = nlinfit(0.25:0.25:1,data4fit1_scaling',@Ricker, .1, options); 
    fit_acq1(draw,:) = Ricker(0.25:0.25:1, betaacq1(draw)); 
    residualsRicker_acq1(draw) = mean(fit_acq1(draw,:)-data4fit1_scaling.^2);
    residualsNull_acq1(draw) = mean(data4fit1_scaling.^2);

    [betaacq2(draw), ~, ~, ~, mseacq2(draw)] = nlinfit(0.25:0.25:1,data4fit2_scaling',@Ricker, .1, options); 
    fit_acq2(draw,:) = Ricker(0.25:0.25:1, betaacq2(draw)); 
    residualsRicker_acq2(draw) = mean(fit_acq2(draw,:)-data4fit2_scaling.^2);
    residualsNull_acq2(draw) = mean(data4fit2_scaling.^2);

    if draw/10 == round(draw/10), fprintf('--------'), end

end

posteriorsigned_acq1 = length(find(residualsNull_acq1(1,:) > residualsRicker_acq1(1,:)))./length(residualsRicker_acq1(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_acq1 = posteriorsigned_acq1./(1-posteriorsigned_acq1); % converts likelihoods to odds   
Bayesmat_acq1 = posteriorOdds_acq1./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

posteriorsigned_acq2 = length(find(residualsNull_acq2(1,:) > residualsRicker_acq2(1,:)))./length(residualsRicker_acq2(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_acq2 = posteriorsigned_acq2./(1-posteriorsigned_acq2); % converts likelihoods to odds   
Bayesmat_acq2 = posteriorOdds_acq2./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

%% Early and Later Extinction

options.MaxIter = 100000;
% step 2: make new grand means as described above
for draw = 1:1000
    
    selectionvec = randi(31,1, 31);
    
    temp31 = filemat31(selectionvec,:);
    temp32 = filemat32(selectionvec,:);
    temp33 = filemat33(selectionvec,:);
    temp34 = filemat34(selectionvec,:);
    
    CSp = avgavgfiles(temp31);
    GS1 = avgavgfiles(temp32);
    GS2 = avgavgfiles(temp33);
    GS3 = avgavgfiles(temp34);

    data4fit1 = [ mean(CSp([70,71,74,75,76,81,82,83], 1)) mean(GS1([70,71,74,75,76,81,82,83], 1)) mean(GS2([70,71,74,75,76,81,82,83], 1)) mean(GS3([70,71,74,75,76,81,82,83], 1))]; % early trials in occipital midline sensors
    data4fit1_scaling = rangecorrect(data4fit1);
    data4fit2 = [ mean(CSp([70,71,74,75,76,81,82,83], 2)) mean(GS1([70,71,74,75,76,81,82,83], 2)) mean(GS2([70,71,74,75,76,81,82,83], 2)) mean(GS3([70,71,74,75,76,81,82,83], 2))]; % later trials in occipital midline sensors
    data4fit2_scaling = rangecorrect(data4fit2);

    bootsData_ext1(draw,:) = data4fit1_scaling;
    bootsData_ext2(draw,:) = data4fit2_scaling;

    [betaext1(draw), ~, ~, ~, mseacq1_ext(draw)] = nlinfit(0.25:0.25:1,data4fit1_scaling',@Ricker, .1, options); 
    fit_ext1(draw,:) = Ricker(0.25:0.25:1, betaext1(draw)); 
    residualsRicker_ext1(draw) = mean(fit_ext1(draw,:)-data4fit1_scaling.^2);
    residualsNull_ext1(draw) = mean(data4fit1_scaling.^2);

    [betaext2(draw), ~, ~, ~, mseacq2_ext(draw)] = nlinfit(0.25:0.25:1,data4fit2_scaling',@Ricker, .1, options); 
    fit_ext2(draw,:) = Ricker(0.25:0.25:1, betaext2(draw)); 
    residualsRicker_ext2(draw) = mean(fit_ext2(draw,:)-data4fit2_scaling.^2);
    residualsNull_ext2(draw) = mean(data4fit2_scaling.^2);

    if draw/10 == round(draw/10), fprintf('--------'), end

end

posteriorsigned_ext1 = length(find(residualsNull_ext1(1,:) > residualsRicker_ext1(1,:)))./length(residualsRicker_ext1(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_ext1 = posteriorsigned_ext1./(1-posteriorsigned_ext1); % converts likelihoods to odds   
Bayesmat_ext1 = posteriorOdds_ext1./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

posteriorsigned_ext2 = length(find(residualsNull_ext2(1,:) > residualsRicker_ext2(1,:)))./length(residualsRicker_ext2(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_ext2 = posteriorsigned_ext2./(1-posteriorsigned_ext2); % converts likelihoods to odds   
Bayesmat_ext2 = posteriorOdds_ext2./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds


%% Plots

figure
subplot(2,2,1); plot(Ricker(0.25:0.25:1, mean(betaacq1))); hold on; title(['Early acquisition, BF =', num2str(Bayesmat_acq1)]);
subplot(2,2,2); plot(Ricker(0.25:0.25:1, mean(betaacq2))); hold on; title(['Late acquisition, BF =', num2str(Bayesmat_acq2)]);

subplot(2,2,3); plot(Ricker(0.25:0.25:1, mean(betaext1))); hold on; title(['Early extinction, BF =', num2str(Bayesmat_ext1)]);
subplot(2,2,4); plot(Ricker(0.25:0.25:1, mean(betaext2))); hold on; title(['Late extinction, BF =', num2str(Bayesmat_ext2)]);



%% Habituation

filemat = getfilesindir(pwd, '*.habituation.csd.at');  % should be 372 files


conditions = 11:14;
for x = 1:4 % 4 conditions
    
    string = ['*.app' num2str(conditions(x)) '.habituation.csd.at'];

    eval(['filemat' num2str(conditions(x)) ' = getfilesindir(pwd, string)']);
    
end

options.MaxIter = 100000;
% step 2: make new grand means as described above
for draw = 1:1000
    
    selectionvec = randi(31,1, 31);
    
    temp31 = filemat11(selectionvec,:);
    temp32 = filemat12(selectionvec,:);
    temp33 = filemat13(selectionvec,:);
    temp34 = filemat14(selectionvec,:);
    
    CSp = avgavgfiles(temp31);
    GS1 = avgavgfiles(temp32);
    GS2 = avgavgfiles(temp33);
    GS3 = avgavgfiles(temp34);

    data4fit1 = [ mean(CSp([70,71,74,75,76,81,82,83], 1)) mean(GS1([70,71,74,75,76,81,82,83], 1)) mean(GS2([70,71,74,75,76,81,82,83], 1)) mean(GS3([70,71,74,75,76,81,82,83], 1))]; % early trials in occipital midline sensors
    data4fit1_scaling = rangecorrect(data4fit1);

    bootsData_hab1(draw,:) = data4fit1_scaling;

    [betahab1(draw), ~, ~, ~, mseacq1_ext(draw)] = nlinfit(0.25:0.25:1,data4fit1_scaling',@Ricker, .1, options); 
    fit_hab1(draw,:) = Ricker(0.25:0.25:1, betahab1(draw)); 
    residualsRicker_hab1(draw) = mean(fit_hab1(draw,:)-data4fit1_scaling.^2);
    residualsNull_hab1(draw) = mean(data4fit1_scaling.^2);

    if draw/10 == round(draw/10), fprintf('--------'), end

end

posteriorsigned_hab1 = length(find(residualsNull_hab1(1,:) > residualsRicker_hab1(1,:)))./length(residualsRicker_hab1(1,:)); % how likely is con1 < 2 given the data
posteriorOdds_hab1 = posteriorsigned_hab1./(1-posteriorsigned_hab1); % converts likelihoods to odds   
Bayesmat_hab1 = posteriorOdds_hab1./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds


figure
subplot(1,2,1); plot(Ricker(0.25:0.25:1, mean(betahab1))); hold on; title(['Early habituation, BF =', num2str(Bayesmat_hab1)]);
subplot(1,2,2); plot(Ricker(0.25:0.25:1, mean(betahab2))); hold on; title(['Late habituation, BF =', num2str(Bayesmat_hab2)]);

%%

figure
subplot(3,2,1); plot(Ricker(0.25:0.25:1, mean(betahab1)),"r"); hold on; title(['Habituation, BF =', num2str(Bayesmat_hab1)]); plot(mean(bootsData_hab1,1),"g");

subplot(3,2,3); plot(Ricker(0.25:0.25:1, mean(betaacq1)),"r"); hold on; title(['Early acquisition, BF =', num2str(Bayesmat_acq1)]); plot(mean(bootsData_acq1,1),"g");
subplot(3,2,4); plot(Ricker(0.25:0.25:1, mean(betaacq2)),"r"); hold on; title(['Late acquisition, BF =', num2str(Bayesmat_acq2)]); plot(mean(bootsData_acq2,1),"g");

subplot(3,2,5); plot(Ricker(0.25:0.25:1, mean(betaext1)),"r"); hold on; title(['Early extinction, BF =', num2str(Bayesmat_ext1)]); plot(mean(bootsData_ext1,1),"g");
subplot(3,2,6); plot(Ricker(0.25:0.25:1, mean(betaext2)),"r"); hold on; title(['Late extinction, BF =', num2str(Bayesmat_ext2)]); plot(mean(bootsData_ext2,1),"g");


