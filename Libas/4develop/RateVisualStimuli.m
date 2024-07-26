%% VISUAL STIMULI RATING FUNCTION %%
function [XXX] = RateVisualStimuli(SubNo, Stimuli, Average_US_Level)
% Function that will assess SAM ratings for individual visual stimuli.

% Create Screen Settings       
AssertOpenGL; % Checks to make sure Psychtoolbox is based on OpenGL or Screen() 
Screen('Preference', 'SkipSyncTests', 1); % Does not skip the Sync Test
fullscreen = 1; % Sets fullscreen value to 1 (i.e., correct)
screens = Screen('Screens'); % Creates a variable corresponding to the number of available physical display(s)
screenNum = max(screens); % Creates a variable of the maximum number of displays

if fullscreen == 1 % Loop to create window if fullscreen is true
    [window, rect] = Screen('OpenWindow', screenNum); % Opens screen number 1   
else
    [window, rect] = Screen('OpenWindow', screenNum,[0,0,0],screensize); % Opens screen if not fullsized window
end

black = BlackIndex(window); % Generates pixel value for black color
white = WhiteIndex(window); % Generates pixel value for white color
gray = GrayIndex(window); % Generates pixel value for gray color

[x,y] = Screen('WindowSize',screenNum); % grabs the x and y coordinates
centerhori = x/2; % creates the x midpoint of the screen
centerverti = y/2; % creates the y midpoint of the screen
Screen('FillRect', window, gray, rect); % Fills the screen with a gray background
Screen('Flip', window); % Shows the screen

% Create Font Parameters
FontSize = 32; % Sets font size
FontStyle = 'Arial'; % Sets font character type
FontColor = black; % Sets font color to black
Screen('TextSize', window, FontSize); % Sets font size based on earlier parameter
Screen('TextFont', window, FontStyle); % Sets font character type based on earlier parameter
Screen('TextColor', window, FontColor); % Sets font color based on earlier parameter

WelcomeText = ['You will now be presented with a loud sound.\n\n\n'... % Creates text message for welcome screen
                'After hearing this sound, you will be asked to rate this sound in terms of\n\n'...
                'how UNPLESANT and how INTENSE/AROUSING the sound was to you.\n\n\n'...
                'You will use your mouse and an image provided as a guide to make your ratings.\n\n'...
                'There are no correct or incorrect answers, so you may answer how you feel.\n\n\n'...
                'Press any button when you are ready to hear the sound'];
            
ValenceText = ['Using the images below, how UNPLEASANT was this sound?\n\n'...
               'Click on the figure that best represents your rating.']; % Creates text message for valence rating screen
ArousalText = ['Using the images below, how INTENSE or AROUSING was this sound?\n\n'...
               'Click on the figure that best represents your rating.']; % Creates text message for arousal rating screen
          
% Image filepaths
val_img = imread('/home/andreaskeil/Desktop/As_Exps/valence.png'); % Loads picture in filepath for valence
aro_img = imread('/home/andreaskeil/Desktop/As_Exps/arousal.png'); % Loads picture in filepath for arousal
exp_img = imread('/home/andreaskeil/Desktop/As_Exps/expectancy.png'); % Loads picture in filepath for expectancy






texPre = Screen('MakeTexture', window, pre_img); % Prepares prediction texture image for presentation

% Creates a vector for each rating question 
textVec = {ValenceText; ...
           ArousalText; ...
           PredictText};
       
% Creates a vector for each pre-task US rating questions
textVecUS = {'Using the images below, how UNPLEASANT was the electrical shock?'; ...
             'Using the images below, how INTENSE or AROUSING was the electrical shock?'; ...
             'Using the images below, how LIKELY is the electrical shock to occur?'};


         
         

% Creates a vector for each rating question 
textVec = {ValenceText, ArousalText}; % Creates vector for text prompts

% Creates a vector for each rating image   
textureVec = {val_img, aro_img}; % Creates vector for image filepaths

