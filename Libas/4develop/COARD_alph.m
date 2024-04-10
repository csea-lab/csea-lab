function COARD_alph(subNo)


% Initialize Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); % Skip synchronization tests for now, remove this line if timing precision is crucial

% Get screen number
screens = Screen('Screens');
screenNumber = max(screens);

% Open window with black background
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0);

% Set text parameters
Screen('TextSize', window, 24);
Screen('TextColor', window, [255 255 255]);
Screen('TextFont', window, 'Arial');

% Get the center coordinates of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Greet the participant
DrawFormattedText(window, 'Welcome to the Experiment!', 'center', 'center', [255 255 255]);
Screen('Flip', window);
WaitSecs(3);

% Define fixation cross parameters
fixCrossDimPix = 40;
fixCrossCoords = [-fixCrossDimPix fixCrossDimPix 0 0; 0 0 -fixCrossDimPix fixCrossDimPix];

% Loop through the experiment
for trial = 1:2
    % Display fixation cross
    Screen('DrawLines', window, fixCrossCoords, 2, [255 255 255], [xCenter yCenter]);
    Screen('Flip', window);
    WaitSecs(2);
    
    % Play soft tone and display text
    sound(sin(2*pi*440*(0:1/44100:2)), 44100);
    DrawFormattedText(window, 'Please close your eyes now', 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    WaitSecs(2);
    Screen('DrawLines', window, fixCrossCoords, 2, [255 255 255], [xCenter yCenter]);
    Screen('Flip', window);
    WaitSecs(60);
    
    
    % Play soft tone and display text
    sound(sin(2*pi*440*(0:1/44100:2)), 44100);
    DrawFormattedText(window, 'Please open your eyes and keep your gaze on the central fixation cross', 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    WaitSecs(2);
    Screen('DrawLines', window, fixCrossCoords, 2, [255 255 255], [xCenter yCenter]);
    Screen('Flip', window);
    WaitSecs(60);
      
end

% End of experiment
DrawFormattedText(window, 'End of Task 1. Thank you!', 'center', 'center', [255 255 255]);
Screen('Flip', window);
WaitSecs(3);

% Close the window
sca;