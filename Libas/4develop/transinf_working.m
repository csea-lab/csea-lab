function transinf_working(subjectNumber, cbOrder)
% TRANSINF  Transitive inference / value-based transitivity experiment
%
% Usage:
%   transinf(subjectNumber, cbOrder)
%
% Inputs:
%   subjectNumber  - integer subject ID (e.g. 1)
%   cbOrder        - integer 1-5, determines which physical scene category
%                    is assigned to the abstract role A,B,C,D,E and which
%                    specific within-category images play which role.
%                    Five counterbalancing orders rotate the category-to-
%                    role assignment:
%                      1: Tundra=A, Mountains=B, Desert=C, Forest=D, Grasslands=E
%                      2: Mountains=A, Desert=B, Forest=C, Grasslands=D, Tundra=E
%                      3: Desert=A, Forest=B, Grasslands=C, Tundra=D, Mountains=E
%                      4: Forest=A, Grasslands=B, Tundra=C, Mountains=D, Desert=E
%                      5: Grasslands=A, Tundra=B, Mountains=C, Desert=D, Forest=E
%
% Phases (in order):
%   1. Baseline 1        – passive viewing (500 ms stim, jittered ITI 2-3.5 s)
%   2. Similarity Ratings 1  – PLACEHOLDER (calls similarityRatings())
%   3. Learning          – A+/B-, B+/C-, C+/D-, D+/E- with feedback
%   4. Testing           – A/E, C/C, B/D;  no feedback
%   5. Baseline 2        – same structure as Baseline 1
%   6. Similarity Ratings 2  – PLACEHOLDER (calls similarityRatings())
%
% Data saved to:  data/sub-<subjectNumber>_transinf.csv
%
% Responses: mouse click (left button = left image, right button = right image)
% Timing is achieved with PTB's flip-based scheduling for ms accuracy.
%
% Requires: Psychtoolbox-3

%% =========================================================
%  0.  HOUSEKEEPING
%% =========================================================
% close all ports before starting
if ~isempty(instrfind), fclose(instrfind); end

rng(subjectNumber * cbOrder);          % reproducible randomisation per subject
KbName('UnifyKeyNames');

% Locate stimuli parent folder (sibling of this .m file)
stimuliDir  = '/home/andreaskeil/Desktop/As_Exps/transinf/stimuli/';

% Output directory
dataDir = '/home/andreaskeil/Desktop/As_Exps/transinf/data/';

%% ports for EEG event markers
% Port
% open serial port for trigger writing
s3 = serial('/dev/ttyUSB1', 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'Parity', 'none');
fopen(s3);


%% =========================================================
%  1.  CATEGORY / COUNTERBALANCING SETUP
%% =========================================================
% Physical category folder names (must match folders inside stimuli/)
allCategoryFolders = {'tundra', 'mountains', 'desert', 'forest', 'grasslands'};
nCategories        = numel(allCategoryFolders);   % 5
nImgsPerCat        = 20;

% Each cbOrder is a circular rotation that maps physical folder -> role A..E
% cbOrder 1 keeps the natural order; cbOrder 2 shifts by 1, etc.
roleOrder = mod((0:nCategories-1) + (cbOrder-1), nCategories) + 1;
% roleOrder(r) = index into allCategoryFolders for abstract role r
% e.g. cbOrder=1 -> roleOrder = [1 2 3 4 5]  (A=tundra, B=Mountains …)
%      cbOrder=2 -> roleOrder = [2 3 4 5 1]  (A=Mountains, …, E=tundra)

% Assign human-readable role labels
roleLabels = {'A','B','C','D','E'};
for r = 1:nCategories
    roles.(roleLabels{r}).folderName = allCategoryFolders{roleOrder(r)};
    roles.(roleLabels{r}).folderPath = fullfile(stimuliDir, allCategoryFolders{roleOrder(r)});
end

