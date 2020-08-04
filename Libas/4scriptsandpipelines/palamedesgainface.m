% Fitting using the Palemedies Toolbox & book
%% this is for 8 conditions: IAPS content by block

% stimulus contrast levels
% StimLevels = ((1:25)./2.63).^2
%StimLevels = log( exp(0.001:0.49:5.95)./4)

StimLevels = [0:2:25]; 
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
%PF = @PAL_Weibull;
PF = @PAL_Gumbel;
%PF = @PAL_Logistic;
% PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 1 1]; % here, estimating location, slope & lapse rate 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = 5:0.02:17;
searchGrid.beta = 0:.05:5;
searchGrid.gamma = 0.1;
searchGrid.lambda = .05:0.05:.8;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 8 conditions, with all individual % correct mats listed in a cell named 'mat' 
figure (999)
for parti = 1:1:size(cellmat4fit,2)     
        temp = (cellmat4fit{parti}); plot(temp'), title(['subject ' num2str(parti)]), pause(1)         
        for condi = 1:8 % conditions
            if condi == 1 
            firstcondMat(parti,:) = temp(condi,:);
            elseif condi == 2
            secondcondMat(parti,:) = temp(condi,:);
            elseif condi == 3
            thirdcondMat(parti,:) = temp(condi,:);
            elseif condi == 4
            fourthcondMat(parti,:) = temp(condi,:);
             elseif condi == 5
            fifthcondMat(parti,:) = temp(condi,:);
            elseif condi == 6
            sixthcondMat(parti,:) = temp(condi,:);
            elseif condi == 7
            seventhcondMat(parti,:) = temp(condi,:);
            else
            eighthcondMat(parti,:) = temp(condi,:); 
            end
        end
end

% now make separate grand mean mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);
Mat3 = sum(thirdcondMat.*100);
Mat4 = sum(fourthcondMat.*100);
Mat5 = sum(fifthcondMat.*100);
Mat6 = sum(sixthcondMat.*100);
Mat7 = sum(seventhcondMat.*100);
Mat8 = sum(eighthcondMat.*100);

GMmat = [Mat1; Mat2; Mat3; Mat4; Mat5; Mat6; Mat7; Mat8];

plot(GMmat'), title(['grand mean']), legend, pause(1) 

OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); % converts to trials and "proportion correct" for the sake of palamedes

% FITTING: for each GM condition, fit the desired function
GM_numsCorr = []; 
GM_paramsValues = []; 

for condi = 1:8
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
end

%Create a plot of the fitted data
figure('name','Maximum Likelihood Psychometric Functions Fitted to the data');
axes, hold on 

for condi = 1:8
ProportionCorrectModel = PF(GM_paramsValues(condi,:),StimLevelsFine);
plot(StimLevelsFine,ProportionCorrectModel,'-','color',[1/condi condi/10 (100-condi*10)/100],'linewidth',4);
plot(StimLevels,GM_percentCorr(condi,:),'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) .0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
end
 legend('1', '1', '2', '2', '3', '3', '4', '4', '5', '5', '6', '6', '7', '7', '8', '8') 
 
 pause(1) 

% now AK bootstrapping 
disp('start bootstrapping....')

 Boot_paramsValues = []; 

for iteration = 1:2000   
    if iteration/50 == round (iteration/50), fprintf('.'), end
    subvec = ceil(rand(18,1).*18); % Randomize subjects with replacement, aka bootstrapping
        % make bootstrapped mats for each condition 
 
        Mat1 = sum(firstcondMat(subvec,:).*100);
        Mat2 = sum(secondcondMat(subvec,:).*100);
        Mat3 = sum(thirdcondMat(subvec,:).*100);
        Mat4 = sum(fourthcondMat(subvec,:).*100);
        Mat5 = sum(fifthcondMat(subvec,:).*100);
        Mat6 = sum(sixthcondMat(subvec,:).*100);
        Mat7 = sum(seventhcondMat(subvec,:).*100);
        Mat8 = sum(eighthcondMat(subvec,:).*100);

        GMmat = [Mat1; Mat2; Mat3; Mat4; Mat5; Mat6; Mat7; Mat8];
        
        OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); 
        % for each GM condition, fit the desired function
       
        GM_numsCorr = []; 

        for condi = 1:8       
        GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
        GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %        
        % Fit and get the log-liklihood value for each GM condition
        [Boot_paramsValues(condi,:, iteration), Boot_LL(condi, iteration), Boot_exitflag(condi, iteration)]... 
         = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
        end
       
