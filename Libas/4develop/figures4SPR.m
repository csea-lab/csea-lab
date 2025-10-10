%% --------------------------------------------------------------
%  1
% Brownian‑noise time series (blue) + log‑power spectrum (orange)
%  Larger fonts for PPT use
% --------------------------------------------------------------

clear; close all; clc;

% ---------- Parameters ----------
fs      = 1000;                 % sampling rate [Hz]
tEnd    = 5;                    % duration [s]
time    = (0:1/fs:tEnd-1/fs)';  % column vector, time axis
N       = numel(time);          % number of samples

% ---------- Generate Brownian noise ----------
white   = randn(N,1);            % zero‑mean white Gaussian noise
brown   = cumsum(white);         % Brownian (1/f) noise

% ---------- Compute single‑sided power spectrum ----------
X       = fft(brown);                       % full FFT
Xpos    = X(1:floor(N/2)+1);                % positive frequencies
faxis   = (0:floor(N/2))' * (fs/N);         % frequency axis (Hz)

% Power (magnitude squared) → dB
powerSpec = (abs(Xpos)/N).^2;                % linear power
powerSpec(2:end-1) = 2*powerSpec(2:end-1);   % single‑sided correction
logPower = 10*log10(powerSpec);              % dB scale

% ---------- Plot ----------
fig = figure('Units','normalized',...
             'Position',[0.2 0.2 0.5 0.38],...
             'Color','w');   % white background

% Use tiledlayout for two side‑by‑side panels
tl = tiledlayout(1,2,'TileSpacing','loose','Padding','loose');

% ----- Common font settings -----
baseFontSize   = 18;   % tick‑labels, axis labels, legend
titleFontSize  = 18;   % titles

% (1) Time‑domain signal -----------------------------------------
nexttile
plot(time, brown, 'LineWidth',2.5,'Color',[0 0.45 0.74]);   % blue
xlabel('Time (s)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Amplitude','FontWeight','bold','FontSize',baseFontSize);
title('Brownian noise (time domain)','FontWeight','bold','FontSize',titleFontSize);
grid on
set(gca,'XTick',0:1:tEnd,'FontSize',baseFontSize);
xlim([0 tEnd]);
ylim([-200 200])

% (2) Frequency‑domain: log‑power spectrum -----------------------
nexttile
plot(faxis, logPower, 'LineWidth',2.5,'Color',[0.85 0.33 0.10]); % orange
xlabel('Frequency (Hz)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Power (dB)','FontWeight','bold','FontSize',baseFontSize);
title('Log‑power spectrum','FontWeight','bold','FontSize',titleFontSize);
grid on
xlim([0 30]);                     % focus on low‑frequency 1/f region
set(gca,'XTick',0:5:30,'FontSize',baseFontSize);

% ----- Export (optional) -----
% Uncomment the line below to save a high‑resolution PNG ready for PowerPoint
% exportgraphics(fig,'Brownian_TimeSeries_LogPower_LargeFonts.png','Resolution',300);

% exportgraphics(fig,'EightBrownian_AvgLogPower_Square.png','Resolution',300);

%% --------------------------------------------------------------
% 2
%  Eight Brownian‑noise time series (blue shades) + average log‑power
%  spectrum (orange) – same layout & fonts as the original plot
% --------------------------------------------------------------
clear; close all; clc;

% ---------- Parameters ----------
fs      = 1000;                 % sampling rate [Hz]
tEnd    = 5;                    % duration [s]
time    = (0:1/fs:tEnd-1/fs)';  % column vector, time axis
N       = numel(time);          % number of samples
nSeries = 8;                    % how many Brownian traces to draw

% ---------- Generate nSeries Brownian noises ----------
brownSeries = zeros(N,nSeries);   % pre‑allocate
for k = 1:nSeries
    white          = randn(N,1);          % zero‑mean white noise
    brownSeries(:,k) = cumsum(white);    % Brownian (1/f) noise
end

% ---------- Compute single‑sided power spectra ----------
% Each column = power spectrum of one trace (linear units)
powerSpec = zeros(floor(N/2)+1, nSeries);
for k = 1:nSeries
    X      = fft(brownSeries(:,k));
    Xpos   = X(1:floor(N/2)+1);                 % positive frequencies
    P      = (abs(Xpos)/N).^2;                  % linear power
    P(2:end-1) = 2*P(2:end-1);                 % single‑sided correction
    powerSpec(:,k) = P;
end

% ---------- Average spectrum and convert to dB ----------
meanPowerLinear = mean(powerSpec,2);            % average in linear domain
logPowerMean    = 10*log10(meanPowerLinear);   % dB scale

% ---------- Frequency axis ----------
faxis = (0:floor(N/2))' * (fs/N);   % Hz

