function condi_uninstruct(subNo)


%%% PRE-SETTINGS %%%

clc;
rand('state', sum(100*clock));

% open serial port for trigger writing
    s3 = serial('COM3'); % on PC only
    fopen(s3)
    s4 = serial('COM4'); % on PC only
    fopen(s4)

%     serialbreak(s4,1000); 
    
% define frequency
    durationpic = 0.075;  %%% make sure this is correct!!!
    puma = [];            %%% tic toc recording

% Define KeyPad/Response
    KbName('UnifyKeyNames');
    advancestudytrial = KbName('n');

% datfile and file labelling
    datafilename = strcat('condi_unintruct',num2str(subNo),'.dat'); % name of data file to write to

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
    gray = GrayIndex(screenNumber, 0.5019);
    [w, wRect] = Screen('OpenWindow', screenNumber, gray, [], 32);
    Screen('FillRect', w, gray);
    Screen('Flip', w);
    Screen('TextSize', w, 24);
    
% Priority
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel)
    
% Read in files
    % Textures
%     imdata_welcome = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\welcome.png');
%     imdata_condi = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\conditime.png');
    imdata_welcome = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/welcome.png');
    imdata_condi = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/conditime.png');
    
    % read startle sound
%     [startlewhite, fs_s] = wavread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\startlewhite.wav');
%     [soundvec, fs] = wavread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\whitenoise.wav');
    
    % make textures
    tex_welcome = Screen('MakeTexture', w, imdata_welcome);     % initial screen
    tRect_welcome = Screen('Rect', tex_welcome);

    tex_cond = Screen('MakeTexture', w, imdata_condi);
    tRect_cond = Screen('Rect', tex_cond);
    
    
    
%%% BEGIN EXPERIMENT %%%
%%%%%%%%%%%%%%%%%%%%%%%%

% Initial Welcome Screen

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
    WaitSecs(2.000);

    
% Phase loop
    
    for phase = 2:3    %%%%% change this back to 1:3!!!!!!!
        if phase == 1
            ntrials = 18;
            convector = [1,1,2,1,1,2,2,2,1,1,2,1,2,1,2,2,2,1];
            startlevector = [7900,3400,4400,7900,4400,4400,3400,7900,7900,4400,3400,3400,4400,3400,7900,7900,3400,4400];
            reinforce66 = [ones(1,18).*9];
        elseif phase == 2
            ntrials = 36;
            convector = [2,1,1,2,1,2,2,1,1,1,2,2,1,2,1,2,1,1,2,1,1,2,1,2,2,1,1,2,2,1,2,1,2,1,2,2];
            startlevector = [3400,4400,3400,7900,3400,4400,4400,7900,7900,4400,3400,7900,4400,4400,3400,7900,3400,7900,7900,7900,3400,4400,3400,3400,4400,4400,4400,3400,7900,7900,4400,7900,3400,4400,7900,3400];
            reinforce66 = [0,1,1,0,1,0,0,1,1,1,0,0,1,0,0,0,0,1,0,0,1,0,1,0,0,1,1,0,0,0,0,1,0,1,0,0];
        elseif phase == 3
            ntrials = 44;
            convector = [1,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,2,1,2,2,1,1,1,2,1,1,2,1,1,2,2,2,2,2,1,1,1,2,2,1,2,1,2];
            startlevector = [3400,4400,4400,7900,4400,3400,7900,7900,4400,3400,3400,4400,4400,7900,7900,7900,3400,3400,4400,7900,3400,7900,7900,4400,3400,7900,3400,7900,4400,4400,7900,4400,3400,3400,4400,3400,3400,7900,4400,7900,3400,4400,7900,7900];
            reinforce66 = [ones(1,22).*9 1 ones(1,21).*9];
        end

    
% Trial/flicker loop

        for trial = 1:ntrials
            % Conditioning un-instruction screen
            buttons = 0;
            pressed = 0;
            respvec = 0;
            
            if phase == 2 && trial == 1
                Screen('DrawTexture', w, tex_cond, [], CenterRect(tRect_cond, wRect));
                Screen('Flip', w);

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


            % Stimuli, flicker duration, and US occurance definitions
            flickdur = 42;
            us = 0;

            if convector(trial) == 1 % magno right
%                 stim1 = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\Rm_75.jpg');
%                 stim2 = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\Rn_75.jpg');
                stim1 = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/P1R.png');
                stim2 = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/P2R.png');
                
                if phase == 2 && reinforce66(trial) == 1, flickdur = 48, us = 1; % Acq CS+, where US occurs
                elseif phase == 2 && reinforce66(trial) == 0, flickdur = 42, us = 0; %maybe unncessary to have this line
                elseif phase == 3 && reinforce66(trial) == 1, flickdur = 48, us = 1; % Re exposure during extinction
                end

            elseif convector(trial) == 2 % magno left, CS-
