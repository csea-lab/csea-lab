function condi_misty2015(subNo, isonum)


%%% PRE-SETTINGS %%%

clc;
rand('state', sum(100*clock));

% open serial port for trigger writing
 %    s3 = serial('COM3'); % on PC only
 %    fopen(s3)
%     s4 = serial('COM4'); % on PC only
%     fopen(s4)
%
 %   serialbreak(s4,1000); 
isonum;
% define frequency
    %durationpic = 0.076;  %%% make sure this is correct!!! aiming for 12Hz, to hit 83.333, not 75 (for 13.3Hz)
    durationpic = 0.576;
    
    puma = [];            %%% tic toc recording

% Define KeyPad/Response
    KbName('UnifyKeyNames');
    advancestudytrial = KbName('n');

% datfile and file labelling
    datafilename = strcat('condi_misty2015_',num2str(subNo),'.dat'); % name of data file to write to

    % Prevent accidentally overwriting data (except for subject numbers > 99)
    if subNo < 99 && fopen(datafilename, 'rt') ~= -1
        fclose('all');
        error('Result data file exists!');
    else
        datafilepointer = fopen(datafilename, 'wt');
    end

%%% EXPERIMENT START %%%

try
    AssertOpenGL;
    
% Screen settings
    screens=Screen('Screens');
    screenNumber=max(screens);
    HideCursor;
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    gray = GrayIndex(screenNumber, 0.5019);
    inc = white-gray;
    [w, wRect] = Screen('OpenWindow', screenNumber, 0, [], 32);  %%% 0 was gray
    Screen('FillRect', w, gray);   %%%%  this was changed from gray to black
    Screen('Flip', w);
    Screen('TextSize', w, 24);
    
% Priority
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel)
    
% Read in files
    % Textures
     imdata_welcome = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\welcome.png');
     imdata_condi = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\conditime.png');
    
    % read startle sound
   [soundvec, fs] = wavread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\whitenoise.wav');
    usnoise = audioplayer(soundvec, 22000); 
    
    % make textures
    tex_welcome = Screen('MakeTexture', w, imdata_welcome);     % initial screen
    tRect_welcome = Screen('Rect', tex_welcome);

    tex_cond = Screen('MakeTexture', w, imdata_condi);
    tRect_cond = Screen('Rect', tex_cond);
    
    
    %make magno Gabors
    
       [x,y] = meshgrid(-200:199, -200:199);
        
        m1 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(45*pi/180)*(2*pi*0.02)*x + sin(45*pi/180)*(2*pi*0.02)*y));
        m2 = m1.*-1;
        
        grating1 = gray+inc*((40./100)*m1);     
        grating2 = gray+inc*((40./100)*m2);        
 
        tex_grating1 = Screen('MakeTexture', w, grating1);  
        tex_grating2 = Screen('MakeTexture', w, grating2);
        
        tRect_1 = Screen('Rect',tex_grating1); 
        
   % make parvo gabors
   
  squarewav1 = [ones(400,20), zeros(400,20)]; b1 = repmat(squarewav1, 1, 10);
  squarewav2 = [zeros(400,20),ones(400,20)]; b2 = repmat(squarewav2, 1, 10);
  
  
  gaussi = exp(-((x/50).^4)-((y/50).^4));
  
  parvogratingred = (180-gray).*b1.*gaussi + gray;  % was 190
  parvogratinggreen = (isonum-gray).*b2.*gaussi + gray;
  
  grating3 =zeros([size(grating1), 3]);
  grating3(:, :, 1) = parvogratingred; grating3(:, :, 2) = parvogratinggreen; grating3(:, :, 3) = ones(400,400).* inc;  % originally these were both grating3; grating3(:,:,2) - (:,:,3); red green
       
   grating4 = zeros([size(grating2), 3]);
   grating4(:, :, 2) = parvogratingred; grating4(:, :, 1) = parvogratinggreen; grating4(:, :, 3) = ones(400,400).* inc; % originally these were both grating4; grating4(:,:,1) - (:,:,3) red green
    
   tex_grating3 = Screen('MakeTexture', w, grating3);  
   tex_grating4 = Screen('MakeTexture', w, grating4);
                 
