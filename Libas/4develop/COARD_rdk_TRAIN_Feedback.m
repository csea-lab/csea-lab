function COARD_rdk_TRAIN_Feedback(subNo)
%
% 1. %%%%%% set the settings for keyb and clock, same for each experiment
clc;
if ~isempty(instrfind), fclose(instrfind); end
rng('shuffle'); % reseed the random-number generator for each expt.
Screen('Preference', 'SkipSyncTests', 0)

% init keyboard responses (caps doesn't matter)
advancestudytrial=KbName('n');

resp = [];

% files
datafilename = strcat('CO_train_rdk_',num2str(subNo),'.dat'); % name of data file to write to

% check for existing file (except for subject numbers > 99)
if subNo<99 && fopen(datafilename, 'rt')~=-1
    error('data files exist!');
else
    datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing
end


% 3. %%%%%% in the try, end, catch loop, program the experiment per se,
% with the presentation and such. start with AssertOpenGL;handle screens;
% text, and cursors

nframes     = 1000; % number of animation frames in loop
mon_width   = 39;   % horizontal dimension of viewable screen (cm)
v_dist      = 60;   % viewing distance (cm)
dot_speed   = 7;    % dot speed (deg/sec)
ndots       = 150; % number of dots
max_d       = 5.5;   % maximum radius of  annulus (degrees)
min_d       = .5;    % minumum
dot_w       = 0.35;  % width of dot (deg)
fix_r       = 0.2; % radius of fixation point (deg)
f_kill      = 0.01; % fraction of dots to kill each frame (limited lifetime)
differentcolors =0; % Use a different color for each point if == 1. Use common color white if == 0.
differentsizes = 0; % Use different sizes for each point if >= 1. Use one common size if == 0.
waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh.

% get screen
screens=Screen('Screens');
screenNumber=max(screens);

% Open a double buffered fullscreen window and draw a gray background
% to front and back buffers:
[w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
[centerX, centerY] = RectCenter(wRect);
center = [centerX, centerY];

% returns as default the mean gray value of screen
black=BlackIndex(screenNumber);
white = WhiteIndex(w);

% set Text properties (all Screen functions must be called after screen
% init
Screen('TextSize', w, 20);

% set priority - also set after Screen init
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

HideCursor(0,0)

Screen('FillRect',w, black);
Screen('Flip', w);

ppd = pi * (wRect(3)-wRect(1)) / atan(mon_width/v_dist/2) / 360;
fix_cord = [center-fix_r*ppd center+fix_r*ppd];


try
    AssertOpenGL;
  
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    %     [center(1), center(2)] = RectCenter(wRect);
    fps=Screen('FrameRate',w);      % frames per second
    ifi=Screen('GetFlipInterval', w);
    if fps==0
        fps=1/ifi;
    end

    
    % 4. %%%%   experiment proper
    % write message to subject
    Screen('DrawText', w, 'Please press mouse key to start ...', 10, 10, 255);
    Screen('Flip', w); % show text
    
    % wait for mouse press ( no GetClicks  :(  )
    buttons=0;
    while ~any(buttons) % wait for press
        [x,y,buttons] = GetMouse;
        % Wait 10 ms before checking the mouse again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.01);
    end
    
    % clear screen
    Screen('Flip', w);
    
    % wait a bit before starting trial
    WaitSecs(2);
    
    % Make conditions and randomization
    tempvector = repmat([ones(1,15) .*1 ones(1,15) .*2], 1, 4);
    ntrials = length(tempvector);
    
    
    stimdir = ('/home/psychlab-stim/Desktop/Matlab_files/exp_stimuli/COARD_rdk/');
    filemat = dir([stimdir '*.jpg']); %reads in pics from folder
    size(filemat, 1) %gets the size of the folder
    newindices = randperm(size(filemat,1));  %creates a new index the same size as the original folder
    filemat_perm = filemat(newindices,:); %creates a random permutation of pics -> new pic order
    convector = [2 2 2 1 2 1 1 2 1 2 2 1 ]; 

    %brownian noise
    imdatanoise_temp = spatialPattern([800 800], -2).*2500+128;
    % make the noise round
    [x1,y1] = meshgrid(-400:399, -400:399);
    apert =(x1.^2 + y1.^2) < 90000;
    imdatanoise = imdatanoise_temp .* apert; 
    % make texture of noise picture
    texnoise=Screen('MakeTexture', w, imdatanoise);
    tRectnoise=Screen('Rect', texnoise);
    
    %%%%% trial loop
    for trial = 1:10
        
                
        % always show fixation cross during ITI (can change
        % ITI length here)
        Screen('FillOval', w, uint8(white), fix_cord) %fills/colors fixation dot in center
        Screen('Flip', w);
        WaitSecs (rand(1,1) + 2)
        
        
        if convector(trial) == 1 % it is not a target
            
            targonset = 0;            
          
            
            ppd = pi * (wRect(3)-wRect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
            pfs = dot_speed * ppd / fps;                            % dot speed (pixels/frame)
            s = dot_w * ppd;                                        % dot size (pixels)
            fix_cord = [center-fix_r*ppd center+fix_r*ppd];
            
            rmax = max_d * ppd;	% maximum radius of annulus (pixels from center)
            rmin = min_d * ppd; % minimum
            r = rmax * sqrt(rand(ndots,1));	% r
            r(r<rmin) = rmin;
            t = 2*pi*rand(ndots,1);                     % theta polar coordinate
            cs = [cos(t), sin(t)];
            xy = [r r] .* cs;   % dot positions in Cartesian coordinates (pixels from center)
            
            xymatrix = xy';
            
            % trial always starts with noisy picture
            
            Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
            Screen('FillOval', w, uint8(white), fix_cord) %fills/colors fixation dot in center
            
            Screen('Flip', w);
            WaitSecs(.5)
            
            
            % Create a vector with different colors for each single dot, if
            % requested:
            if (differentcolors==1)
                colvect = uint8(round(rand(3,ndots)*255));
            else
                %later change the color maybe to yellow using
                %RGB vector
                colvect= [255 255 0];
            end
            
            % Create a vector with different point sizes for each single dot, if
            % requested:
            if (differentsizes>0)
                s=(1+rand(1, ndots)*(differentsizes-1))*s;
            end
              

            tic % measure trial length

            for flickindex = 1:75
                            
                % draw pic plus dots
                if flickindex < 26
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
                    
                else
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect)); %shows pic
                end
                Screen('DrawDots', w, xymatrix, s, colvect, center,1) %draws dots at random positions
                Screen('FillOval', w, uint8(white), fix_cord) %fills/colors fixation dot in center
                [VBLTimestamp startrt]=Screen('Flip', w);
                WaitSecs(.05)
                
                % Show pic without dots
                
                if flickindex < 26
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
                else
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect)); %shows pic
                end
                
                Screen('FillOval', w, uint8(white), fix_cord)
                
                % Show stimulus on screen & record onset time
                [VBLTimestamp startrt]=Screen('Flip', w); %shows cow when screen flips to black, dots "off"
                %show texture here
                WaitSecs(.05)
                
                xy= [xymatrix(1,:) + rafz(rand(size(xymatrix(1,:)))-.5).*5; xymatrix(2,:) + rafz(rand(size(xymatrix(2,:)))-.5).*5]';
                
                [t,r] = cart2pol(xy(:,1), xy(:,2));
                
                % check to see which dots have gone beyond the borders of the annuli
                
                r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	% dots to reposition
                nout = length(r_out);
                
                if nout
                    
                    % choose new coordinates
                    
                    r(r_out) = rmax * sqrt(rand(nout,1));
                    r(r<rmin) = rmin;
                    t(r_out) = 2*pi*(rand(nout,1));
                    
                    % now convert the polar coordinates to Cartesian
                    
                    cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                    xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                    
                end
                
                
                xymatrix = transpose(xy);
                
            end %flicker loop

            trialdur = toc; 
                      
            %clear screen
            Screen('Flip', w);
            
            
        elseif convector(trial) == 2 % if it is a target
            
            % dtermine random onset of the 4 target
            % flickers
            temp1 = randperm(45); targonset = temp1(1)+15;
            coherDuration = 18;
            
            % detrmine the points that move
            % coherently % does not yet work ....@@@
            temp2 = randperm(150); subset1 = temp2(1:75); subset2= temp2(76:150);
            
            % determine the direction of the targets
            factor1 = rafz(rand(1,1)-.5).*6;
            factor2 = rafz(rand(1,1)-.5).*6;
            
            ppd = pi * (wRect(3)-wRect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
            pfs = dot_speed * ppd / fps;                            % dot speed (pixels/frame)
            s = dot_w * ppd;                                        % dot size (pixels)
            fix_cord = [center-fix_r*ppd center+fix_r*ppd];
            
            rmax = max_d * ppd;	% maximum radius of annulus (pixels from center)
            rmin = min_d * ppd; % minimum
            r = rmax * sqrt(rand(ndots,1));	% r
            r(r<rmin) = rmin;
            t = 2*pi*rand(ndots,1);                     % theta polar coordinate
            cs = [cos(t), sin(t)];
            xy = [r r] .* cs;   % dot positions in Cartesian coordinates (pixels from center)
            
            xymatrix = xy';
            
            % trial always starts with noisy picture
            
            Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
            Screen('FillOval', w, uint8(white), fix_cord) %fills/colors fixation dot in center
            
            Screen('Flip', w);
            WaitSecs(.5)
            
            
            % Create a vector with different colors for each single dot, if
            % requested:
            if (differentcolors==1)
                colvect = uint8(round(rand(3,ndots)*255));
            else
                colvect= [255 255 0];
            end
         
            
            tic % measure time
            
            for flickindex = 1:75
                
                % draw pic plus dots
                if flickindex < 26
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
                else
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect)); %shows pic
                end
                Screen('DrawDots', w, xymatrix, s, colvect, center,1) %draws dots at random positions
                Screen('FillOval', w, uint8(white), fix_cord) %fills/colors fixation dot in center
                [VBLTimestamp startrt]=Screen('Flip', w);
                WaitSecs(.05)
                
                % Show pic without dots
                
                if flickindex < 26
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect));
                else
                    Screen('DrawTexture', w, texnoise, [], CenterRect(tRectnoise, wRect)); %shows pic
                end
                
                Screen('FillOval', w, uint8(white), fix_cord)
                
                % Show stimulus on screen & record onset time
                [VBLTimestamp startrt]=Screen('Flip', w); %shows cow when screen flips to black, dots "off"
                %show texture here
                WaitSecs(.05)
                
                
                if ismember(flickindex, targonset:targonset+coherDuration)
                    xy = [xymatrix(1,:) + factor1; xymatrix(2,:) + factor2]';
                    
                else
                    xy= [xymatrix(1,:) + rafz(rand(size(xymatrix(1,:)))-.5).*10; xymatrix(2,:) + rafz(rand(size(xymatrix(2,:)))-.5).*10]';
                end
                
                [t,r] = cart2pol(xy(:,1), xy(:,2));
                
                % check to see which dots have gone beyond the borders of the annuli
                
                r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	% dots to reposition
                nout = length(r_out);
                
                if nout
                    
                    % choose new coordinates
                    
                    r(r_out) = rmax * sqrt(rand(nout,1));
                    r(r<rmin) = rmin;
                    t(r_out) = 2*pi*(rand(nout,1));
                    
                    % now convert the polar coordinates to Cartesian
                    
                    cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                    xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                    
                end
                
                
                xymatrix = transpose(xy);
                
            end
            
            trialdur = toc; 
            
            %clear screen
            Screen('Flip', w);
            
        end % if condition
        

        %% 
        [resp] = promptMessage(w);

            fprintf(datafilepointer,'%i %i %i %i %i %i %i\n', ...
                subNo, ...
                trial, ...
                startrt,...
                convector(trial),...
                targonset, ...
                resp,...
                trialdur);

    end % trials
    
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
    