%% =========================================================
%  2.  LOAD IMAGE FILE PATHS (do NOT load textures yet)
%% =========================================================
for r = 1:nCategories
    lbl  = roleLabels{r};
    flds = dir(fullfile(roles.(lbl).folderPath, '*.png'));
    if numel(flds) < nImgsPerCat
        error('Category %s (%s): expected %d PNGs, found %d.', ...
            lbl, roles.(lbl).folderName, nImgsPerCat, numel(flds));
    end
    % Shuffle image order per subject/cb for within-category counterbalancing
    shuffIdx = randperm(nImgsPerCat);
    roles.(lbl).imgPaths = arrayfun(@(i) fullfile(roles.(lbl).folderPath, flds(shuffIdx(i)).name), ...
        1:nImgsPerCat, 'UniformOutput', false);
end

%% =========================================================
%  3.  PSYCHTOOLBOX INITIALISATION
%% =========================================================
PsychDefaultSetup(2);                  % normalised colour range [0,1]
screenNum = max(Screen('Screens'));    % use highest-numbered (external) screen

% Suppress PTB's verbose output in production; comment out for debugging
oldLevel = Screen('Preference','Verbosity', 1);
Screen('Preference','SkipSyncTests', 0);   % set to 1 only for debugging!

[win, winRect] = PsychImaging('OpenWindow', screenNum, 0.5);   % grey background

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

ifi        = Screen('GetFlipInterval', win);   % inter-frame interval (s)
slack      = ifi / 2;                           % flip scheduling slack

[cx, cy]   = RectCenter(winRect);
scrW       = RectWidth(winRect);
scrH       = RectHeight(winRect);

% Image display size (pixels) – adjust to suit your monitor / stimuli
imgW = round(scrW * 0.30);
imgH = round(scrH * 0.55);

% Left / right image rects (centred vertically, flanking fixation)
xOffset  = round(scrW * 0.25);          % distance of image centre from screen centre
leftRect  = CenterRectOnPointd([0 0 imgW imgH], cx - xOffset, cy);
rightRect = CenterRectOnPointd([0 0 imgW imgH], cx + xOffset, cy);

% Fixation dot parameters
fixDotRadius = 6;   % pixels
fixColor     = [1 1 1];

% Text parameters
Screen('TextFont',  win, 'Arial');
Screen('TextSize',  win, 36);
Screen('TextStyle', win, 1);   % bold

% Timing constants (seconds)
BASELINE_STIM_DUR   = 0.500;
BASELINE_ITI_MIN    = 2.0;
BASELINE_ITI_MAX    = 3.5;
LEARNING_MAX_RT     = 1.000;   % images stay on until response OR this limit
LEARNING_ITI_MIN    = 1.0;
LEARNING_ITI_MAX    = 2.0;
FEEDBACK_DUR        = 0.500;
TEST_MAX_RT         = 1.000;

% hide the cursor
HideCursor(win)

%% =========================================================
%  4.  DATA LOG INITIALISATION
%% =========================================================
% log file define and open for baseline 1
datafilename1 = [dataDir 'tinfLog1s' num2str(subjectNumber) '.dat'];
datafilepointer1 = fopen(datafilename1, 'w');

% log file define and open for ratings 1
datafileratings1 = [dataDir 'tinfLogrates' num2str(subjectNumber) '.dat'];
datafilepointerrate1 = fopen(datafileratings1, 'w');

% log file define and open for Learning 1
datafilename2 = [dataDir 'tinfLog2s' num2str(subjectNumber) '.dat'];
datafilepointer2 = fopen(datafilename2, 'w');

%log file define and open for baseline 2
datafilename3 = [dataDir 'tinfLog1s' num2str(subjectNumber) '.dat'];
datafilepointer3 = fopen(datafilename3, 'w');

% log file define and open for ratings 2
datafileratings2 = [dataDir 'tinfLogrates' num2str(subjectNumber) '.dat'];
datafilepointerrate2 = fopen(datafileratings2, 'w');

%% =========================================================
%  5.  Baseline 1
%% =========================================================

% write message to subject
Screen('DrawText', win, 'The experiment will begin shortly ... ', cx-120, cy, 255);
Screen('Flip', win); % show text
KbStrokeWait;
% clear screen
Screen('Flip', win);