end

disp('... aaaaaand done. go back to other script (memo) for stats and plots')



%% this is for 6 conditions: block by pictype

% stimulus contrast levels
%StimLevels = [0:2:25].*[1:0.21:3.6];
StimLevels = [0:2:25]; % gumbel expects log transformed stimulus intensities
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
%PF = @PAL_Weibull;
PF = @PAL_Gumbel;
% PF = @PAL_Logistic;
%  PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 1 1]; % here, just estimating location, slope & lapse rate 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = 5:0.02:17;
searchGrid.beta = 0:.05:5;
searchGrid.gamma = 0.1;
searchGrid.lambda = .05:0.05:.8;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 6 conditions, with all individual % correct mats listed in a cell named 'mat' 
figure (999)
for parti = 1:1:size(cellmat4fit,2) 
    temp = (cellmat4fit{parti}); plot(temp'), pause(.5) 
for condi = 1:6 % conditions
    if condi == 1 
    firstcondMat(parti,:) = temp(condi,:);
    elseif condi == 2
    secondcondMat(parti,:) = temp(condi,:);
    elseif condi == 3
    thirdcondMat(parti,:) = temp(condi,:);
    elseif condi == 4
    fourthcondMat(parti,:) = temp(condi,:);
    elseif condi == 5
    fifthcondMat(parti,:) = temp(condi,:);
    else
    sixthcondMat(parti,:) = temp(condi,:);
    end
end
end
% then make seperate mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);
Mat3 = sum(thirdcondMat.*100);
Mat4 = sum(fourthcondMat.*100);
Mat5 = sum(fifthcondMat.*100);
Mat6 = sum(sixthcondMat.*100);

GMmat = [Mat1; Mat2; Mat3; Mat4; Mat5; Mat6];

plot(GMmat'), title(['grand mean']), legend, pause(1) 

OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); % converts to trials and "proportion correct" for the sake of palamedes
% for each GM condition, fit the desired function

GM_numsCorr = []; 
GM_paramsValues = []; 

for condi = 1:6
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
% uncomment and run StimLevelsFine if you want it to plot
% GM_Fit(condi,:) = PF(GM_paramsValues_PF(condi,:), StimLevelsFine);
end

%Create a plot of the fitted data
figure('name','Maximum Likelihood Psychometric Functions Fitted to the data');
axes, hold on 

for condi = 1:6
ProportionCorrectModel = PF(GM_paramsValues(condi,:),StimLevelsFine);
plot(StimLevelsFine,ProportionCorrectModel,'-','color',[1/condi condi/10 (100-condi*10)/100],'linewidth',4);
plot(StimLevels,GM_percentCorr(condi,:),'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) .0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
end
 legend('1', '1', '2', '2', '3', '3', '4', '4', '5', '5', '6', '6') 
 
 pause(1) 

% now AK bootstrapping 
disp('start bootstrapping....')

Boot_paramsValues = []; 

for iteration = 1:2000   
    if iteration/50 == round (iteration/50), fprintf('.'), end
    subvec = ceil(rand(18,1).*18); % Randomize subjects with replacement, aka bootstrapping
        % make bootstrapped mats for each condition 
 
        Mat1 = sum(firstcondMat(subvec,:).*100);
        Mat2 = sum(secondcondMat(subvec,:).*100);
        Mat3 = sum(thirdcondMat(subvec,:).*100);
        Mat4 = sum(fourthcondMat(subvec,:).*100);
        Mat5 = sum(fifthcondMat(subvec,:).*100);
        Mat6 = sum(sixthcondMat(subvec,:).*100);
 
        GMmat = [Mat1; Mat2; Mat3; Mat4; Mat5; Mat6];
        
        OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); 
        % for each GM condition, fit the desired function
       
        GM_numsCorr = []; 
    
   
        for condi = 1:6       
        GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
        GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %        
        % Fit and get the log-liklihood value for each GM condition
        [Boot_paramsValues(condi,:, iteration), Boot_LL(condi, iteration), Boot_exitflag(condi, iteration)]... 
         = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
        end
       