catch
    
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
    

end

%%
function [resp] = promptMessage(w)


questionText = ['Were the dots moving together in the same direction? \n\n\n'...
    'Left mouse button is Yes, an right mouse button is No']

DrawFormattedText(w, questionText, 'center', 'center', [255 255 255]);
Screen('Flip', w); % Shows text line

buttons=0;
while ~any(buttons) % wait for press
[x,y,buttons] = GetMouse;
% Wait 10 ms before checking the mouse again to prevent
% overload of the machine at elevated Priority()
WaitSecs(0.01);
end


resp = find(buttons==1);
showFeedback(w, convector, buttons, trial);
end 
end
%%
% Call showFeedback function
function showFeedback(w, convector, buttons, trial)
correctflag = false;
if convector(trial) == 1 && buttons(1) ==1
    correctflag = 0;
elseif convector(trial) == 1 && buttons(3) ==1
    correctflag = 1;
end

if convector(trial) == 2 && buttons(1)==1 
    correctflag = 1;
elseif convector(trial) == 2 && buttons(3) ==1
    correctflag = 0;
end

if correctflag==1
    DrawFormattedText(w, 'Correct response', 'center', 'center', [0 204 102]);
else
    DrawFormattedText(w, 'Incorrect response', 'center', 'center', [255 0 0]);
end

Screen('Flip', w);
WaitSecs(1);
end