%% randomization
NTrials = nCategories*nImgsPerCat; % trials in baseline phase = all pictures

counterA = 0;
counterB = 0;
counterC = 0;
counterD = 0;
counterE = 0;

Rolenamevec_randomized = []; % make a vector with as many role names as trials
for randoloop = 1:nImgsPerCat
    Rolenamevec_randomized = [Rolenamevec_randomized roleLabels(randperm(nCategories))];
end

for trialindex_bsl1 = 1:NTrials-99
    % first, set the event marker channel to zero
    fprintf(s3, '00');
    % start and control counters for each role
    if strcmp('A', char(Rolenamevec_randomized(trialindex_bsl1))), counterA = counterA+1; counter = counterA;
    elseif strcmp('B', char(Rolenamevec_randomized(trialindex_bsl1))), counterB = counterB+1;counter = counterB;
    elseif strcmp('C', char(Rolenamevec_randomized(trialindex_bsl1))), counterC = counterC+1; counter = counterC;
    elseif strcmp('D', char(Rolenamevec_randomized(trialindex_bsl1))), counterD = counterD+1; counter = counterD;
    elseif strcmp('E', char(Rolenamevec_randomized(trialindex_bsl1))), counterE = counterE+1; counter = counterE;
    end
    
    %fixation cross
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(BASELINE_ITI_MIN + rand(1,1) * (BASELINE_ITI_MAX-BASELINE_ITI_MIN)) % ITI between 1 and 3 secs, uniform
    
    % make texture for this trial
    TrialPicturePath =  eval(['roles.' char(Rolenamevec_randomized(trialindex_bsl1)) '.imgPaths{' num2str(counter) '}']);
    [~, currentfile] = fileparts(TrialPicturePath);
    TrialPicture = imread(TrialPicturePath);
    TrialPicture = imresize(TrialPicture, .5);
    TrialTex=Screen('MakeTexture', win, TrialPicture);
    
    %show the picture
    Screen('DrawTexture', win, TrialTex);
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    fprintf(s3, '01');
    WaitSecs(BASELINE_STIM_DUR);
    % this is how long it is on, and now take it off the screen
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(.2);
    
    % Dat file information, add a row in each trial
    fprintf(datafilepointer1,'%i %i %i %s %s \n', ...
        subjectNumber, ...
        1, ...
        trialindex_bsl1, ...
        char(Rolenamevec_randomized(trialindex_bsl1)),...
        currentfile);
    
end

%% =========================================================
% 6 similarity rating 1
%% =========================================================

similarityRatings(win, roles, subjectNumber, dataDir, winRect, datafileratings1, datafilepointerrate1)

%% =========================================================
% 7 learning Phase 1
%% =========================================================

% write message to subject
Screen('DrawText', win, 'The next task will begin shortly ... ', cx-120, cy, 255);
Screen('Flip', win); % show text
KbStrokeWait;
% clear screen
Screen('Flip', win);

% mouse cursor
ShowCursor('Arrow',win);
SetMouse(cx, cy, win);   % park cursor at centre between trials

% randomization
NTrials = (nCategories-1)*nImgsPerCat/2; % trials in baseline phase = all pictures
counterA = 0;
counterB = 0;
counterC = 0;
counterD = 0;
counterE = 0;
pairlabelvec = [];
switchsidevec = []; 
for loopindex = 1:nImgsPerCat/2
    pairlabelvec = [pairlabelvec randperm(4)];
    switchsidevec = [switchsidevec randperm(2)];    
end

switchsidevec = [switchsidevec fliplr(switchsidevec)];

for trialindex_training = 1:NTrials
    % first, set the event marker channel to zero
