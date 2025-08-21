% Parameters of Rescorla-Wagner Model
clear
alpha = 0.2;  % Learning rate (between 0 and 1)
nTrials = 90; % Number of trials
USvec = [ones(1,(round(nTrials/1.5))) zeros(1,(round(nTrials/3)))];
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
ylim([-0.3 lambda]);
yline(0, '--k');  % Baseline for prediction error


% Adjust axis properties for professional look
set(gca, 'LineWidth', 2, 'FontSize', 16, 'FontWeight', 'bold', 'Box', 'off', ...
    'XGrid', 'on', 'YGrid', 'on', 'TickDir', 'out', 'TickLength', [0.01 0.01]);

% Add label on right Y-axis for prediction error (red bars)
yl = ylim;  % current y-axis limits
xr = xlim;  % current x-axis limits

text(xr(2) + 1, mean(yl), 'prediction error  (red bars)', ...
     'Rotation', 90, 'HorizontalAlignment', 'center', ...
     'Color', [1 0 0], 'FontSize', 16, 'FontWeight', 'bold');


plotHandle = plot(1:nTrials, V, 'b', 'LineWidth', 2);
pause(1);

% Initialize movie structure
frames(nTrials) = struct('cdata', [], 'colormap', []);

frames(1) = getframe(gcf);

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
        xline(trial, '--g', 'LineWidth', 2);  % Dashed red line for US absence
    end
    
    % --- NEW: Add prediction error bar below x-axis ---
    % Position below the plot (e.g., from y = -0.05 to -0.05 - height)
    barHeight = deltaV;  % Can scale or normalize if needed
    if barHeight ~= 0
        barColor = [1 0 0]; % Red
        line([trial trial], [0, 0 - barHeight], ...
             'Color', barColor, 'LineWidth', 2);
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
