%-------------------------------------------------------------------
function w = rescorlaWagner_one(alpha, r, noise)
% learn weights w based on inputs u and rewards r with learning rate eta

if ~iscolumn(r)
r = r';
end

trials = size(r,1); % establish number of trials
w = zeros(trials+1, 1);
delta = zeros(trials, 1);

for t=2:trials

    noisy = r(t) + randn() * noise;
    delta(t) = alpha .* (noisy-w(t));
    w(t+1) = w(t) + delta(t);
end

w(isinf(w)) = 1;
w = w(2:end); 
