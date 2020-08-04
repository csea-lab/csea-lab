%% 1. analysis for pictype by threat versus safe block, 6 conditions: 

%%%% 4. MAIN EFFECT of threat in IAPS in 8 conditions, with 18 people 144 files (18 * 8) 
% get filemat of all hamp files, then do ROI
clear
filemat = getfilesindir(pwd, '*hamp12');

% apply ROI
for x = 1:size(filemat,1)  
a = ReadAvgFile(deblank(filemat(x,:))); 
b = bslcorr(a, 300:500); 
ROImatHamp(x,:) = mean(b([75 74 82],:)); 
end

% use only ramp up segment
ROImatHampCRF = ROImatHamp(:, 500:1900); 

% average every 100 sample points into 13 bins
timeindex = 1;
for x = 1:100:1300; 
    mat4fit(:, timeindex) = mean(ROImatHampCRF(:, x:x+100), 2); 
    timeindex = timeindex+ 1; 
end

% normalize by the mean
for x = 1:144; mat4fit(x,:) = (mat4fit(x,:)+mean(mat4fit))./2; end

% average like conditions, here for threat
mat4fitnew = zeros(2*18,13); 
mat4fitnew(1:2:end,:) = (mat4fit(1:8:end,:) + mat4fit(2:8:end,:)+ mat4fit(3:8:end,:)+ mat4fit(4:8:end,:))./4;
mat4fitnew(2:2:end,:) = (mat4fit(5:8:end,:) + mat4fit(6:8:end,:)+ mat4fit(7:8:end,:)+ mat4fit(8:8:end,:))./4;
       
% make a cell array for palamedesgainface script, then do normalization of each person from 0 to 1
cellmat4fit = []; 
for x = 1:18, cellmat4fit{x} = mat4fitnew(x*2-1:x*2,:), end
for x = 1:18, cellmat4fit{x} = (cellmat4fit{x}+abs(min(min(cellmat4fit{x})))),  end
for x = 1:18, cellmat4fit{x} = (cellmat4fit{x}./(max(max(cellmat4fit{x})))),  end

%%
% now run appropriate field in palamedesgainesface for this condition

%% AFTER palamedesgainface, do this.
% plot histograms and assess differences for N conditions
 Ncons = size(Boot_paramsValues, 1); % number of conditions - can be 6 or 4 or 8 depending on what you are doing 
 
 % calculate RMSE for each condition just after running palamedesgainface, with GM and fit
 % figure

 for x1 = 1:Ncons
     ProportionCorrectModel = PF(GM_paramsValues(x1,:),StimLevels); 
    figure(66), plot(ProportionCorrectModel), hold on, plot(GM_percentCorr(x1,:)), pause, hold off
     RMSE(x1) = sqrt(mean((ProportionCorrectModel-GM_percentCorr(x1,:)).^2)); 
 end

%load PalamedesOutput.mat %if needed
for param = 1:4
  
    parameter =param; % can be 1 2, 3, or 4
    % alpha(1) = location, beta(2) = slope, gamma(3) = guess rate, lambda(4) = lapse rate (upper asymptote) 

    N = []; bins = []; 
    confborders = [];  

    % compute histograms
    for con = 1:size(Boot_paramsValues, 1)
     [N(con,:), bins(con,:)] = hist(squeeze(Boot_paramsValues(con,parameter,:)), 50); 
    end

    % plot histograms
    figure, 
    for con = 1:size(Boot_paramsValues, 1); 
    bar(bins(con,:), N(con,:)), hold on, pause(.5)
    end
    title(['parameter: ' num2str(parameter)]),  legend
    hold off

    % use bootstrapped confidence intervals to look for robust 
    % differences, with high Bayes factors, posterior odds over prior odds (0.5) 
    % i.e., are any lower borders higher than upper borders? or vice versa? 
    Bayesmat = zeros(size(Boot_paramsValues, 1), size(Boot_paramsValues, 1)); 

    for con1 = 1:Ncons

      for con2 = 1:Ncons

        BootstrapDist1 = squeeze(Boot_paramsValues(con1, parameter, :)); 

        BootstrapDist2 = squeeze(Boot_paramsValues(con2, parameter, :));  

        BootstrapDist2 = BootstrapDist2+(rand(size(BootstrapDist2))-.5)./1000; % does not change data but avoids that both are exactly the same. allows checking BF=1 in diag

        posteriorsigned(con1, con2) = length(find(BootstrapDist1 < BootstrapDist2))./length(BootstrapDist1); % how likely is con1 < 2 given the data

        posteriorOdds(con1, con2) = posteriorsigned(con1, con2)./(1-posteriorsigned(con1, con2)); % converts likelihoods to odds   

        Bayesmat(con1, con2) = posteriorOdds(con1, con2)./1; % prior odds for a value being greater/smaller in one condition are fifty-fifty, i.e. 1; BF = posterior odds / prior odds

      end
      
    end
   
    disp(Bayesmat), pause
    
end % param






