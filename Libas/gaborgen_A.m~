function gaborgen_A(subNo)

clc;
rand('state', sum(100*clock));

AssertOpenGL;

% open serial port for trigger writing
s1 = serial('COM1'); % on PC only
fopen(s1)

% Define KeyPad/Response
KbName('UnifyKeyNames');
advancestudytrial = KbName('n');

% files
datafilename = strcat('gaborgen_A_',num2str(subNo),'.dat'); % name of data file to write to

% Prevent accidentally overwriting data (except for subject numbers > 99)
if subNo < 99 && fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Result data file exists!');
else
    datafilepointer = fopen(datafilename, 'wt');
end


%%% Experiment start: try ...and... catch
try
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    HideCursor;
    
    % Black background
    black = BlackIndex(screenNumber);
    [w, wRect]=Screen('OpenWindow', screenNumber, black, [], 32);
    Screen('TextSize', w, 32);
    
    %determine black, white, gray
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    
    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % make textures for the three instruction screens
    welcome = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\page1.jpg');
    welcome2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\page2.jpg');
    instruct = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\page3.jpg');
    instruct2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\page4.jpg');
    last = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\page5.jpg');
    
    hab = Screen('MakeTexture', w, welcome);
    habrect = Screen('Rect', hab);
    
    hab2 = Screen('MakeTexture', w, welcome2);
    habrect2 = Screen('Rect', hab2);
    
    cond = Screen('MakeTexture', w, instruct);
    condrect = Screen('Rect', cond);
    
    cond2 = Screen('MakeTexture', w, instruct2);
    condrect2 = Screen('Rect', cond2);
    
    ext = Screen('MakeTexture', w, last);
    extrect = Screen('Rect', ext);
           
    % welcome screen #1
        Screen('DrawTexture', w, hab, [], CenterRect(habrect, wRect));
        Screen('Flip', w); % show text
        
        % wait for mouse press ( no GetClicks  :(  )
        buttons=0;
        while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse;
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
        end
        
        waitsecs(0.5);
        
    % welcome screen #2    
        Screen('DrawTexture', w, hab2, [], CenterRect(habrect2, wRect));
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
        WaitSecs(1.000);
    
    %read in US and startle noises
    [soundvec, fs] = wavread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\whitenoise.wav');
    [startlesound, fs] = wavread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\startlesound.wav');
     
    %determine flicker frequency
    durationscreen = 0.059;
    
    ntrials = 64; %number of trials PER EXPERIMENT PHASE
    
%     q = [15,25,35,45,55,65,75,-45]; %possible angle conditions
%     order_q = [1, 2, 3, 4, 5, 6, 7,  8]; % coding of angle conditions
%     tempvec = repmat(q,[1 8]);
%     tempvec_codes =  repmat(order_q,[1 8]);
    hab_codes = [6,2,5,1,7,8,4,3,4,7,3,6,8,2,1,5,5,6,2,7,3,8,1,4,4,2,5,1,8,7,6,3,2,3,8,4,7,1,5,6,7,2,4,3,8,1,6,5,7,2,5,8,4,3,6,1,4,8,7,6,5,1,2,3];
    hab_theta = [65,25,55,15,75,-45,45,35,45,75,35,65,-45,25,15,55,55,65,25,75,35,-45,15,45,45,25,55,15,-45,75,65,35,25,35,-45,45,75,15,55,65,75,25,45,35,-45,15,65,55,75,25,55,-45,45,35,65,15,45,-45,75,65,55,15,25,35];
    acq_codes = [ 2, 3, 7, 5, 1, 4, 6,  8, 1, 7, 4, 6,  8, 5, 2, 3,  8, 4, 6, 7, 2, 5, 1, 3, 5, 3,  8, 7, 6, 2, 1, 4, 3, 5, 4, 6, 7, 1,  8, 2, 6, 5, 2,  8, 7, 4, 3, 1, 4,  8, 6, 2, 7, 3, 5, 1, 5, 6, 7, 4, 1,  8, 2, 3];
    acq_theta = [25,35,75,55,15,45,65,-45,15,75,45,65,-45,55,25,35,-45,45,65,75,25,55,15,35,55,35,-45,75,65,25,15,45,35,55,45,65,75,15,-45,25,65,55,25,-45,75,45,35,15,45,-45,65,25,75,35,55,15,55,65,75,45,15,-45,25,35];
    ext_codes = [8,5,6,7,4,3,1,2,8,4,6,7,2,1,5,3,5,2,7,8,4,1,3,6,4,8,2,7,5,6,1,3,6,7,4,2,3,5,1,8,5,1,4,7,8,3,2,6,5,4,1,8,6,3,2,7,5,6,1,4,7,2,8,3];
    ext_theta = [-45,55,65,75,45,35,15,25,-45,45,65,75,25,15,55,35,55,25,75,-45,45,15,35,65,45,-45,25,75,55,65,15,35,65,75,45,25,35,55,15,-45,55,15,45,75,-45,35,25,65,55,45,15,-45,65,35,25,75,55,65,15,45,75,25,-45,35];
    
    startlevec_1 = [1 3 5 7];
    startlevec_2 = [2 4 6 8];
    
    
    %%% for loop for 3 phases of experiment %%%
    for phase = 1:3 
        
%         randvec = randperm(ntrials)
%         
%         thetavec = tempvec(randvec);
%         thetavec_code = tempvec_codes(randvec); 


        if phase == 1
            thetavec = hab_theta;
            thetavec_code = hab_codes;
        elseif phase == 2
            thetavec = acq_theta;
            thetavec_code = acq_codes;
        else
            thetavec = ext_theta;
            thetavec_code = ext_codes;
        end

        
        for trial = 1:ntrials
            
            WaitSecs(rand(1,1)+3.5); %ITI between 3.5 and 4.5 seconds (with a 2 second wait for physio later in code)
            
            Screen('FillRect', w, black);

            theta = thetavec(trial); %angle of gabor patch for each trial
            
            if theta == 15
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m15patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n15patch.jpg');
            elseif theta == 25
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m25patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n25patch.jpg');
            elseif theta == 35
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m35patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n35patch.jpg');
            elseif theta == 45
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m45patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n45patch.jpg');                
            elseif theta == 55
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m55patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n55patch.jpg');                
            elseif theta == 65
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m65patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n65patch.jpg');                
            elseif theta == 75
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m75patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n75patch.jpg');                          
            else
                stim1 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\m-45patch.jpg');
                stim2 = imread('C:\Documents and Settings\Compaq_Owner\My Documents\matlab_as\stimprograms\gaborgen\n-45patch.jpg');                
            end
                
            patch1 = Screen('MakeTexture', w, stim1);
            tRect_1=Screen('Rect', patch1);
            patch2 = Screen('MakeTexture', w, stim2);
            tRect_2=Screen('Rect', patch2);
            
%             [x,y] = meshgrid(-300:300, -300:300);      
%             % make gabor patches, textures
%             m = (exp(-((x/150).^2)-((y/150).^2)) .* sin(cos(theta*pi/180)*(pi*0.02)*x + sin(theta*pi/180)*(pi*0.02)*y));
%             n = (-exp(-((x/150).^2)-((y/150).^2)) .* sin(cos(theta*pi/180)*(pi*0.02)*x + sin(theta*pi/180)*(pi*0.02)*y));
%             
%             patch1 = Screen('MakeTexture', w, m, 1, [], 0, 2, []);
%             tRect = Screen('Rect', patch1);
%             
%             patch2 = Screen('MakeTexture', w, n, 1, [], 0, 2, []);
%             tRect = Screen('Rect', patch2);             
            
       %%% acquisition instructions     
            if phase == 2 && trial == 1
                Screen('DrawTexture', w, cond, [], CenterRect(condrect, wRect));
                Screen('Flip', w); % show text

                % wait for mouse press ( no GetClicks  :(  )
                buttons=0;
                while ~any(buttons) % wait for press
                    [x,y,buttons] = GetMouse;
                    % Wait 10 ms before checking the mouse again to prevent
                    % overload of the machine at elevated Priority()
                    WaitSecs(0.01);
                end
                
                waitsecs(0.5);
                
                Screen('DrawTexture', w, cond2, [], CenterRect(condrect2, wRect));
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
                WaitSecs(3.000);        
            end
            
       %%% Instruction screen for extinction phase     
            if phase == 3 && trial == 1
                Screen('DrawTexture', w, ext, [], CenterRect(extrect, wRect));
                Screen('Flip', w); % show text

                % wait for mouse press ( no GetClicks  :(  )
                buttons=0;
                while ~any(buttons) % wait for press
                    [x,y,buttons] = GetMouse;
                    % Wait 10 ms before checking the mouse again to prevent
                    % overload of the machine at elevated Priority()
                    WaitSecs(0.01);
                end
                
                Screen('Flip', w);
                
            end
            
            
      %%% startle flag!!      
           if ismember(trial, 1:8) | ismember(trial, 17:24) | ismember(trial, 33:40) | ismember(trial, 49:56);
               if ismember(thetavec_code(trial), startlevec_1);
                   startle = 1;
               else startle = 0;
               end
           else
               if ismember(thetavec_code(trial), startlevec_2);
                   startle = 1;
               else startle = 0;
               end
           end
           
            
      %%% PHYSIO TRIGGER, THEN WAIT 2 SECS BEFORE TRIAL
            fprintf(s1,'PP')
            WaitSecs(2.0) 
                 
      %%% Loop for CS+ and all other conditions
            if phase == 2 && theta == 45  %CS+ condition
                for flickindex = 1:42
                    if flickindex == 1
                        fprintf(s1, 'TT'); %stimulus onset trigger
                    elseif flickindex == 27 && startle == 1;
                        fprintf(s1,'S') % upsampling for startle, 142.8571ms before
                    elseif flickindex == 28 && startle == 1; % 28th flickindex is 4000ms
                        wavplay(startlesound, fs, 'async')
                    elseif flickindex == 35 % upsampling for US, 142.8571ms before US
                        fprintf(s1,'U')
                    elseif flickindex == 36 % 36th flickindex is 5000ms
                        wavplay(soundvec, fs, 'async')
                    end
                    Screen('DrawTexture', w, patch1, [], CenterRect(tRect_1, wRect));
                    Screen('Flip', w);
                    WaitSecs(durationscreen);

                    Screen('DrawTexture', w, patch2, [], CenterRect(tRect_2, wRect));
                    Screen('Flip', w);
                    WaitSecs(durationscreen);
                end %flicker loop
                Screen('Flip', w);
                waitsecs(1.0); %wait an extra second after US to allow for more time to establish a physio baseline for the next trial
                % entire CS+ trial is 6000ms plus additional 1000ms
                % post-trial baseline
                
            else
                for flickindex = 1:35
                    if flickindex == 1
                        fprintf(s1, 'TT');
                    elseif flickindex == 27 && startle == 1;
                        fprintf(s1,'S') % upsampling for startle, 142.8571ms before
                    elseif flickindex == 28 && startle == 1; % 28th flickindex is 4000ms
                        wavplay(startlesound, fs, 'async')
                    end
                  
                    Screen('DrawTexture', w, patch1, [], CenterRect(tRect_1, wRect));
                    Screen('Flip', w);
                    WaitSecs(durationscreen);
                    Screen('DrawTexture', w, patch2, [], CenterRect(tRect_2, wRect));
                    Screen('Flip', w);
                    WaitSecs(durationscreen);
                end %flicker loop
                Screen('Flip', w);
                
            end %if loop
            
            serialbreak(s1,50)
            
            con = strcat(num2str(phase), num2str(thetavec_code(trial)));
            
            fprintf(datafilepointer, '%i, %i, %i, %i, %i, %s, %i \r', ...    
            subNo,...
            trial,...
            phase,...
            theta,...
            thetavec_code(trial), ...
            con,...
            startle);
            
        end %trial loop
    end %phase loop
    % cleanup at end of experiment
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    fclose(s1); 
catch
    % catch error
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
    fclose(s1); 
end

    
    
