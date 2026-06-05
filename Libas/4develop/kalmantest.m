%%
u = rand(1,500); 
y = u + 0.1*randn(size(u));

% Number of time points
T = length(u);

% Model parameters
A = 0.95;     % state persistence
B = 0.5;      % stimulus influence
C = 1.0;      % observation mapping

Q = 0.01;     % process noise variance
R = 0.1;      % observation noise variance

% Preallocate
x_hat = zeros(1,T);      % state estimate
P = zeros(1,T);          % uncertainty estimate

% Initial values
x_hat(1) = 0;
P(1) = 1;

for t = 2:T

    % ---- Prediction step ----
    x_pred = A * x_hat(t-1) + B * u(t);
    P_pred = A * P(t-1) * A' + Q;

    % ---- Update step ----
    K = P_pred * C' / (C * P_pred * C' + R);  % Kalman gain

    innovation(t) = y(t) - C * x_pred;           % prediction error
    x_hat(t) = x_pred + K * innovation(t);

    P(t) = (1 - K * C) * P_pred;

end
%%