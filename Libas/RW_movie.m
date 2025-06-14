% Parameters of Rescorla-Wagner Model
alpha = 0.2;  % Learning rate (between 0 and 1)
nTrials = 100; % Number of trials
USvec = [ones(1,(roundnTrials/2)) zeros(1,(roundnTrials/2))];
tempunpaired = randperm(nTrials./2); unpaired = tempunpaired(1:10); 
USvec(unpaired) = 0; 
lambda = 1;   % Maximum associative strength (US presence)
V = zeros(1, nTrials);  % Associative strength initialized to 0

% Initialize figure for movie with larger size and margins adjusted
figure('Position', [100, 100, 700, 500]);
hold on;
title('Rescorla-Wagner Model: Learning Over Time', 'FontSize', 16, 'FontWeight', 'bold');
xlabel('Trial Number', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Associative Strength (V)', 'FontSize', 14, 'FontWeight', 'bold');
xlim([1 nTrials]);
ylim([0 lambda]);

% Adjust axis properties for professional look
set(gca, 'LineWidth', 2, 'FontSize', 16, 'FontWeight', 'bold', 'Box', 'off', ...
    'XGrid', 'on', 'YGrid', 'on', 'TickDir', 'out', 'TickLength', [0.01 0.01]);

plotHandle = plot(1:nTrials, V, 'b', 'LineWidth', 2);
pause(1);

% Initialize movie structure
frames(nTrials) = struct('cdata', [], 'colormap', []);

% Run the trials
for trial = 2:nTrials
    % Calculate prediction error
    deltaV = alpha * (USvec(trial) - V(trial-1)); 
    
    % Update associative strength
    V(trial) = V(trial-1) + deltaV;
    
    % Update plot for visualization
    set(plotHandle, 'YData', V);
    title(['Trial: ', num2str(trial), ' | Prediction Error: ', num2str(deltaV, '%.2f')], ...
        'FontSize', 18, 'FontWeight', 'bold');
    
    % Add a vertical line for trials where US is absent
    if USvec(trial) == 0
        xline(trial, '--r', 'LineWidth', 2);  % Dashed red line for US absence
    end
    
    % Capture the frame for the movie
    drawnow;  % Ensure plot updates before capturing frame
    frames(trial) = getframe(gcf);
    
    pause(0.1); % For smooth visualization
end

% Remove empty frames (in case any are uninitialized)
validFrames = frames(~cellfun(@isempty, {frames.cdata}));

% Create and save movie
v = VideoWriter('Rescorla_Wagner_alpha02.mp4', 'MPEG-4');  % Save as MP4
v.FrameRate = 6; % Frames per second

open(v);
writeVideo(v, validFrames);  % Write only the valid frames
close(v);

disp('Movie saved as "Rescorla_Wagner_AssociativeLearning_Improved.avi".');
