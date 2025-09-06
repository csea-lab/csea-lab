%% SSVEP Flicker Movie Demo with Circular Yellow Dots & Limited Lifetime
% Generates an .mp4 movie with RDK dots (yellow) using limited dot lifetime

clear; clc;

%% Parameters
bgFile = 'IMG_2744.jpeg';   % replace with your file
nDots = 200;                % number of dots
dotRadius = 20;             % radius in px
apRadius = 1100;            % aperture radius in px
dotStep = 8;                % step size per frame
flickerHz = 6;              % flicker frequency (Hz)
fps = 30;                   % movie frame rate
duration = 6;               % seconds
outFile = 'ssvep_demo_lifetime.mp4';

dotLifetime = round(fps * 0.5);  % average lifetime ~0.5 sec (tunable)

%% Prepare background
bg = imread(bgFile);
[bgH, bgW, ~] = size(bg);
centerX = bgW/2;
centerY = bgH/2;

[x1,y1] = meshgrid(-floor(centerX):floor(centerX)-1, -floor(centerY):floor(centerY)-1);

apert =(x1.^2 + y1.^2) < (apRadius + dotRadius).^2; 
for chanx = 1:3
bg(:, :, chanx) = double(bg(:, :, chanx)) .*apert;
end

%% Initialize dot positions
theta = rand(nDots,1) * 2*pi;
r = apRadius * sqrt(rand(nDots,1));
dotX = r .* cos(theta);
dotY = r .* sin(theta);

%% Initialize dot lifetimes
lifetimes = randi(dotLifetime, nDots, 1);

%% Video writer
v = VideoWriter(outFile, 'MPEG-4');
v.FrameRate = fps;
open(v);

%% Frame loop
nFrames = duration * fps;
framesPerCycle = round(fps / flickerHz);
halfCycle = round(framesPerCycle/2);

cohStart = round(2 * fps);    % coherence onset
cohEnd   = round(3 * fps);    % coherence offset
cohDir   = [1 1] / sqrt(2);   % up-right unit vector

for f = 1:nFrames
    frame = bg; % start with background

    % --- Update positions ---
    if f >= cohStart && f <= cohEnd
        % 100% coherent motion: all move up-right
        dotX = dotX + cohDir(1) * dotStep;
        dotY = dotY + cohDir(2) * dotStep;
    else
        % Random walk
        dotX = dotX + randn(nDots,1) * dotStep;
        dotY = dotY + randn(nDots,1) * dotStep;
    end

    % Decrement lifetimes
    lifetimes = lifetimes - 1;

    % Respawn expired dots anywhere in aperture
    expired = lifetimes <= 0;
    nExpired = sum(expired);
    if nExpired > 0
        theta = rand(nExpired,1) * 2*pi;
        r = apRadius * sqrt(rand(nExpired,1));
        dotX(expired) = r .* cos(theta);
        dotY(expired) = r .* sin(theta);
        lifetimes(expired) = randi(dotLifetime, nExpired, 1);
    end

    % Enforce aperture (clip to circle)
    r = sqrt(dotX.^2 + dotY.^2);
    outside = r > apRadius;
    if any(outside)
        % Rewrap outside dots back inside randomly
        theta = rand(sum(outside),1) * 2*pi;
        r = apRadius * sqrt(rand(sum(outside),1));
        dotX(outside) = r .* cos(theta);
        dotY(outside) = r .* sin(theta);
        lifetimes(outside) = randi(dotLifetime, sum(outside), 1);
    end

    % --- Flicker: on/off depending on cycle ---
    flickerOn = mod(f, framesPerCycle) < halfCycle;

    if flickerOn
        for d = 1:nDots
            % Center pixel coords for this dot
            cx = round(centerX + dotX(d));
            cy = round(centerY + dotY(d));

            % Bounding box
            xIdx = max(1,cx-dotRadius) : min(bgW, cx+dotRadius);
            yIdx = max(1,cy-dotRadius) : min(bgH, cy+dotRadius);

            % Draw circular mask
            [xx, yy] = meshgrid(xIdx, yIdx);
            mask = (xx-cx).^2 + (yy-cy).^2 <= dotRadius^2;

            % Apply yellow (R=255,G=255,B=0)
            for ch = 1:3
                tmp = frame(yIdx, xIdx, ch);
                if ch == 1 || ch == 2
                    tmp(mask) = 255;
                else
                    tmp(mask) = 0;
                end
                frame(yIdx, xIdx, ch) = tmp;
            end
        end
    end

    % Write frame
    writeVideo(v, frame);
end

close(v);
disp(['Movie written to ', outFile]);