%     fprintf(s3, '00');
    
    %Select the stimulus pair    
    if pairlabelvec(trialindex_training) == 1
        counterA = counterA+1;
        TrialPicturePath1 =  eval(['roles.A.imgPaths{' num2str(counterA) '}']);
        counterB = counterB+1;
        TrialPicturePath2 =  eval(['roles.B.imgPaths{' num2str(counterB) '}']);
    elseif pairlabelvec(trialindex_training) == 2
        counterB = counterB+1;
        TrialPicturePath1 =  eval(['roles.B.imgPaths{' num2str(counterB) '}']);
        counterC = counterC+1;
        TrialPicturePath2 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
    elseif pairlabelvec(trialindex_training) == 3
        counterC = counterC+1;
        TrialPicturePath1 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
        counterD = counterD+1;
        TrialPicturePath2 =  eval(['roles.D.imgPaths{' num2str(counterD) '}']);
    elseif pairlabelvec(trialindex_training) == 4
        counterD = counterD+1;
        TrialPicturePath1 =  eval(['roles.D.imgPaths{' num2str(counterD) '}']);
        counterE = counterE+1;
        TrialPicturePath2 =  eval(['roles.E.imgPaths{' num2str(counterE) '}']);
    end
    
    % make the corresponding textures  
    [~, currentfile1] = fileparts(TrialPicturePath1);
    [~, currentfile2] = fileparts(TrialPicturePath2);
    
    TrialPicture1 = imread(TrialPicturePath1);
    TrialPicture1 = imresize(TrialPicture1, .5);
    TrialTex1=Screen('MakeTexture', win, TrialPicture1);
    
    TrialPicture2 = imread(TrialPicturePath2);
    TrialPicture2 = imresize(TrialPicture2, .5);
    TrialTex2=Screen('MakeTexture', win, TrialPicture2);        
    
    %fixation cross
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(LEARNING_ITI_MIN + rand(1,1) * (LEARNING_ITI_MAX-LEARNING_ITI_MIN)) % ITI between 1 and 3 secs, uniform
           
    %show the picture pair
    if switchsidevec(trialindex_training) == 1
        Screen('DrawTexture', win, TrialTex1, [], [cx-500 cy-200 cx-100 cy+200] );
        Screen('DrawTexture', win, TrialTex2, [], [cx+100 cy-200 cx+500 cy+200] );
    elseif switchsidevec(trialindex_training) == 2
        Screen('DrawTexture', win, TrialTex2, [], [cx-500 cy-200 cx-100 cy+200] );
        Screen('DrawTexture', win, TrialTex1, [], [cx+100 cy-200 cx+500 cy+200] );
    end
        
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    sFlip = Screen('Flip', win);
    fprintf(s3, '02');  
    
    % wait for mouse click
        buttons=0;
            while ~any(buttons) % wait for press
                [xcoor,~,buttons] = GetMouse;
                 sPress=GetSecs;
                % Wait 10 ms before checking the mouse again to prevent
                % overload of the machine at elevated Priority()
                WaitSecs(0.01);
            end
            
            % calculate response side: left or right
            responseside_contin = cx-xcoor;            
            % positive means left and negative means right
            if switchsidevec(trialindex_training) == 1 && responseside_contin > 0
                correctstatus = 1; 
            elseif switchsidevec(trialindex_training) == 2 && responseside_contin < 0
                 correctstatus = 1; 
            else
                 correctstatus = 0; 
            end
                    
            % Calculate RT
            RTlearning = 1000*(sPress-sFlip);
    
            % and now take it off the screen
            if correctstatus == 1
                Screen('DrawText', win, ' CORRECT! ', cx-120, cy, [0 1 0]);
            elseif  correctstatus == 0
                Screen('DrawText', win, ' False :-( ', cx-120, cy, [1 0 0]);
            end
            Screen('Flip', win); % show text
            WaitSecs(.5);
    
    % Dat file information, add a row in each trial
    fprintf(datafilepointer2,'%i %i %i %i %i %i %i %i %i %s %s \n', ...
        subjectNumber, ...
        2, ...
        trialindex_training, ...
        pairlabelvec(trialindex_training),...
        switchsidevec(trialindex_training),...
        xcoor,...
        responseside_contin,...
        correctstatus,...
        RTlearning,...
        currentfile1, ...
        currentfile2);
    
end


%% =========================================================
% 8 Testing Phase
%% =========================================================

Screen('DrawText', win, 'The next task will begin shortly ... ', cx-120, cy, 255);
Screen('Flip', win); % show text
KbStrokeWait;
% clear screen
Screen('Flip', win);

