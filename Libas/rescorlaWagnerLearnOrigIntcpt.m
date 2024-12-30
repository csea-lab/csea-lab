%-------------------------------------------------------------------
function w = rescorlaWagnerLearnOrigIntcpt(params, r)
% learn weights w based on inputs u and rewards r with learning rate eta


eta = params(1);
u= params(2);
intcpt = params(3);

trials = size(r,1); % establish number of trials
dim = size(u,2); % establish number of feature dimensions
w = zeros(trials+1, dim);
delta = zeros(trials, dim);

for t=2:trials
    delta(t) = u .* eta .* (r(t)-w(t));
    w(t+1) = w(t) + delta(t);
end

w(isinf(w)) = 1;
w = w(2:end) + intcpt; 
