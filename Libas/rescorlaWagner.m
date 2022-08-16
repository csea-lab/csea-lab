opfunction rescorlaWagner
% Demonstration of the Rescorla Wagner (1972) model.
%
% Jochen Triesch, November 2006

trials = 100;
eta = 0.1;

% %-------------------------------------------------------------------
% % conditioning, extinction, partial reinforcement
% figure(1)
% u = ones(trials,1);
% r = [ones(trials/2,1); zeros(trials/2,1)];
% w = rescorlaWagnerLearn(u, r, eta);
% plot(0:trials,w);
% xlabel('trial number');
% ylabel('weight');
% title('conditioning, extinction, partial reinforcement');
% hold on
% 
% p_reward = 0.5;
% r = rand(trials,1)<p_reward;
% w = rescorlaWagnerLearn(u, r, eta);
% plot(0:trials,w, 'g');
% legend('conditioning/extinction', 'partial reinforcement');
% hold off

%-------------------------------------------------------------------
% blocking
figure(2)
u1 = ones(trials,1);
u2 = [ zeros(trials/2,1); ones(trials/2,1) ];
u = [u1 u2];
r = ones(trials,1);
w = rescorlaWagnerLearn(u, r, eta);
plot(0:trials,w(:,1),'b', 0:trials,w(:,2),'r');
xlabel('trial number');
ylabel('weight');
title('blocking');
legend('w_1', 'w_2');
% 
% %-------------------------------------------------------------------
% % inhibitory conditioning
% figure(3)
% u1 = ones(trials,1);
% u2 = repmat([0; 1], trials/2, 1);
% u = [u1 u2];
% r = repmat([1; 0], trials/2, 1);
% w = rescorlaWagnerLearn(u, r, eta);
% plot(0:trials,w(:,1),'b', 0:trials,w(:,2),'r');
% xlabel('trial number');
% ylabel('weight');
% title('inhibitory conditioning');
% legend('w_1', 'w_2');
% 
%-------------------------------------------------------------------
function w = rescorlaWagnerLearn(u, r, eta)
% learn weights w based on inputs u and rewards r with learning rate
% epsilon
trials = size(r,1); % establish number of trials
dim = size(u,2); % establish number of feature dimensions
w = zeros(trials+1, dim);
for t=1:trials
    delta = r(t)-w(t,:)*u(t,:)';
    w(t+1,:) = w(t,:) + eta*delta*u(t,:);
end