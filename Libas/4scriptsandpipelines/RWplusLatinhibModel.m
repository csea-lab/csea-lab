
clear 

reinforcement = [ 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 1 0 1 0 0 1 1 1 1  0 0 0 0 0 0 0 0 0 0 0 0  ]; % simulated US outcomes

reinforcement = reinforcement+ rand(1, length(reinforcement))./3; % add noise

[w, delta] = rescorlaWagnerLearnMod([0.1 1], reinforcement'); % execute rescorla wagner model, get assoc. strength and pred error

delta_smooth = movingavg_as_forward(delta, 10); 

for index = 1:length(reinforcement)
    
    I1 = -.1 -w(index); % lateral inhibition weights, changing with associative strength
    I2 = -1 -w(index);
    
    VM = shiftLam([2 I2 I1 1 1 I1 I2])' % lateral inhibition matrix
    
    input = rand(1,7)./10+gaussPro(-3:3, 1./(w(index).*3)) *sign(delta_smooth(index)) *w(index); % generalization to surrounding stimuli, width changes with assoc strength, magnitide with prediction error
    
    amygdala(:, index) = gaussPro(-3:3, 1./(w(index).*3)) *(delta(index)); 
    
    A(:, index) = input'; 
    
    R(:, index) = VM*input', figure(11), plot(R(:, index)), hold on, plot(input), title(num2str(reinforcement(index))), hold off

    pause(.1)

end

amygdala(:, 1:5) = 0; 

figure(10), 
subplot(3,1,3), colormap('jet'), contourf(R, 12), colorbar
subplot(3,1,2),colormap('jet'), contourf(A, 12), colorbar
subplot(3,1,1),colormap('jet'), contourf(amygdala, 12), colorbar


%% gaussPro.m
% this function computes a discrete Gaussian curve, where s is a row 
% vector of values and sd is the standard deviation of the Gaussian 
function gd = gaussPro(s,sd) % declare the function
gd = exp((s/sd) .^ 2 * (-0.5)); % compute the Gaussian curve
end
%% shiftLam.m
% makes connectivity matrix MX by laminating shifted versions of the 
% same row vector rv that contains the desired connectivity profile
function MX = shiftLam(rv) % declare the function
[dum,nUnits] = size(rv); % find the number of units in the network
for i = 1:nUnits % for each unit in the network
   MX(i,:) = rv; % set its row of the weight matrix to the profile
   rv = [rv(nUnits) rv(1:nUnits-1)]; % shift the profile
end % end the loop
end