% mouse cursor
ShowCursor('Arrow',win);
SetMouse(cx, cy, win);   % park cursor at centre between trials

% randomization
NTrials = (nCategories-1)*nImgsPerCat/2; % trials in baseline phase = all pictures
counterA = 0;
counterB = 0;
counterC = 0;
counterD = 0;
counterE = 0;
pairlabelvec = [];
switchsidevec = []; 
for loopindex = 1:nImgsPerCat/2
    pairlabelvec = [pairlabelvec randperm(4)];
    switchsidevec = [switchsidevec randperm(2)];    
end

switchsidevec = [switchsidevec fliplr(switchsidevec)];

for trialindex_training = 1:5
    % first, set the event marker channel to zero
     fprintf(s3, '00');
    
     
%Select the stimulus pair  
%NEED TO SOMEHOW INCREASE DD COUNTER (RUNS OUT)  
    if pairlabelvec(trialindex_training) == 1
        counterA = counterA+1;
        TrialPicturePath1 =  eval(['roles.A.imgPaths{' num2str(counterA) '}']);
        counterE = counterE+1;
        TrialPicturePath2 =  eval(['roles.E.imgPaths{' num2str(counterE) '}']);
    elseif pairlabelvec(trialindex_training) == 2
        counterC = counterC+1;
        TrialPicturePath1 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
        counterC = counterC+1;
        TrialPicturePath2 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
    elseif pairlabelvec(trialindex_training) == 3
        counterB = counterB+1;
        TrialPicturePath1 =  eval(['roles.B.imgPaths{' num2str(counterB) '}']);
        counterD = counterD+1;
        TrialPicturePath2 =  eval(['roles.D.imgPaths{' num2str(counterD) '}']);
    end
    
    % make the corresponding textures  
    [~, currentfile1] = fileparts(TrialPicturePath1);
    [~, currentfile2] = fileparts(TrialPicturePath2);
    
    TrialPicture1 = imread(TrialPicturePath1);
    TrialPicture1 = imresize(TrialPicture1, .5);
    TrialTex1=Screen('MakeTexture', win, TrialPicture1);
    
    TrialPicture2 = imread(TrialPicturePath2);
    TrialPicture2 = imresize(TrialPicture2, .5);
    TrialTex2=Screen('MakeTexture', win, TrialPicture2);        
    
    %fixation cross
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(LEARNING_ITI_MIN + rand(1,1) * (LEARNING_ITI_MAX-LEARNING_ITI_MIN)) % ITI between 1 and 3 secs, uniform
           
    %show the picture pair
    if switchsidevec(trialindex_training) == 1
        Screen('DrawTexture', win, TrialTex1, [], [cx-500 cy-200 cx-100 cy+200] );
        Screen('DrawTexture', win, TrialTex2, [], [cx+100 cy-200 cx+500 cy+200] );
    elseif switchsidevec(trialindex_training) == 2
        Screen('DrawTexture', win, TrialTex2, [], [cx-500 cy-200 cx-100 cy+200] );
        Screen('DrawTexture', win, TrialTex1, [], [cx+100 cy-200 cx+500 cy+200] );
    end
        
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    sFlip = Screen('Flip', win);
    fprintf(s3, '02');  
    
    % wait for mouse click
        buttons=0;
            while ~any(buttons) % wait for press
                [xcoor,~,buttons] = GetMouse;
                 sPress=GetSecs;
                % Wait 10 ms before checking the mouse again to prevent
                % overload of the machine at elevated Priority()
                WaitSecs(0.01);
            end
            
  %HOW TO GIVE FEEDBACK FOR CC AND DD
%             % calculate response side: left or right
            responseside_contin = cx-xcoor;            
%             % positive means left and negative means right
%             if switchsidevec(trialindex_training) == 1 && responseside_contin > 0
%                 correctstatus = 1; 
%             elseif switchsidevec(trialindex_training) == 2 && responseside_contin < 0
%                  correctstatus = 1; 
%             else
%                  correctstatus = 0; 
%             end
                    
            % Calculate RT
            RTlearning = 1000*(sPress-sFlip);
    
