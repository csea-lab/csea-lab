function [  ] = psytest(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 
Screen('Preference', 'SkipSyncTests', 1);

     screens=Screen('Screens');
    screenNumber=max(screens);

    HideCursor;

    % Open a double buffered fullscreen window and draw a black background
    % to front and back buffers:
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);

    % returns as default the mean gray value of screen
    black=BlackIndex(screenNumber);

    Screen('FillRect',w, black);
    Screen('Flip', w);
 Screen('TextSize', w, 22);
 
          DrawFormattedText(w,'coherent motion?','Center','Center',WhiteIndex(w));
         
          startquery = Screen('Flip', w);
    
            % wait for mouse press
            buttons=0;
            while ~any(buttons) && GetSecs-startquery< 4% wait for press
             [x,y,buttons] = GetMouse;
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
            end
            respvec = buttons; pressed=GetSecs;   
             Screen('Flip', w);