end

disp('... aaaaaand done. go back to other script (memo) for stats and plots')

%% this is for 4 conditions: e.g., angry/neutral faces by block

% stimulus contrast levels
%StimLevels = [0:2:25].*[1:0.21:3.6];
StimLevels = [0:2:25]; % gumbel expects log transformed stimulus intensities
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
%PF = @PAL_Weibull;
PF = @PAL_Gumbel;
% PF = @PAL_Logistic;
%  PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 1 1]; % here, just estimating location, slope & lapse rate 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = 5:0.02:17;
searchGrid.beta = 0:.05:5;
searchGrid.gamma = 0.1;
searchGrid.lambda = .05:0.05:.8;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 4 conditions, with all individual % correct mats listed in a cell named 'mat' 
figure (999)
 %vidObj1 = VideoWriter('singlesubjects.avi');
    %open(vidObj1);
for parti = 1:1:size(cellmat4fit,2) 
    temp = (cellmat4fit{parti}); plot(temp'), currFrame = getframe; 
    %writeVideo(vidObj1,currFrame);pause(2) 
for condi = 1:4 % conditions
    if condi == 1 
    firstcondMat(parti,:) = temp(condi,:);
    elseif condi == 2
    secondcondMat(parti,:) = temp(condi,:);
    elseif condi == 3
    thirdcondMat(parti,:) = temp(condi,:);
    else
    fourthcondMat(parti,:) = temp(condi,:);
    end
end
end

  %close(vidObj1);
% then make seperate mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);
Mat3 = sum(thirdcondMat.*100);
Mat4 = sum(fourthcondMat.*100);

GMmat = [Mat1; Mat2; Mat3; Mat4];

plot(GMmat'), title(['grand mean']), legend, pause(1) 

OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); % converts to trials and "proportion correct" for the sake of palamedes
% for each GM condition, fit the desired function

GM_numsCorr = []; 


for condi = 1:4
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
% uncomment and run StimLevelsFine if you want it to plot
% GM_Fit(condi,:) = PF(GM_paramsValues_PF(condi,:), StimLevelsFine);
end

%Create a plot of the fitted data
figure('name','Maximum Likelihood Psychometric Functions Fitted to the data');
axes, hold on 

for condi = 1:4
ProportionCorrectModel = PF(GM_paramsValues(condi,:),StimLevelsFine);
plot(StimLevelsFine,ProportionCorrectModel,'-','color',[1/condi condi/10 (100-condi*10)/100],'linewidth',4);
plot(StimLevels,GM_percentCorr(condi,:),'.','color',[1/condi condi/10 (100-condi*10)/100],'markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) .0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
end
 legend('1', '1', '2', '2', '3', '3', '4', '4') 
 
 pause(1) 

% now AK bootstrapping 
disp('start bootstrapping....')

 Boot_paramsValues = []; 

for iteration = 1:2000   
    if iteration/50 == round (iteration/50), fprintf('.'), end
    subvec = ceil(rand(18,1).*18); % Randomize subjects with replacement, aka bootstrapping
        % make bootstrapped mats for each condition 
 
        Mat1 = sum(firstcondMat(subvec,:).*100);
        Mat2 = sum(secondcondMat(subvec,:).*100);
        Mat3 = sum(thirdcondMat(subvec,:).*100);
        Mat4 = sum(fourthcondMat(subvec,:).*100);

 
        GMmat = [Mat1; Mat2; Mat3; Mat4];
        
        OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); 
        % for each GM condition, fit the desired function
       
        GM_numsCorr = []; 

        for condi = 1:4       
        GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
        GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %        
        % Fit and get the log-liklihood value for each GM condition
        [Boot_paramsValues(condi,:, iteration), Boot_LL(condi, iteration), Boot_exitflag(condi, iteration)]... 
         = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
        end
       
