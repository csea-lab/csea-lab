%-------------------------------------------------------------------
function [w, delta] = gamblersf_ak(params, r)
% learn weights w based on inputs u and rewards r with learning rate eta
%delta = prediction error for each trial

%invert contingencies for gambler's fallacy
r = (r.*-1) + 1; 

eta = params(1); %learning rate
% u= params(2); %saliency of US?
u = 1;

trials = size(r,1); % establish number of trials
dim = size(u,2); % establish number of feature dimensions
w = zeros(trials+1, dim);
delta = zeros(trials+1, dim);%prediction error

for t=2:trials
    delta(t) = u .* eta .* ((w(t))-r(t));
    w(t+1) = ((w(t) - delta(t)));   
end

w(isinf(w)) = 1;
w = w(2:end); 

% delta(isinf(delta)) = 1;
% delta = delta(2:end); 
