% Parameters for DoG
sigma1 = 2;  
sigma2 = 4;
k = 0.5;

size = 3 * sigma2;
[x, y] = meshgrid(linspace(-size, size, 31), linspace(-size, size, 31));
G1 = exp(-(x.^2 + y.^2) / (2*sigma1^2));
G2 = exp(-(x.^2 + y.^2) / (2*sigma2^2));
DoG = G1 - k*G2; 

% Create figure
fig = figure('Color','w','Position',[100 100 600 600]);
h = surf(x, y, DoG, 'EdgeColor','none'); % no gridlines
colormap parula
shading interp
axis off
set(gca,'XColor','none','YColor','none','ZColor','none')
set(gca,'Color','w');
set(gcf,'InvertHardcopy','off') % prevents white-on-white inversion for movie

% Set up video writer
v = VideoWriter('dog_rotation.mp4','MPEG-4');
v.Quality = 95;
v.FrameRate = 30;
open(v);

% Movie loop
nFrames = 300; % 10 sec at 30 fps
for i = 1:nFrames
    % Animation: rotate around z, and change elevation for top/side effect
    az = mod(i*1.2, 360);
    if i <= nFrames/2
        el = 36 - (i-1)*(36-90)/(nFrames/2-1); % Side to top
    else
        el = 90 - (i-nFrames/2)*(90-12)/(nFrames/2-1); % Top to low side
    end
    view(az, el);
    drawnow;
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
disp('Movie saved as dog_rotation.mp4');

%%
% Define parameters
[x, y] = meshgrid(-50:50, -50:50);
sigma1 = 10; % Standard deviation for first Gaussian
sigma2 = 15; % Standard deviation for second Gaussian
k = 0.8;

% Create zero-initialized surface for initial frames
Z = zeros(size(x));

% Create Gaussian functions
G1 = exp(-(x.^2 + y.^2) / (2*sigma1^2));
G2 = exp(-(x.^2 + y.^2) / (2*sigma2^2));
DoG = G1 - k*G2; 

figure

% Create movie frames
frames = cell(1, 50);
for i = 1:50
    frames{i} = surf(X, Y, Z + i/50 * DoG, 'EdgeColor', 'none');
    view(0, 90); % Top view
    drawnow;
end


% Panning out and showing from a 45 degree angle

 for j = 1:80
        view(j, 90-j);
        drawnow;
 end


 %%
 clear
 % Define parameters
[x, y] = meshgrid(-50:50, -50:50);
sigma1 = 10; % Standard deviation for the first Gaussian
sigma2 = 15; % Standard deviation for the second Gaussian
k = 0.8;

% Create zero-initialized surface for initial frames
Z = zeros(size(x));

% Create Gaussian functions
G1 = exp(-(x.^2 + y.^2) / (2*sigma1^2));
G2 = exp(-(x.^2 + y.^2) / (2*sigma2^2));
DoG = G1 - k*G2;

% Set up video writer
v = VideoWriter('DoG_condispas_evolve', 'MPEG-4');
open(v);

figure('Color','white');
colormap parula
shading interp
axis off
set(gca,'XColor','none','YColor','none','ZColor','none')
set(gca,'Color','w');
set(gcf,'InvertHardcopy','off') % prevents white-on-white inversion for movie


% Create movie frames
for i = 1:50
    surf(x, y, Z + i/50 * DoG, 'EdgeColor', 'none');
    clim([min(min(DoG)), max(max(DoG))])
    colormap(jet); % Set colormap
    view(0, 90); % Top view
    shading interp; % Interpolated shading
    axis off
    set(gca,'XColor','none','YColor','none','ZColor','none')
    set(gca,'Color','w');


    drawnow;
    
    % Capture frame for video
    frame = getframe(gcf);
    writeVideo(v, frame);
end

% Pan out and show from a 45-degree angle
for j = 1:80
    view(j, 90-j);

    axis off
    set(gca,'XColor','none','YColor','none','ZColor','none')
    set(gca,'Color','w');
    drawnow;
    
    % Capture frame for video
    frame = getframe(gcf);
    writeVideo(v, frame);
end

% Close video writer
close(v);


%% sample and fit empirical data

[x, y] = meshgrid(-10:10, -10:10);
sigma1 = 3; % Standard deviation for the first Gaussian
sigma2 = 4; % Standard deviation for the second Gaussian
k = 0.8;

% Create zero-initialized surface for initial frames
z = zeros(size(x));

for index = 1:200
    a1 = max(abs(round(randn.*2)+11), 1)
    a2 = max(abs(round(randn.*2)+11),1)
    z(min(a1, 21), min(a2,21)) = z(min(a1, 21), min(a2,21))+ rand(1,1); 
end

for index = 1:700
    b1 = max(abs(round(randn.*4)+2), 1);
    b2 = max(abs(round(randn.*4)+2),1);
    b3  = 21-max(abs(round(randn.*4)+2),1); 
    b4 = 21-max(abs(round(randn.*4)+2),1); 
    vec = [b1 b2 b3 b4]; 
    nums1 = vec(randperm(4,1)) 
    nums2 = vec(randperm(4,1)) 
    z((nums1), (nums2)) = z((nums1), (nums2))- rand(1,1); 
end

% Create Gaussian functions
G1 = exp(-(x.^2 + y.^2) / (2*sigma1^2));
G2 = exp(-(x.^2 + y.^2) / (2*sigma2^2));
DoG = G1 - k*G2;



[xq, yq] = meshgrid(-10:0.1:10, -10:0.1:10);

zq = interp2(x, y, z, xq, yq, 'spline');

figure;
colormap('jet');
imagesc(zq);
colorbar;