% ---------- Colour map for the 8 traces (light → dark blue) ----------
cmap = flipud([ linspace(0.4,0, nSeries)', ...   % R
                linspace(0.7,0.2, nSeries)', ... % G
                linspace(1,0.5, nSeries)' ]);   % B

% ---------- Plot ----------
fig = figure('Units','normalized', ...
             'Position',[0.2 0.2 0.5 0.38], ...   % same size as your original
             'Color','w');                     % white background

tl = tiledlayout(1,2,'TileSpacing','loose','Padding','loose');

% ----- Common font settings -----
baseFontSize  = 18;   % tick‑labels, axis labels, legend
titleFontSize = 18;   % titles

% ----- (1) Left panel – 8 Brownian traces -----
nexttile
hold on
for k = 1:nSeries
    plot(time, brownSeries(:,k), 'LineWidth',2.5, 'Color',cmap(k,:));
end
hold off
xlabel('Time (s)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Amplitude','FontWeight','bold','FontSize',baseFontSize);
title('Eight Brownian noise segments','FontWeight','bold','FontSize',titleFontSize);
grid on
set(gca,'XTick',0:1:tEnd,'FontSize',baseFontSize);
xlim([0 tEnd]);

% ----- (2) Right panel – average log‑power spectrum -----
nexttile
plot(faxis, logPowerMean, 'LineWidth',2.5, ...
     'Color',[0.85 0.33 0.10]);   % orange
xlabel('Frequency (Hz)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Power (dB)','FontWeight','bold','FontSize',baseFontSize);
title('Average log‑power spectrum','FontWeight','bold','FontSize',titleFontSize);
grid on
xlim([0 30]);                     % focus on low‑frequency 1/f region
set(gca,'XTick',0:5:30,'FontSize',baseFontSize);

% ----- Export (optional) -----
% Uncomment to save a high‑resolution PNG ready for PowerPoint
% exportgraphics(fig,'EightBrownian_AvgLogPower.png','Resolution',300);


% 
%% --------------------------------------------------------------
% 3 a little alpha
%  Eight Brownian‑noise time series (blue shades) + average log‑power
%  spectrum (orange) – same layout & fonts as the original plot
% --------------------------------------------------------------
clear; close all; clc;

% ---------- Parameters ----------
fs      = 1000;                 % sampling rate [Hz]
tEnd    = 4;                    % duration [s]
time    = (0:1/fs:tEnd-1/fs)';  % column vector, time axis
N       = numel(time);          % number of samples
nSeries = 30;                    % how many Brownian traces to draw

% ---------- Generate nSeries Brownian noises ----------
brownSeries = zeros(N,nSeries);   % pre‑allocate
for k = 1:nSeries
    white          = randn(N,1);          % zero‑mean white noise
    brownSeries(:,k) = cumsum(white);    % Brownian (1/f) noise
    brownSeries(:,k) = brownSeries(:,k) + 10* sin(2*pi*(10+(randn(1,1)*1.5))*time);
end

% ---------- Compute single‑sided power spectra ----------
% Each column = power spectrum of one trace (linear units)
powerSpec = zeros(floor(N/2)+1, nSeries);
for k = 1:nSeries
    X      = fft(brownSeries(:,k));
    Xpos   = X(1:floor(N/2)+1);                 % positive frequencies
    P      = (abs(Xpos)/N).^2;                  % linear power
    P(2:end-1) = 2*P(2:end-1);                 % single‑sided correction
    powerSpec(:,k) = P;
end

% ---------- Average spectrum and convert to dB ----------
meanPowerLinear = mean(powerSpec,2);            % average in linear domain
logPowerMean    = 10*log10(meanPowerLinear);   % dB scale

% ---------- Frequency axis ----------
faxis = (0:floor(N/2))' * (fs/N);   % Hz

% ---------- Colour map for the 8 traces (light → dark blue) ----------
cmap = flipud([ linspace(0.4,0, nSeries)', ...   % R
                linspace(0.7,0.2, nSeries)', ... % G
                linspace(1,0.5, nSeries)' ]);   % B

% ---------- Plot ----------
fig = figure('Units','normalized', ...
             'Position',[0.2 0.2 0.5 0.38], ...   % same size as your original
             'Color','w');                     % white background

tl = tiledlayout(1,2,'TileSpacing','loose','Padding','loose');

% ----- Common font settings -----
baseFontSize  = 18;   % tick‑labels, axis labels, legend
titleFontSize = 18;   % titles

% ----- (1) Left panel – 8 Brownian traces -----
nexttile
hold on
for k = 1:nSeries
    plot(time, brownSeries(:,k), 'LineWidth',2.5, 'Color',cmap(k,:));
end
hold off
xlabel('Time (s)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Amplitude','FontWeight','bold','FontSize',baseFontSize);
title('Thirty Brownian noise segments','FontWeight','bold','FontSize',titleFontSize);
grid on
set(gca,'XTick',0:1:tEnd,'FontSize',baseFontSize);
xlim([0 tEnd]);

% ----- (2) Right panel – average log‑power spectrum -----
nexttile
plot(faxis, logPowerMean, 'LineWidth',2.5, ...
     'Color',[0.85 0.33 0.10]);   % orange
xlabel('Frequency (Hz)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Power (dB)','FontWeight','bold','FontSize',baseFontSize);
title('Average log‑power spectrum','FontWeight','bold','FontSize',titleFontSize);
grid on
xlim([0 30]);                     % focus on low‑frequency 1/f region
set(gca,'XTick',0:5:30,'FontSize',baseFontSize);

% ----- Export (optional) -----
% Uncomment to save a high‑resolution PNG ready for PowerPoint
% exportgraphics(fig,'EightBrownian_AvgLogPower.png','Resolution',300);

%% --------------------------------------------------------------
% 4 transients
%  Eight Brownian‑noise time series (blue shades) + average log‑power
%  spectrum (orange) – same layout & fonts as the original plot
% --------------------------------------------------------------
clear; close all; clc;

% ---------- Parameters ----------
fs      = 1000;                 % sampling rate [Hz]
tEnd    = 5;                    % duration [s]
time    = (0:1/fs:tEnd-1/fs)';  % column vector, time axis
N       = numel(time);          % number of samples
nSeries = 8;                    % how many Brownian traces to draw

% ---------- Generate nSeries Brownian noises ----------
brownSeries = zeros(N,nSeries);   % pre‑allocate
for k = 1:nSeries
    startvec = randperm(4000,1); 
    white          = randn(N,1);          % zero‑mean white noise
    brownSeries(:,k) = cumsum(white);    % Brownian (1/f) noise
    brownSeries(startvec:startvec+174,k) = brownSeries(startvec:startvec+174,k)+30*sin(2*pi*10*[0:1/fs:0.174]');
end

% ---------- Compute single‑sided power spectra ----------
% Each column = power spectrum of one trace (linear units)
powerSpec = zeros(floor(N/2)+1, nSeries);
for k = 1:nSeries
    X      = fft(brownSeries(:,k));
    Xpos   = X(1:floor(N/2)+1);                 % positive frequencies
    P      = (abs(Xpos)/N).^2;                  % linear power
    P(2:end-1) = 2*P(2:end-1);                 % single‑sided correction
    powerSpec(:,k) = P;
end

% ---------- Average spectrum and convert to dB ----------
meanPowerLinear = mean(powerSpec,2);            % average in linear domain
logPowerMean    = 10*log10(meanPowerLinear);   % dB scale

% ---------- Frequency axis ----------
faxis = (0:floor(N/2))' * (fs/N);   % Hz

% ---------- Colour map for the 8 traces (light → dark blue) ----------
cmap = flipud([ linspace(0.4,0, nSeries)', ...   % R
                linspace(0.7,0.2, nSeries)', ... % G
                linspace(1,0.5, nSeries)' ]);   % B

% ---------- Plot ----------
fig = figure('Units','normalized', ...
             'Position',[0.2 0.2 0.5 0.38], ...   % same size as your original
             'Color','w');                     % white background

tl = tiledlayout(1,2,'TileSpacing','loose','Padding','loose');

% ----- Common font settings -----
baseFontSize  = 18;   % tick‑labels, axis labels, legend
titleFontSize = 18;   % titles

% ----- (1) Left panel – 8 Brownian traces -----
nexttile
hold on
for k = 1:nSeries
    plot(time, brownSeries(:,k), 'LineWidth',2.5, 'Color',cmap(k,:));
end
hold off
xlabel('Time (s)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Amplitude','FontWeight','bold','FontSize',baseFontSize);
title('Eight Brownian noise segments','FontWeight','bold','FontSize',titleFontSize);
grid on
set(gca,'XTick',0:1:tEnd,'FontSize',baseFontSize);
xlim([0 tEnd]);

% ----- (2) Right panel – average log‑power spectrum -----
nexttile
plot(faxis, logPowerMean, 'LineWidth',2.5, ...
     'Color',[0.85 0.33 0.10]);   % orange
xlabel('Frequency (Hz)','FontWeight','bold','FontSize',baseFontSize);
ylabel('Power (dB)','FontWeight','bold','FontSize',baseFontSize);
title('Average log‑power spectrum','FontWeight','bold','FontSize',titleFontSize);
grid on
xlim([0 30]);                     % focus on low‑frequency 1/f region
set(gca,'XTick',0:5:30,'FontSize',baseFontSize);

% ----- Export (optional) -----
% Uncomment to save a high‑resolution PNG ready for PowerPoint
% exportgraphics(fig,'EightBrownian_AvgLogPower.png','Resolution',300);