end

disp('... aaaaaand done. go back to other script (wrapper) for stats and plots')
%%
%%%% this is for 2 conditions: main effects
tic
% stimulus contrast levels
%StimLevels = [0:2:25].*[1:0.21:3.6];
StimLevels = [0:2:25]; % gumbel expects log transformed stimulus intensities
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
%PF = @PAL_Weibull;
PF = @PAL_Gumbel;
% PF = @PAL_Logistic;
%  PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 1 1]; % here, just estimating location, slope & lapse rate 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = 5:0.02:17;
searchGrid.beta = 0:.05:5;
searchGrid.gamma = 0.1;
searchGrid.lambda = .05:0.05:.8;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 4 conditions, with all individual % correct mats listed in a cell named 'mat' 
figure (999)
 %vidObj1 = VideoWriter('singlesubjects.avi');
    %open(vidObj1);
for parti = 1:1:size(cellmat4fit,2) 
    temp = (cellmat4fit{parti}); plot(temp'), pause(1), %currFrame = getframe; 
    %writeVideo(vidObj1,currFrame);pause(2) 
for condi = 1:2 % conditions
    if condi == 1 
    firstcondMat(parti,:) = temp(condi,:);
    else
    secondcondMat(parti,:) = temp(condi,:);
    end
end
end

  %close(vidObj1);
% then make seperate mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);


GMmat = [Mat1; Mat2];

plot(GMmat'), title(['grand mean']), legend, pause(1) 

OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); % converts to trials and "proportion correct" for the sake of palamedes
% for each GM condition, fit the desired function

GM_numsCorr = []; 


for condi = 1:2
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
% uncomment and run StimLevelsFine if you want it to plot
% GM_Fit(condi,:) = PF(GM_paramsValues_PF(condi,:), StimLevelsFine);
end

%Create a plot of the fitted data
figure('name','Maximum Likelihood Psychometric Functions Fitted to the data');
axes, hold on 

for condi = 1:2
ProportionCorrectModel = PF(GM_paramsValues(condi,:),StimLevelsFine);
plot(StimLevelsFine,ProportionCorrectModel,'-','color',[1/condi condi/10 (100-condi*10)/100],'linewidth',4);
plot(StimLevels,GM_percentCorr(condi,:),'.','color',[1/condi condi/10 (100-condi*10)/100],'markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) .0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
end
 legend('1 fit', '1 data', '2 fit', '2 data') 
 
 pause(1) 

% now AK bootstrapping 
disp('start bootstrapping....')

 Boot_paramsValues = []; 

for iteration = 1:2000   
    if iteration/50 == round (iteration/50), fprintf('.'), end
    if iteration/500 == round (iteration/500), disp(iteration), end
    
    subvec = ceil(rand(18,1).*18); % Randomize subjects with replacement, aka bootstrapping
        % make bootstrapped mats for each condition 
 
        Mat1 = sum(firstcondMat(subvec,:).*100);
        Mat2 = sum(secondcondMat(subvec,:).*100);
 
        GMmat = [Mat1; Mat2];
        
        OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); 
        % for each GM condition, fit the desired function
       
        GM_numsCorr = []; 

        for condi = 1:2       
        GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
        GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %        
        % Fit and get the log-liklihood value for each GM condition
        [Boot_paramsValues(condi,:, iteration), Boot_LL(condi, iteration), Boot_exitflag(condi, iteration)]... 
         = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
        end
       