%%% BEGIN EXPERIMENT %%%
%%%%%%%%%%%%%%%%%%%%%%%%

% Phase loop
    
    for phase = 1:3  % 150 trials
        if phase == 1   % the magno (1 or in phase 2 1 to 3) and the parvo are shown without noise
            ntrials = 18; % should be 18
            convector = [4,4,4,1,1,4,4,4,1,1,4,1,4,1,4,4,4,1];  % original vector is 1 1 4, changed to 4 4 4
        elseif phase == 2 % now we have 6 conditions, magno and parvo with no US, early US, late US, respectively
            ntrials = 120;
            convector = [3,2,5,6,5,3,2,5,6,5,6,1,2,6,2,4,3,1,5,5,6,3,6,3,5,6,5,2,6,6,2,4,5,3,3,1,2,1,2,4,4,4,3,5,6,4,5,4,6,5,3,2,2,2,4,2,3,2,3,3,2,1,6,4,1,4,5,4,1,5,6,6,5,5,3,1,4,1,1,4,1,1,3,2,1,4,2,3,1,1,4,1,6,2,3,1,1,6,2,4,5,5,5,2,6,4,6,1,3,6,5,3,1,3,4,2,3,4,6,4];
        elseif phase == 3
            ntrials = 12;
            convector = [1,4,1,4,4,1,1,4,1,1,4,4];
        end
        
        
    if phase == 1
        
        % welcome
        Screen('DrawTexture', w, tex_welcome, [], CenterRect(tRect_welcome, wRect))
        Screen('Flip', w)

        % wait for mouse press ( no GetClicks  :(  )
        buttons=0;
        while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse;
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
        end

        Screen('Flip', w);
    WaitSecs(3.000);
    end
    
% Trial/flicker loop

%%% Fixation cross
    Screen('TextSize', w, 22);
    DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
    Screen('Flip', w);
            
  
%%% All following trials  

        for trial = 1:ntrials

         %%% Conditioning un-instruction screen

            buttons = 0;
            pressed = 0;
            respvec = 0;
            responseRT = 0;
  
%%% Stimuli, flicker duration, and US occurance definitions

            flickdur = 42;
            us = 0;
            
            
                if convector(trial) == 2 || convector(trial) == 5
                    USflickindex = 12;
                elseif convector(trial) == 3 || convector(trial) == 6
                    USflickindex = 30;
                else
                    USflickindex = 0; 
                end
                            
                if phase == 2 && USflickindex == 12;  us = 1; % Acq CS+, where US occurs
                elseif phase == 2 && USflickindex == 30;  us = 1;
                else
                us = 0;
                end

          

%%% Fixation Cross
            
            Screen('TextSize', w, 22);
            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
            Screen('Flip', w);
        
            % Flicker loop
            waitsecs (.1)
            
            % determine which gratings to show % 
           
           if  convector(trial) < 4
               tex_end1 = tex_grating1;
                tex_end2 = tex_grating2;
            elseif convector(trial) > 3
                 tex_end1 = tex_grating3;
                tex_end2 = tex_grating4;
           end
                
            
              serialbreak(s3);
            tic
            
             if convector(trial) <4  
        
            for flickindex = 1:flickdur  % for 7000ms trials   
               
                    
                            % Drawing of gabor patches
                            Screen('DrawTexture', w, tex_end1, [], CenterRect(tRect_1, wRect));
                            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            Screen('DrawTexture', w, tex_end2, [], CenterRect(tRect_1, wRect));
                            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            if us == 1 && flickindex == USflickindex % US onset, only when us == 1
                                play(usnoise)  %took out fs
                            end

            end % end flicker loop
            
             else
                 
                    for flickindex = 1:flickdur  % for 7000ms trials   
               
                    
                            % Drawing of gabor patches
                            Screen('DrawTexture', w, tex_end1, [], CenterRect(tRect_1, wRect) );
                            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            Screen('DrawTexture', w, tex_end2, [], CenterRect(tRect_1, wRect));
                            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            if us == 1 && flickindex == USflickindex % US onset, only when us == 1
                                play(usnoise)  %took out fs
                            end

                    end % end flicker loop
            
             end% if condition 
                 
                 
                 
            witz  = toc;
            puma = [puma; witz]; % record length (ms) of trial
            
            Screen('Flip', w);  % remove gabor patch
           
               
            WaitSecs(rand(1,1)*2+1.2);
       

            if phase == 2 || phase == 3 % input only during acquisition and extinction
                
                        x_direction1 = 0;
            
                      % Move the cursor to the center of the screen
                    theX = 830
                    theY = 500
                    SetMouse(theX,theY);
                    ShowCursor(0);
                    
                        % ------ read images and record responses
                        Screen('DrawText', w, 'How likely is the loud noise to follow this pattern?', 400, 130, 255);
                        Screen('DrawText', w, 'Not Likely', 270, 900, 255);  
                        Screen('DrawText', w, 'Uncertain', 760, 900, 255);
                        Screen('DrawText', w, 'Likely', 1290, 900, 255); 
                        Screen('DrawText', w, '1', 330, 850, 255);
                        Screen('DrawText', w, '2', 440, 850, 255);
                        Screen('DrawText', w, '3', 550, 850, 255);
                        Screen('DrawText', w, '4', 660, 850, 255);
                        Screen('DrawText', w, '5', 770, 850, 255);
                        Screen('DrawText', w, '6', 880, 850, 255);
                        Screen('DrawText', w, '7', 1000, 850, 255);
                        Screen('DrawText', w, '8', 1110, 850, 255);
                        Screen('DrawText', w, '9', 1220, 850, 255);
                        Screen('DrawText', w, '10', 1330, 850, 255);
                        
                        
                       if convector(trial) <4  
                        Screen('DrawTexture', w, tex_grating1,[],CenterRect(tRect_1, wRect))
                        else
                             Screen('DrawTexture', w, tex_grating3,[],CenterRect(tRect_1, wRect))
                        end
                                    
                        % Show stimulus on screen & record onset time
                        [VBLTimestamp startrt]=Screen('Flip', w);
                    
                        % record reaction: X dimension of mouse
                        buttons = 0;
                        respvec = 0;
                        pressed = 0;
                        while ~any(buttons) % wait for press
                            [x_direction1,y,buttons] = GetMouse;
                            if buttons(1)
                                respvec = buttons;
                                pressed = GetSecs;
                            end
                            % Wait 10 ms before checking the mouse again to prevent
                            % overload- of the machine at elevated Priority()
                            WaitSecs(0.01);
                        end
                        if respvec(1)
                            responseRT = round(1000*(pressed-startrt));
                        end
                        
                        Screen('Flip', w);  %% make sure cursor disappears here! lol..
                        HideCursor  %%%  need ITI in here?
            elseif phase == 1                
                        x_direction1 = 0;
                        WaitSecs(rand(1,1)*2+1.5);
            end

            % Dat file information 
                    fprintf(datafilepointer,'%i %i %i %i %i %i %i \n', ...
                    subNo, ...
                    phase, ...
                    trial, ...
                    convector(trial), ...
                    x_direction1, ...
                    puma(trial),...
                    responseRT);
               
           
            WaitSecs(1);
            Screen('TextSize', w, 22);
            DrawFormattedText(w,'+','Center','Center',WhiteIndex(w));
            Screen('Flip', w);

        end  % end trial loop
    end  % phase loop
    
% End of Experiment, error catch

catch
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
     
end % try/catch loop
    