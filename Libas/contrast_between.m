function [ Fcontvec, rcontvec ] = contrast_between( data, groupvector, weights )
%contrast_between calculates fs for a contrast in groups with unequal n
%  data needs to be arranged such that rows are subjects

%1 find how many groups there are and their ns
   groups = unique(groupvector);

    for index = 1:length(groups)
     nvec(index) = length(find(groupvector == index)); 
    end 

% if there are channels or time points (= 2nd dimension)
% loop over those

for loopindex = 1:size(data,2); 

    % calulate group means and stats for each loppindex (time or channel)

    for index = 1:length(groups); 
      meanvec(index) = mean(data(groupvector == index, loopindex)); 
    end 
    
    % multiply meanvec with harmonic mean of the ns (R&R page 17/18)
    nh = length(groups)./ sum(1./nvec);
    
    T = nh.* meanvec;
    
    % calulate SS contrast
   
    SScontrast = (sum(T.*weights).^2) ./ (nh .* sum(weights.^2));
    
    
     % calulate SS error
     
     DFerror = size(data,1) - length(groups);
     
     % calulate within-group variance

    for index = 1:length(groups); 
      SSvec(index) = sum((data(groupvector == index, loopindex)-mean(data(groupvector == index, loopindex))).^2); 
    end
    
    SSerror = sum(SSvec);
    MSerror = SSerror./DFerror;
    
    Fcontvec(loopindex) = SScontrast/MSerror; 
    rcontvec(loopindex) = sqrt( Fcontvec(loopindex) ./ (Fcontvec(loopindex) + DFerror)); 
    
    
end