end

disp('... aaaaaand done. go back to other script (memo) for stats and plots')
toc
%%
%%%% this is for 3 conditions: main effects

% stimulus contrast levels
%StimLevels = [0:2:25].*[1:0.21:3.6];
StimLevels = [0:2:25]; % gumbel expects log transformed stimulus intensities
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
%PF = @PAL_Weibull;
PF = @PAL_Gumbel;
% PF = @PAL_Logistic;
%  PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 1 1]; % here, just estimating location, slope & lapse rate 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = 5:0.02:17;
searchGrid.beta = 0:.05:5;
searchGrid.gamma = 0.1;
searchGrid.lambda = .05:0.05:.8;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 4 conditions, with all individual % correct mats listed in a cell named 'mat' 
figure (999)
 %vidObj1 = VideoWriter('singlesubjects.avi');
    %open(vidObj1);
for parti = 1:1:size(cellmat4fit,2) 
    temp = (cellmat4fit{parti}); plot(temp'), pause(1), %currFrame = getframe; 
    %writeVideo(vidObj1,currFrame);pause(2) 
    for condi = 1:3 % conditions
        if condi == 1 
        firstcondMat(parti,:) = temp(condi,:);
        elseif condi == 2
        secondcondMat(parti,:) = temp(condi,:);
        else 
        thirdcondMat(parti,:) = temp(condi,:);    
        end
    end
end

  %close(vidObj1);
% then make seperate mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);
Mat3 = sum(thirdcondMat.*100);


GMmat = [Mat1; Mat2; Mat3];

plot(GMmat'), title(['grand mean']), legend, pause(1) 

OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); % converts to trials and "proportion correct" for the sake of palamedes
% for each GM condition, fit the desired function

GM_numsCorr = []; 


for condi = 1:3
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
% uncomment and run StimLevelsFine if you want it to plot
% GM_Fit(condi,:) = PF(GM_paramsValues_PF(condi,:), StimLevelsFine);
end

%Create a plot of the fitted data
figure('name','Maximum Likelihood Psychometric Functions Fitted to the data');
axes, hold on 

for condi = 1:3
ProportionCorrectModel = PF(GM_paramsValues(condi,:),StimLevelsFine);
plot(StimLevelsFine,ProportionCorrectModel,'-','color',[1/condi condi/10 (100-condi*10)/100],'linewidth',4);
plot(StimLevels,GM_percentCorr(condi,:),'.','color',[1/condi condi/10 (100-condi*10)/100],'markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) .0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
end
 legend('1 fit', '1 data', '2 fit', '2 data', '3 fit', '3 data') 
 
 pause(1) 

% now AK bootstrapping 
disp('start bootstrapping....')

 Boot_paramsValues = []; 

for iteration = 1:2000   
    if iteration/50 == round (iteration/50), fprintf('.'), end
    if iteration/500 == round (iteration/500), disp(iteration), end
    
    subvec = ceil(rand(18,1).*18); % Randomize subjects with replacement, aka bootstrapping
        % make bootstrapped mats for each condition 
 
        Mat1 = sum(firstcondMat(subvec,:).*100);
        Mat2 = sum(secondcondMat(subvec,:).*100);
        Mat3 = sum(thirdcondMat(subvec,:).*100);
 
        GMmat = [Mat1; Mat2; Mat3];
        
        OutOfNum_tot = OutOfNum .* size(cellmat4fit,2); 
        % for each GM condition, fit the desired function
       
        GM_numsCorr = []; 

        for condi = 1:3       
        GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
        GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %        
        % Fit and get the log-liklihood value for each GM condition
        [Boot_paramsValues(condi,:, iteration), Boot_LL(condi, iteration), Boot_exitflag(condi, iteration)]... 
         = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
        end
       
end

disp('... aaaaaand done. go back to other script (memo) for stats and plots')