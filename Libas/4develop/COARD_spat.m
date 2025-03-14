function COARD_spat(subNo)
Screen('Preference', 'SkipSyncTests', 1);
 clc;
 if ~isempty(instrfind), fclose(instrfind); end
 rng('shuffle'); % reseed the random-number generator for each expt.% reseed the random-number generator for each expt.

%serial port for trigger
% open serial port for trigger writing
%s3 = serial('/dev/ttyUSB0', 'BaudRate', 4800, 'Terminator', 'CR/LF');
%fopen(s3);

% wherw are the pics
   stimdir = ('/Users/andreaskeil/As_Docs/stimuli/IAPS 1-20/IAPS 1-20 Images/');

% Defining the base messages
WellcomeMsg1=['Please get ready. remember that your task is to press the mouse key whenever the central cross changes to red.'];
WellcomeMsg2=['READY? then click'];
goodbyeMsg = ['You have completed the first task. Thank you!\n\n' ...
    'The experimenter will be with you in a moment.'];


AssertOpenGL;

gray = [];

 
%  log file 
datafilename = strcat('COARD_spat',num2str(subNo),'.dat'); % name of data file to write to

% Prevent accidentally overwriting data (except for subject numbers > 99)
if subNo < 99 && fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Result data file exists!');
else
    datafilepointer = fopen(datafilename, 'wt');
end

% picture files
    filemat = dir([stimdir '*.jpg']); %reads in pics from folder
    ntrials = size(filemat, 1); %gets the size of the folder
    newindices = randperm(size(filemat,1));  %creates a new index the same size as the original folder
    filemat_perm = filemat(newindices,:); %creates a random permutation of pics -> new pic order
    

% actual experiment ...

try
    screens = Screen('Screens');
    screenNumber = max(screens);

    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    [centerX, centerY] = RectCenter(wRect), pause
    center = [centerX, centerY];

    % locations
    leftloc = [centerX-400 centerY-200 centerX centerY+200];
    rightloc = [centerX+400 centerY-200 centerX centerY+200];


    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    % Hide cursor
    HideCursor(0,0);
            
    % here: determine the gray etc
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    gray = (white+black)/2;
  
            
    % General instruction  
    % here mouse click to start
    % write message to subject
     % clear screen
    Screen('FillRect', w, black);
    Screen('Flip', w);
    
    % wait a bit before starting experiment
    WaitSecs(.5);
    Screen('DrawText', w, 'Welcome to the experiment. In each trial, you will focus on a fixation cross while two pictures are presented.', 20, 20, 1275, WhiteIndex(w));
    Screen('DrawText', w, 'Sometimes the cross will change color.', 20, 70, 1275, WhiteIndex(w));
    Screen('DrawText', w, 'Please pay attention to these changes.', 20, 120, 1275, WhiteIndex(w));
    Screen('DrawText', w, 'Click the mouse key if cross changes color, Thanks!.', 20, 170, 1275, WhiteIndex(w)););

    Screen('DrawText', w, 'Please press any key to start the experiment...', 20, 900, 1275);
    Screen('Flip', w); % show text
    
    % clear screen
    Screen('Flip', w);
    
    % wait a bit before starting trial
    WaitSecs(rand(1,1) + 3);
    
    %%%%%%%%%%%%%%%%%%%%%
    %%%%% TRIAL LOOP MAIN EXP
   
    % first constrcuct a vecto with condition numbers, probably for angry
    % neutral * hemifield * left vs right probe = 8 conditions max
   
    % find orientation of second target
    for trial = 1:ntrials

        imdatatemp=imread([stimdir filemat_perm(trial).name]); %reads in random picture for every trial but records pic used
        imdata = double(imresize(imdatatemp, [200 200]));
  
        
        if trial == 80
             Screen('DrawText', w, ' You are halfway done - good job! Wait for experimenter...', 20, 900, 1275);
                Screen('Flip', w); % show text
    
                    % wait for mouse press ( no GetClicks  :(  )
                     buttons=0;
                        while ~any(buttons) % wait for press
                        [thex,they,buttons] = GetMouse;
                        % Wait 10 ms before checking the mouse again to prevent
                        % overload of the machine at elevated Priority()
                        WaitSecs(0.01);
                        end
        end
        
        % settings for the ssVEP: 
      sequence1 = repmat([1 1 1 0 0 0],1,4);          %24-element loops: each has 1*8.33*24 ms = 200 ms
      sequence2 = repmat([1 1 1 1 0 0 0 0], 1,3);
        
        WaitSecs(1+ rand(1,1));
        
        % Fixation cross
        Screen('TextSize', w, 22);
        DrawFormattedText(w,'+','Center','Center',WhiteIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)+1);
        
           
           % make textures for faces
            tex_left = Screen('MakeTexture', w, imdata);
            tRect = Screen('Rect', tex_left);

            tex_right = Screen('MakeTexture', w, imdata);
            tRect = Screen('Rect', tex_right);
        
          %%%% show the actual stimuli    

                fprintf(s3, [0 1]);
 tic
            for loopindex = 1:10 % go through the 35-element loop 10 times
                             
               for flipindex = 1:24              
               
               if sequence1(flipindex) == 1, Screen('DrawTexture', w, tex_left,[],leftloc,[],[],1); end  %shows face1
               if sequence2(flipindex) == 1, Screen('DrawTexture', w, tex_right,[],rightloc,[],[],1); end  %shows face2                
                DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
                 
                Screen('Flip', w);
               end % for flipindex
                
           end % for loopindex                      
          
 timevector =  toc ;
 
                    
                     DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
                                        
                     [dummy, startrt] = Screen('Flip', w);
     
                    
        % Write results to file
        fprintf(datafilepointer,'%i %i %i %i %i %i %s %s  \n', ...
            subNo, ...
            trial, ...
            probeconvec(trial), ...
           resp, ... %  response
            rt,...
            timevector, ...
            leftstimwriteout, ...
            rightstimwriteout);
        
        Screen('Close', tex_left)
        Screen('Close', tex_right)
      
    end   % trial
    
    Screen('Flip', w);
    
   
    % wait a bit before starting trial
    WaitSecs(rand(1,1) + 2);
    
    % write message to subject
    Screen('DrawText', w, 'Thank you very much for participating!', 10, 10, 255);
    Screen('DrawText', w, 'The experimenter will be with you shortly...', 10, 60, 255);
    Screen('Flip', w); % show text
    % wait for mouse press ( no GetClicks  :(  )
    buttons=0;
    while ~any(buttons) % wait for press
        [thex,they,buttons] = GetMouse;
        % Wait 10 ms before checking the mouse again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.011);
    end
    
    
    % ready to end the exp   
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    %  fclose(s3);
    
    % End of experiment:
    return;
  catch
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    %
    %      fclose(s3);
    psychrethrow(psychlasterror);
 end