%             % and now take it off the screen
%             if correctstatus == 1
%                 Screen('DrawText', win, ' CORRECT! ', cx-120, cy, [0 1 0]);
%             elseif  correctstatus == 0
%                 Screen('DrawText', win, ' False :-( ', cx-120, cy, [1 0 0]);
%             end
            Screen('Flip', win); % show text
            WaitSecs(.5);
            
            
            fprintf(datafilepointer2,'%i %i %i %i %i %i %i %i %s %s \n', ...
                subjectNumber, ...
                4, ...
                trialindex_training, ...
                pairlabelvec(trialindex_training),...
                switchsidevec(trialindex_training),...
                xcoor,...
                responseside_contin,...
                RTlearning,...
                currentfile1, ...
                currentfile2);
            
            
%             % Dat file information, add a row in each trial
%     fprintf(datafilepointer2,'%i %i %i %i %i %i %i %i %i %s %s \n', ...
%         subjectNumber, ...
%         4, ...
%         trialindex_training, ...
%         pairlabelvec(trialindex_training),...
%         switchsidevec(trialindex_training),...
%         xcoor,...
%         responseside_contin,...
%         correctstatus,...
%         RTlearning,...
%         currentfile1, ...
%         currentfile2);
    
end





%% =========================================================
%  9.  Baseline 2
%% =========================================================

% write message to subject
Screen('DrawText', win, 'The experiment will begin shortly ... ', cx-120, cy, 255);
Screen('Flip', win); % show text
KbStrokeWait;
% clear screen
Screen('Flip', win);

% randomization
NTrials = nCategories*nImgsPerCat; % trials in baseline phase = all pictures

counterA = 0;
counterB = 0;
counterC = 0;
counterD = 0;
counterE = 0;

Rolenamevec_randomized = []; % make a vector with as many role names as trials
for randoloop = 1:nImgsPerCat
    Rolenamevec_randomized = [Rolenamevec_randomized roleLabels(randperm(nCategories))];
end

for trialindex_bsl2 = 1:NTrials-99
    % first, set the event marker channel to zero
    fprintf(s3, '00');
    % start and control counters for each role
    if strcmp('A', char(Rolenamevec_randomized(trialindex_bsl2))), counterA = counterA+1; counter = counterA;
    elseif strcmp('B', char(Rolenamevec_randomized(trialindex_bsl2))), counterB = counterB+1;counter = counterB;
    elseif strcmp('C', char(Rolenamevec_randomized(trialindex_bsl2))), counterC = counterC+1; counter = counterC;
    elseif strcmp('D', char(Rolenamevec_randomized(trialindex_bsl2))), counterD = counterD+1; counter = counterD;
    elseif strcmp('E', char(Rolenamevec_randomized(trialindex_bsl2))), counterE = counterE+1; counter = counterE;
    end
    
    %fixation cross
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(BASELINE_ITI_MIN + rand(1,1) * (BASELINE_ITI_MAX-BASELINE_ITI_MIN)) % ITI between 1 and 3 secs, uniform
    
    % make texture for this trial
    TrialPicturePath =  eval(['roles.' char(Rolenamevec_randomized(trialindex_bsl2)) '.imgPaths{' num2str(counter) '}']);
    [~, currentfile] = fileparts(TrialPicturePath);
    TrialPicture = imread(TrialPicturePath);
    TrialPicture = imresize(TrialPicture, .5);
    TrialTex=Screen('MakeTexture', win, TrialPicture);
    
    %show the picture
    Screen('DrawTexture', win, TrialTex);
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    fprintf(s3, '01');
    WaitSecs(BASELINE_STIM_DUR);
    % this is how long it is on, and now take it off the screen
    Screen('FillOval', win, 255 ,[cx-5 cy-5 cx+5 cy+5]);
    Screen('Flip', win);
    WaitSecs(.2);
    
    % Dat file information, add a row in each trial
    fprintf(datafilepointer3,'%i %i %i %s %s \n', ...
        subjectNumber, ...
        4, ...
        trialindex_bsl2, ...
        char(Rolenamevec_randomized(trialindex_bsl2)),...
        currentfile);
    
