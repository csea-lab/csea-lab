

reinforcement = [0 0 0 0 0 0 0 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 .4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]; % simulated US outcomes

reinforcement = reinforcement+ rand(1, length(reinforcement))./3; % add noise

w = rescorlaWagnerLearnMod([0.1 1], reinforcement');

%VM = shiftLam([4 -2 -1 1 1 -1 -2])'



for index = 1:length(reinforcement)
     
    input = gaussPro(-3:3, 1./(w(index).*3)).*(1+w(index));
    
    input = z_norm(input); 
    
    VM = shiftLam([max(input) min(input)-0.5 min(input) 1 1 min(input) min(input)-.5])

    temp(:, index) = VM*input', plot(temp(:, index)), hold on, plot(input), title(num2str(reinforcement(index))), hold off
    
    pause(.2)

end

contourf(temp)

% 
% %% 
% %% gaussPro.m
% % this function computes a discrete Gaussian curve, where s is a row 
% % vector of values and sd is the standard deviation of the Gaussian 
% function gd = gaussPro(s,sd) % declare the function
%     gd = exp((s/sd) .^ 2 * (-0.5)); % compute the Gaussian curve
% end
% 
% %% 
% % makes connectivity matrix MX by laminating shifted versions of the 
% % same row vector rv that contains the desired connectivity profile
% function MX = shiftLam(rv) % declare the function
% [dum,nUnits] = size(rv); % find the number of units in the network
%     for i = 1:nUnits % for each unit in the network
%    MX(i,:) = rv; % set its row of the weight matrix to the profile
%    rv = [rv(nUnits) rv(1:nUnits-1)]; % shift the profile
%     end % end the loop
% end
% 
