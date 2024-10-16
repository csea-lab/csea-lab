%-------------------------------------------------------------------
function w = PearceHallModIntcpt(params, r)
% modified RW model
% learn weights w based on inputs u and rewards r with learning rate eta
% does not work with u that is not 1 or 0; but could be extended for more
% feature dims; use rescorlaWagnerLearnOrig when in doubt

eta = params(1);
u = params(2).*ones(size(r));
intcpt = params(3); 

trials = size(r,1); % establish number of trials
dim = size(u,2); % establish number of feature dimensions
w = zeros(trials+1, dim);
for t=1:trials
    if t >1, eta = abs(r(t)-w(t)); end % after first trial, eta is learned from data
    delta = r(t)-w(t,:)*u(t,:)';
    w(t+1,:) = w(t,:) + eta*delta*u(t,:) + intcpt;    
end

w = w(2:end);