end



%% =========================================================
%% Similarity Ratings 2
%% =========================================================

similarityRatings(win, roles, subjectNumber, dataDir, winRect, datafileratings2, datafilepointerrate2)


%% End of entire experiment
Screen('DrawText', win, 'Thank you! Press any key to exit.', 20, 20, 1275);
Screen('Flip', win);
KbStrokeWait;

Screen('CloseAll')


end % main function transinf end



%% Similarity Ratings

function similarityRatings(win, roles, subjectNumber, dataDir, winRect, datafileratings, datafilepointerrate)

[cx, cy] = RectCenter(winRect);
scrW = RectWidth(winRect);
scrH = RectHeight(winRect);

% image display rects, flanking center
imgW = round(scrW * 0.30);
imgH = round(scrH * 0.55);
xOffset = round(scrW * 0.25);

leftRect  = CenterRectOnPointd([0 0 imgW imgH], cx - xOffset, cy);
rightRect = CenterRectOnPointd([0 0 imgW imgH], cx + xOffset, cy);

% fixation dot
fix_cord = [cx-5 cy-5 cx+5 cy+5];

% slider setup (adapted from simrate2)
locationPosFrac = [0/9, 1/9, 2/9, 3/9, 4/9, 5/9, 6/9, 7/9, 8/9, 9/9]; % 10 selectable locations
locationPosTick = [0/9, 5/9, 9/9];
% locationPosFrac = 0:0.2:1;              % 5 selectable positions, 0 to 1
% locationPosTick = [0 0.5 1];             % only these get drawn/labeled
sliderWidth   = scrW * 0.6;
sliderHeight  = 20;
sliderXcenter = scrW / 2;
sliderY       = scrH * 0.85;
sliderRect    = CenterRectOnPointd([0 0 sliderWidth sliderHeight], sliderXcenter, sliderY);
sliderBgColor  = [100 100 100];
locMarkerColor = [0 255 0];

% randomization
allCategoryFolders = {'tundra', 'mountains', 'desert', 'forest', 'grasslands'};
nCategories        = numel(allCategoryFolders); 
nImgsPerCat        = 10;
NTrials = (nCategories-1)*nImgsPerCat/2; % trials in baseline phase = all pictures

counterA = 0;
counterB = 0;
counterC = 0;
counterD = 0;
counterE = 0;

pairlabelvec = [];
switchsidevec = [];

for loopindex = 1:nImgsPerCat/2
    pairlabelvec = [pairlabelvec randperm(4)];
    switchsidevec = [switchsidevec randperm(2)];
end

switchsidevec = [switchsidevec fliplr(switchsidevec)];

for trialindex_sim = 1:NTrials
    % first, set the event marker channel to zero
