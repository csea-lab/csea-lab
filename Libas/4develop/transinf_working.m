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
%   1. Baseline 1        – passive viewing (500 ms stim, jittered ITI 1-3 s)
%   2. Similarity Ratings 1  – PLACEHOLDER (calls similarityRatings())
%   3. Learning          – A+/B-, B+/C-, C+/D-, D+/E- with feedback
%   4. Testing           – A/E, C/C, D/D, B/D; no feedback
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
rng(subjectNumber * cbOrder);          % reproducible randomisation per subject
KbName('UnifyKeyNames');

% Locate stimuli parent folder (sibling of this .m file)
scriptDir   = fileparts(mfilename('fullpath'));
stimuliDir  = fullfile(scriptDir, 'stimuli');

% Output directory
dataDir = fullfile(scriptDir, 'data');
if ~exist(dataDir, 'dir'), mkdir(dataDir); end
dataFile = fullfile(dataDir, sprintf('sub-%03d_transinf.csv', subjectNumber));

%% =========================================================
%  1.  CATEGORY / COUNTERBALANCING SETUP
%% =========================================================
% Physical category folder names (must match folders inside stimuli/)
allCategoryFolders = {'tundra', 'mountains', 'desert', 'forest', 'grasslands'};
nCategories        = numel(allCategoryFolders);   % 5
nImgsPerCat        = 10;

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
Screen('TextSize',  win, 48);
Screen('TextStyle', win, 1);   % bold

% Timing constants (seconds)
BASELINE_STIM_DUR   = 0.500;
BASELINE_ITI_MIN    = 1.0;
BASELINE_ITI_MAX    = 3.0;
LEARNING_MAX_RT     = 1.000;   % images stay on until response OR this limit
LEARNING_ITI_MIN    = 2.0;
LEARNING_ITI_MAX    = 4.0;
FEEDBACK_DUR        = 0.500;
TEST_MAX_RT         = 1.000;

% Mouse / response
ShowCursor('Arrow', win);
SetMouse(cx, cy, win);   % park cursor at centre between trials

%% =========================================================
%  4.  DATA LOG INITIALISATION
%% =========================================================
% Pre-allocate a struct-array; we append rows as we go and write CSV at end
dataLog = struct('subjectNumber',{}, 'phase',{}, 'block',{}, 'trialNumber',{}, ...
                 'catRoleLeft',{},   'catRoleRight',{}, ...
                 'catNameLeft',{},   'catNameRight',{}, ...
                 'imgFileLeft',{},   'imgFileRight',{}, ...
                 'correctSide',{},   'responseSide',{}, ...
                 'correct',{},       'RT_ms',{},         'feedback',{});
logIdx = 0;

 HideCursor(0,0);
%% =========================================================
%  5.  Baseline 1
%% =========================================================
% write message to subject
Screen('DrawText', w, 'The experiment will begin shortly ... ', cx-120, cy, 255);
Screen('Flip', w); % show text
KbStrokeWait;
% clear screen
Screen('Flip', w);

% randomization
Rolenamevec_randomized = []; 
NTrials = nCategories*nImgsPerCat; 
for randoloop = 1:nImgsPerCat
    Rolenamevec_randomized = [Rolenamevec_randomized roleLabels(randperm(nCategories))];
end

for trialindex_bsl1 = 1:nCategories*nImgsPerCat

%fixation cross
 Screen('FillOval', w, 255 ,[cx-5 cy-5 cx+5 cy+5]);
Screen('Flip', w);
 WaitSecs(BASELINE_ITI_MIN + rand(1,1) * (BASELINE_ITI_MAX-BASELINE_ITI_MIN)) % ITI between 1 and 3 secs, uniform

TrialPicturePath =  eval(['roles.' char(Rolenamevec_randomized(trialindex_bsl1)) '.imgPaths{' num2str(counter) '}']);
TrialPicture = imread(TrialPicturePath); 

% WaitSecs(BASELINE_STIM_DUR)

end

% wait a bit before starting trial
WaitSecs(1.000);


end % function transinf