%-------------------------------------------------------------------
function [w, delta] = rescorlaWagnerLearnMod(params, r)
% modified RW model
% learn weights w based on inputs u and rewards r with learning rate eta
% does not work with u that is not 1 or 0; but could be extended for more
% feature dims; use rescorlaWagnerLearnOrig when in doubt

alpha = params(1);
u = params(2).*ones(size(r));

trials = size(r,1); % establish number of trials
w = zeros(trials+1, 1);

for t=1:trials
    delta(t) = r(t)-w(t);
    w(t+1) = w(t) + alpha*delta(t)*u(t);
end

w = w(2:end);