%     fprintf(s3, '00');

    %Select the stimulus pair
    if pairlabelvec(trialindex_sim) == 1
        counterA = counterA+1;
        TrialPicturePath1 =  eval(['roles.A.imgPaths{' num2str(counterA) '}']);
        counterB = counterB+1;
        TrialPicturePath2 =  eval(['roles.B.imgPaths{' num2str(counterB) '}']);
    elseif pairlabelvec(trialindex_sim) == 2
        counterB = counterB+1;
        TrialPicturePath1 =  eval(['roles.B.imgPaths{' num2str(counterB) '}']);
        counterC = counterC+1;
        TrialPicturePath2 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
    elseif pairlabelvec(trialindex_sim) == 3
        counterC = counterC+1;
        TrialPicturePath1 =  eval(['roles.C.imgPaths{' num2str(counterC) '}']);
        counterD = counterD+1;
        TrialPicturePath2 =  eval(['roles.D.imgPaths{' num2str(counterD) '}']);
    elseif pairlabelvec(trialindex_sim) == 4
        counterD = counterD+1;
        TrialPicturePath1 =  eval(['roles.D.imgPaths{' num2str(counterD) '}']);
        counterE = counterE+1;
        TrialPicturePath2 =  eval(['roles.E.imgPaths{' num2str(counterE) '}']);
    end

    % make the corresponding textures
    [~, currentfile1] = fileparts(TrialPicturePath1);
    [~, currentfile2] = fileparts(TrialPicturePath2);

    TrialPicture1 = imread(TrialPicturePath1);
    TrialPicture1 = imresize(TrialPicture1, .5);
    TrialTex1=Screen('MakeTexture', win, TrialPicture1);

    TrialPicture2 = imread(TrialPicturePath2);
    TrialPicture2 = imresize(TrialPicture2, .5);
    TrialTex2=Screen('MakeTexture', win, TrialPicture2);

    % response phase: images + slider together, wait for click
    ShowCursor('Arrow', win);
    responseMade = false;
    tStart = GetSecs;

    while ~responseMade
        [mx, ~, buttons] = GetMouse(win);

        % constrain mouse x to the slider's range
        if mx < sliderXcenter - sliderWidth/2, mx = sliderXcenter - sliderWidth/2; end
        if mx > sliderXcenter + sliderWidth/2, mx = sliderXcenter + sliderWidth/2; end
        fillWidth = mx - (sliderXcenter - sliderWidth/2);

        if switchsidevec(trialindex_sim) == 1
            Screen('DrawTexture', win, TrialTex1, [], leftRect);
            Screen('DrawTexture', win, TrialTex2, [], rightRect);
        else
            Screen('DrawTexture', win, TrialTex1, [], rightRect);
            Screen('DrawTexture', win, TrialTex2, [], leftRect);
        end

        Screen('FillOval', win, 255, fix_cord);
        DrawFormattedText(win, 'How similar are these pictures based on the meaning they convey??', 'center', cy - 350, 255);

        drawSimSlider(win, sliderRect, sliderBgColor, locationPosTick, ...
            sliderWidth, sliderHeight, sliderXcenter, sliderY, locMarkerColor, fillWidth);

        Screen('Flip', win);

        if any(buttons)
            sliderLeft = sliderXcenter - sliderWidth/2;
            normPos = (mx - sliderLeft) / sliderWidth;
            [~, choiceLoc] = min(abs(locationPosFrac - normPos));
            simresponse = choiceLoc - 1;     % 0-9 scale
            responsecont = mx;
            thisRT = GetSecs - tStart;
            responseMade = true;
        end

        WaitSecs(0.03);
    end

    HideCursor(win);
    Screen('Close', [TrialTex1 TrialTex2]);   % release these two textures now that the trial is done


    % log this trial
    fprintf(datafilepointerrate, '%i %i %s %s %i %i %i %i %i \n', ...
        subjectNumber, ...
        trialindex_sim, ...
        currentfile1, ...
        currentfile2, ...
        pairlabelvec(trialindex_sim), ...
        switchsidevec(trialindex_sim), ...
        simresponse, ...
        responsecont, ...
        thisRT);
end
end



%%
function drawSimSlider(win, sliderRect, bgColor, locationPosTick, ...
    sliderWidth, sliderHeight, sliderXcenter, sliderY, locColor, fillWidth)

% slider background bar
Screen('FillRect', win, bgColor, sliderRect);

% red fill tracking the mouse position
fillWidth = max(0, fillWidth);
fillRect = [sliderRect(1) sliderRect(2) sliderRect(1)+fillWidth sliderRect(4)];
Screen('FillRect', win, [255 0 0], fillRect);

% green tick markers at 0%, 50%, 100%
sliderLeft = sliderXcenter - sliderWidth/2;
for i = 1:length(locationPosTick)
    xPos = sliderLeft + sliderWidth * locationPosTick(i);
    lineRect = [xPos-1 sliderY-30 xPos+1 sliderY+sliderHeight+15];
    Screen('FillRect', win, locColor, lineRect);
end

% labels under the 0%/50%/100% ticks
labels = {'0% similar', '', '100% similar'};
for i = 1:length(locationPosTick)
    xPos = sliderLeft + sliderWidth * locationPosTick(i);
    DrawFormattedText(win, labels{i}, round(xPos)-60, sliderY+sliderHeight+50, locColor);
end

end
