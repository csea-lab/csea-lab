function [z_delta, mu, sd, epsilon, BF] = epsilon_delta(invec1, invec2, n)
% calculates epsilon according to Schwarzkopf, 2015
% die frisur hält; input only column vectors
% https://www.biorxiv.org/content/10.1101/017327v2.full
% takes 2 vectors and caluclates real difference distribution (thetaH1) and permutationdiff (thetaH0)
% then does the stuff from the paper above
% this works only for gainface. for other studies, estimate thetaH0 differently


 invec1 = column(invec1); % make sure its is column vectors
 invec2 = column(invec2); 

 thetaH1 = invec1-invec2; % the difference distribution under H1

 for bootIdx = 1:length(invec1)% the difference distribution under H1
 temp = cat(1, invec1, invec2); % puts all bootstraps in one distribution
 temp = temp(randperm(length(temp))); % shuffles them 
 thetaH0(bootIdx) = median(temp(1:10) - temp(21:30)); 
 end
thetaH0 = column(thetaH0); 
 
  [N_H1, bins_H1] = hist(thetaH1, 50); 
  [N_H0, bins_H0] = hist(thetaH0, 50); 
  
  figure(99)
  bar(bins_H0, N_H0), hold on, pause(.5)
  bar(bins_H1, N_H1), title('distribution of effect size and of random perm difference')
  hold off
  
  delta = thetaH1-thetaH0; % the difference of difference distribution (effect size distrib., delta)
  mu = mean(delta); 
  sd = std(delta); 
  z_delta = mu/sd; % the effect size z, or normalized evidence for H1
  
  figure(199)
  hist(delta, 50), title('delta'); grid
  
  omega = length(find(delta <= 0))./length(find(delta>0))
  
  e_numerator = (1-omega).*abs(mu)+omega*sd; 
  e_denominator = (1+omega.*log(n)).* sd; 
  epsilon = log( e_numerator./e_denominator ) 
  
  priorsigned = length(find(thetaH0 >0))./length(thetaH0); % how likely is con1 < 2 given the data
  priorOdds = priorsigned./(1-priorsigned) % converts likelihoods to odds   
  
  posteriorsigned = length(find(thetaH1 >0))./length(thetaH1); % how likely is con1 < 2 given the data
  posteriorOdds = posteriorsigned./(1-posteriorsigned) % converts likelihoods to odds   

   BF = posteriorOdds./priorOdds; % prior odds for a value being greater/smaller in one condition are fifty-fift, i.e. 1; BF = posterior odds / prior odds

        
  
  