%                 stim1 = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\Lm_75.jpg');
%                 stim2 = imread('C:\Documents and Settings\andreas CSEA\My Documents\As_Exps\mp_gabor\stimuli\Ln_75.jpg');
                stim1 = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/P1L.png');
                stim2 = imread('/Users/fgruss/Documents/Studies/condi_uninstruct/Stimuli/P2L.png');
            end


            % Fixation Cross    
            Screen('TextSize', w, 22);
            DrawFormattedText(w,'+','Center','Center',WhiteIndex(w));
            Screen('Flip', w);

            fprintf(s4, 'P')  % trigger to VPM of trial start
            WaitSecs(1)
            serialbreak(s4, 1000);

            % Textures        
            tex_1=Screen('MakeTexture', w, stim1);
            tRect_1=Screen('Rect', tex_1);
            tex_2=Screen('MakeTexture', w, stim2);
            tRect_2=Screen('Rect', tex_2);


            % Flicker loop
            tic        
            for flickindex = 1:flickdur  % for 7000ms trials
                if flickindex == 1
                    serialbreak(s3);
                end
                    if startlevector(trial) == 4400 && flickindex == 35, wavplay(startlewhite, fs_s, 'async') % 5 sec startle, double check flickindex though
                    elseif startlevector(trial) == 3400&& flickindex == 28, wavplay(startlewhite, fs_s, 'async') % 4 sec startle
                    end
                    if startlevector(trial) = 4400 && flickindex == 34, fprintf(s4,'S'), fprintf(s3, 'TTTT') % fast sample one cycle ahead by 83.3ms
                    elseif startlevector(trial) == 3400 && flickindex == 27, fprintf(s4,'S'), fprintf(s3,'TTTT')
                    end
                            % Drawing of gabor patches
                            Screen('DrawTexture', w, tex_1, [], CenterRect(tRect_1, wRect));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            Screen('DrawTexture', w, tex_2, [], CenterRect(tRect_2, wRect));
                            Screen('Flip', w);
                            WaitSecs(durationpic)
                            if us == 1 && flickindex == 43 && reinforce66(trial) ==1  % US onset, only when us == 1
                                wavplay(soundvec, fs, 'async')
                            end

            end % end flicker loop
            toc
            puma = [puma; toc]; % record length (ms) of trial
            Screen('Flip', w);  % remove gabor patch


            % ITI and ITI startle
            WaitSecs(.5);
            serialbreak (s4, 1000);
            WaitSecs(.5);

            if startlevector(trial) == 7900; 
                WaitSecs(1.0);
                fprintf(s4, 'S'),  serialbreak(s3), 
                WaitSecs(.143);
                wavplay(startlewhite, fs_s, 'async')
                WaitSecs(.5); 
                serialbreak (s4, 100);
            else
                WaitSecs(rand(1,1)*2+1.5);
            end

            if phase == 2 || phase == 3 % input only during acquisition and extinction
                
                        x_direction1 = 0;
            
                      % Move the cursor to the center of the screen
                    theX = 400
                    theY = 300
                    SetMouse(theX,theY);
                    ShowCursor(0);
                    
                        % ------ read images and record responses
                        Screen('DrawText', w, 'How likely is the sound to follow?', 115, 30, 255);
                        Screen('DrawText', w, 'Not Likely', 40, 500, 255);  
                        Screen('DrawText', w, 'Uncertain', 320, 500, 255);
                        Screen('DrawText', w, 'Likely', 597, 500, 255); 
                        Screen('DrawText', w, '1', 45, 470, 255);
                        Screen('DrawText', w, '5', 390, 470, 255);
                        Screen('DrawText', w, '10', 670, 470, 255);
                        Screen('DrawTexture', w, tex_1, [], CenterRect(tRect_1, wRect));
                                    
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
                        
                        Screen('Flip', w);  %% make sure cursor disappears here!
                        HideCursor  %%  makes sure exact code for this  -- also need to recenter!!
            elseif phase == 1                
                        x_direction1 = 0;
                        WaitSecs(rand(1,1)*2+1.5);
            end


            % Dat file information 
                    fprintf(datafilepointer,'%i %i %i %i %i %i %i %i \n', ...
                    subNo, ...
                    phase, ...
                    trial, ...
                    convector(trial), ...
                    reinforce66(trial), ...
                    x_direction1, ...
                    puma(trial),...
                    responseRT);
                
            screen('close', tex_1)
            screen('close', tex_2)
            
            % WaitSecs(8)

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
    