% Creates a vector for recording
RatingIndex = [{'Valence_US'}, {'Arousal_US'}]; % Vector of ratinging indices

% Create empty vectors for Valence and Arousal ratings
ValenceRate = []; % Empty valence ratings
ArousalRate = []; % Empty arousal ratings

% Randomize SAM order
rand_vec_me = randperm(numel(textVec)); % Creates random permuations based on vector length
textVec = textVec(rand_vec_me); % Save text vector based on randomization
textureVec = textureVec(rand_vec_me); % Save texture vector based on randomization
RatingIndex = RatingIndex(rand_vec_me); % Save rating index vector based on randomization

% Present Instruction Screen
DrawFormattedText(window, WelcomeText, 'center', 'center'); % Write the text line on the screen
HideCursor(0,0) % hides the cursor (second part) for the associated screen (first part)
Screen('Flip', window); % Shows text line

% Click to Continue
clicks = 0; % Set click value to 0
while ~any(clicks) % While no clicks are made
    [clicks, ~, ~, ~] = GetClicks(); % GetClicks function to get clicks
    WaitSecs(0.01); % Wait 10ms before checking mouse again to prevent overload of machine
end  

% Show Fixation ITI
Screen('FillOval', window, black ,[centerhori-10 centerverti-10 centerhori+10 centerverti+10]); % Creates a fixation dot +/- 10 pixels of the middle x and y coordinates
Screen('Flip', window); % Removes the text and shows the fixation dot

% Auditory US % US ratings .dat file log information
Valence_US = USratingMat(1); % Grabs the first column (i.e., valence)
Arousal_US = USratingMat(2); % Grabs the second column (i.e., arousal)
Expectancy_US = USratingMat(3); % Grabs the third column (i.e., expectancy)
dlmwrite(USratFileName, [SubNo, Counter, Valence_US, Arousal_US, Expectancy_US], '-append'); % Saves US rating file


Presentation
WaitSecs(1); % Wait 1 second following mouse click to play the sound
playblocking(Auditory_US) % Plays pitch
WaitSecs(0.1) % Waits 100 ms following sound

% Loop Through Ratings Questions
for i = 1:2 % Loop through all rating images
    RateText = char(textVec{i}); % Make rating text in line with randomization
    ImageMe = cell2mat(textureVec(i)); % Grab randomized image rating
    RateImg = Screen('MakeTexture', window, ImageMe); % Make a texture out of rating image

    % Show Rating Prompt
    RatingType = RatingIndex(i); % Update rating type based on randomization order
    DrawFormattedText(window, RateText, 'center', 200); 
    Screen('DrawTexture', window, RateImg)
    SetMouse(centerhori,centerverti); % Sets mouse to the center of the screen
    ShowCursor(0,0,0); % Show mouse cursor with simple arrow
    Screen('Flip', window); % show text and image

    % Click to Make Response
    clicks = 0; % Set click value to 0
    while ~any(clicks) % While
        [clicks, RatingX(i), ~, ~] = GetClicks(); % GetClicks function to get clicks
        WaitSecs(0.01); % Wait 10ms before checking mouse again to prevent overload of machine
    end   
    
    % Assess Rating Type
    if strcmp(char(RatingIndex{1,i}), 'Valence_US') == 1 % if the current RatingIndex is for Valence
        ValenceRate = RatingX(i); % Grab the valence rating in terms of x-axis pixel selected
    elseif strcmp(char(RatingIndex{1,i}), 'Arousal_US') == 1 % if the current RatingIndex is for Arousal
        ArousalRate = RatingX(i); % Grab the valence rating in terms of x-axis pixel selected
    end

end % Ends Rating Loop

% Record Rating Information from Trial 
RateAuditoryUS = [ValenceRate, ArousalRate]; % Save RateAuditoryUS output (Valence first, Arousal second)
    
end % Ends RateAuditoryUS Function