% Parameters
x = linspace(-5, 5, 1000);       % Domain
mu = 0;                          % Mean of Gaussian
sigma_vals = linspace(2, 0.5, 60); % Simulated attention narrowing
line_width = 6;                  % Line thickness
video_filename = 'attention_focus.mp4';

% Set up video writer
v = VideoWriter(video_filename, 'MPEG-4');
v.FrameRate = 10;
open(v);

% Create figure
fig = figure('Color', 'w', 'Position', [100, 100, 600, 400]);

for i = 1:length(sigma_vals)
    sigma = sigma_vals(i);
    y = 1/sigma.*exp(-((x - mu).^2) / (2 * sigma^2));  % Gaussian function

    y = y-(max(y)./2); % normalize by peak activation; 2 is a scaling factor

    % Plot
    clf
    plot(x, y, 'k-', 'LineWidth', line_width);
    axis tight
    ylim([-1.1 1.1])
    set(gca, 'Visible', 'off') % Remove axes and ticks

    % Capture frame
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
close(fig);

disp(['Video saved to ', video_filename]);

%%
% Parameters
x = linspace(-5, 5, 1000);         % Domain
mu = 0;                            % Mean of Gaussian
sigma_vals = linspace(2, 0.5, 60); % Simulated attention narrowing
line_width = 6;                    % Main line thickness
video_filename = 'attention_focus_trail.mp4';

% Color map (perceptually smooth)
cmap = turbo(length(sigma_vals));  % Choose 'turbo', 'parula', or other

% Set up video writer
v = VideoWriter(video_filename, 'MPEG-4');
v.FrameRate = 10;
open(v);

% Create figure
fig = figure('Color', 'w', 'Position', [100, 100, 600, 400]);

% Store previous curves for fading trail
y_history = zeros(length(sigma_vals)-1, length(x));

for i = 1:length(sigma_vals)
    sigma = sigma_vals(i);
    y = 1/sigma .* exp(-((x - mu).^2) / (2 * sigma^2));  % Gaussian function
    y = y - (max(y)/2); % normalize by peak activation
    
    % Store current y in history for next frames
    if i > 1
        y_history(i-1, :) = y;
    end
    
    % Plot
    clf
    hold on;

    % Draw past curves with fading alpha
    alpha_vals = linspace(0.05, 0.3, i-1); % Fade older curves more
    for j = 1:i-1
        plot(x, y_history(j, :), 'Color', [cmap(j,:) alpha_vals(j)], 'LineWidth', 2);
    end

    % Draw current curve in solid color
    plot(x, y, 'Color', cmap(i,:), 'LineWidth', line_width);

    axis tight
    ylim([-1.1 1.1])
    set(gca, 'Visible', 'off') % Remove axes and ticks

    % Capture frame
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
close(fig);

disp(['Video saved to ', video_filename]);

