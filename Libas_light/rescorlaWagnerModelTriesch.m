function w = rescorlaWagnerModelAK(u, r, eta)
% learn weights w based on inputs u and rewards r with learning rate
% epsilon
trials = size(r,1); % establish number of trials
dim = size(u,2); % establish number of feature dimensions
w = zeros(trials+1, dim);

for t=1:trials
    delta = r(t)-w(t,:)*u(t,:)';
    w(t+1,:) = w(t,:) + eta*delta*u(t,:);
end

w = w(2:end, :); 