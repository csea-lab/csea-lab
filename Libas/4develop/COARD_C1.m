function COARD_C1(subNo)
%
% 1. %%%%%% set the settings for keyb and clock, same for each experiment

    clc;
    if ~isempty(instrfind), fclose(instrfind); end
   rng('shuffle'); % reseed the random-number generator for each expt.% reseed the random-number generator for each expt.

    % init keyboard responses (caps doesn't matter)
    advancestudytrial=KbName('n');
 
% 2. %%%%%% set the settings that are changed for each experiment, set file
% handling for file with the responses etc. that is written out for each
% subject

durationpic =.1;

% open serial port for trigger writing
s3 = serial('/dev/ttyUSB0', 'BaudRate', 4800, 'Terminator', 'CR/LF');
fopen(s3);

% Defining the base messages
WellcomeMsg1=['Please get ready. remember that your task is to press the mouse key whenever the central cross changes to red.'];
WellcomeMsg2=['READY? then click'];
goodbyeMsg = ['You have completed the first task. Thank you!\n\n' ...
    'The experimenter will be with you in a moment.'];

% files
datafilename = strcat('COARD_C1_',num2str(subNo),'.dat'); % name of data file to write to

% check for existing file (except for subject numbers > 99)   O
if subNo<99 && fopen(datafilename, 'rt')~=-1
    error('data files exist!');
else
    datafilepointer = fopen(datafilename,'wt'); % open ASCII file for writing
end

% 3. %%%%%% in the try, end, catch loop, program the experiment per se,
% with the presentation and such. start with AssertOpenGL;handle screens;
% text, and cursors

try
    AssertOpenGL;
    % get screen
    screens=Screen('Screens');
    screenNumber=max(screens);
    % Open a double buffered fullscreen window and draw a black background
    % to front and back buffers:
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    % returns as default the mean black value of screen
    black=BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    Screen('FillRect',w, black);
    Screen('Flip', w);
    HideCursor(0,0)
    % set Text properties (all Screen functions must be called after screen
    Screen('TextSize', w, 24);
    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    WaitSecs(1)
    
    % conditions and instruction screen
    ntrials = 240;
    targetvectemp = randperm(ntrials);
    targetvectemp2 = targetvectemp(1:15); % pick 15 trials as target trials, per block
    targetvec = zeros(1,ntrials);
    targetvec(targetvectemp2)= 1;
    bigVec=repmat([1:2],1,120); %% Vector of 1-4 repeating 60 times
    indices = randperm(240); %% The numbers 1-240 in random order
    convector = (bigVec(indices)); %% The order of our presented conditions
    
    DrawFormattedText(w, WellcomeMsg1, 'center', 'center', [255]);
    Screen('Flip', w);
    %wait for mouse click
    buttons=0;
    while ~any(buttons) % wait for press
        [x,y,buttons] = GetMouse;
        % Wait 10 ms before checking the mouse again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.01);
    end
    
    WaitSecs(1);
    
    %%%%%%%%%%%%%%%%%% main loop 
    
        
        for block = 1:1
       
        DrawFormattedText(w, WellcomeMsg2, 'center', 'center', [255]);
        Screen('Flip', w);
       
        %wait for mouse click
        buttons=0;
            while ~any(buttons) % wait for press
                    [x,y,buttons] = GetMouse;
                    % Wait 10 ms before checking the mouse again to prevent
                    % overload of the machine at elevated Priority()
                    WaitSecs(0.01);
            end
        
        Screen('Flip', w);
        WaitSecs(1)
        DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
        Screen('Flip', w);
        WaitSecs(1)
     
        
        for trial = 1:ntrials

            if convector(trial) == 1 %top of visual field
                stim1 = imread('/home/psychlab-stim/Desktop/Matlab_files/exp_stimuli/COARD_C1/top20_L.jpg');
            elseif convector(trial) == 2 %bottom of visual field - right tilt
                stim1 = imread('/home/psychlab-stim/Desktop/Matlab_files/exp_stimuli/COARD_C1/bottom20_L.jpg');                         
            end

            % PC in the lab C:\Documents and Settings\KeilLab\My Documents\As_Exps\C1\

            %make predefined stim textures
            tex_1=Screen('MakeTexture', w, stim1);
            tRect_1=Screen('Rect', tex_1);
          
          
            Screen ('DrawTexture', w,tex_1);
            Screen('Flip', w);
            
            % first, assign default values to 'buttons(mouse)' & 'response'
            buttons=0;
            respvec = 0;
            checkvec = 0;


         % show the stimulus
         %%%%%%%%%%%%%%%%%%%%%%%%%%%      

             fprintf(s3, [0 1]); % Trigger sent/event marker sent


             Screen('DrawTexture', w, tex_1, [], CenterRect(tRect_1, wRect));
 
             DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
             Screen('Flip', w);
             WaitSecs(durationpic)

             DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
             Screen('Flip', w);
                 
                 if targetvec(trial) == 1, WaitSecs(rand(1,1))
                     
                     DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
                     
                     WaitSecs(rand(1,1)./2)
                      
                     DrawFormattedText(w, '+', 'center', 'center', [255 0 0]);
                 else
                     DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
                 end
                    

                [vbltimestamp, starttarget] = Screen('Flip', w);

                       % get the mouse-clicking responses
                                    buttons = 0; 
                                    %start timer
                                        tic;
                                        t = 0;
                                        pressed = 0; 

                                        %wait for mouseclick or .8 seconds, whichever comes first
                                        while t < 1.0 
                                            [x,y,buttons] = GetMouse;
                                            if buttons(1)
                                            respvec = buttons; 
                                            pressed = GetSecs;
                                            break, 
                                            end 
                                            toc;
                                            t = toc;
                                            WaitSecs(0.01);
                                        end
                                                if respvec(1)
                                                 rt = round(1000*(pressed-starttarget));
                                                 else
                                                    rt = 0; 
                                                end                                                                                            

                Screen('close', tex_1);

                fprintf(datafilepointer,'%i %i %i %i %i %i \n', ...
                subNo, ...
                trial, ...
                block,...
                convector(trial),...
                targetvec(trial),...
                rt);

            WaitSecs(rand(1,1)./1.5)
            
        end %trial loop
        
        DrawFormattedText(w, goodbyeMsg, 'center', 'center', [255]);
        Screen('Flip', w);
        
        WaitSecs(10)

        end % block - 4 per phase

Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
psychrethrow(psychlasterror);
clearScreen

catch

end %try loop

        
        
        
        