% Fitting using the Palemedies Toolbox & book
% stimulus contrast levels
StimLevels = [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700];
% stimlevelsfine is just for plotting, you can leave it out
StimLevelsFine = [min(StimLevels):(max(StimLevels)-min(StimLevels))./1000:max(StimLevels)];

% Then choose the PF you want(lots more) - can also program one
PF = @PAL_Weibull;
%PF = @PAL_Gumbel;
%PF = @PAL_Logistic;
%PF = @PAL_logQuick;

% choose the paramaters to estimate
% 0 = specify yourself, 1 = estimate
% alpha = location, beta = slope, gamma = guess rate, lambda = lapse rate (upper asymptote) 
paramsFree = [1 1 0 0]; % here, just estimating location & slope 

% specify a wide search area for Palemedies to do a "brute force" paramater
% search through - see the book for details
searchGrid.alpha = (.25:0.01:10);
searchGrid.beta = (0:.1:15);
searchGrid.gamma = 0.5;
searchGrid.lambda = 0.018;

% //////////////////////// setting up the data //////////////////////// %  
% PAL wants everything in # correct, not % correct):
OutOfNum = 100*(ones(length(StimLevels),1))'; % 1 entry for every stim level

% for using overall data (not individual PFs)
% Extract correct responses from everyone in each contrast cond.

% here, 4 conditions, with all individual % correct mats listed in a cell named 'mat' 

for parti = 1:1:size(mat,1) 
    temp = eval(mat{parti});
for condi = 1:4 % make blocks for CS+/- in HAB & ACQ   
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
% then make seperate mats for each condition 
Mat1 = sum(firstcondMat.*100);
Mat2 = sum(secondcondMat.*100);
Mat3 = sum(thirdcondMat.*100);
Mat4 = sum(fourthcondMat.*100);

GMmat = [Mat1; Mat2; Mat3; Mat4];
OutOfNum_tot = OutOfNum .* size(mat,1); 
% for each GM condition, fit the desired function
for condi = 1:4
GM_numsCorr(condi,:) = GMmat(condi,:); % stores # correct for each condition
GM_percentCorr(condi,:) = GMmat(condi,:)./OutOfNum_tot; % same for %
% Fit and get the log-liklihood value for each GM condition
[GM_paramsValues(condi,:) GM_LL(condi) GM_exitflag(condi)]... 
 = PAL_PFML_Fit(StimLevels, GM_numsCorr(condi,:), OutOfNum_tot,searchGrid, paramsFree,PF);
% uncomment and run StimLevelsFine if you want it to plot
% GM_Fit(condi,:) = PF(GM_paramsValues_PF(condi,:), StimLevelsFine);
end

% now the PF paramaters are estimated, get bootstrapped SE & simulated
% distributions
% non-parametric Bootstrap (can change to parametric, see book)

B = 1000; % B is the number of bootstrap iterations (10k takes ~12 hrs)
for condi = 1:4
NumPos = GMmat(condi,:);
[SD(condi,:) paramsSim(condi,:,:) LLSim(condi,:) converged(condi,:)] = PAL_PFML_BootstrapNonParametric... 
(StimLevels,NumPos, OutOfNum_tot, [],paramsFree, B, PF, 'searchGrid', searchGrid);
end













