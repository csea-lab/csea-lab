function condiCRS(subNo)

clc;
rand('state', sum(100*clock));

AssertOpenGL;

durationgabor = .1;
durationscreen = .1;
contrast = .3;

% open serial port for trigger writing
%s3 = serial('com3'); % on PC only
%fopen(s3)

% files
datafilename = strcat('condiCRS_',num2str(subNo),'.dat'); % name of data file to write to

%US white noise

%[soundvec, fs] = wavread('C:\Users\basic\Documents\As_Exps\mp_gabor\stimuli\whitenoise.wav');
%p = audioplayer(soundvec, fs); 

% Prevent accidentally overwriting data (except for subject numbers > 99)
if subNo < 99 && fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Result data file exists!');
else
    datafilepointer = fopen(datafilename, 'wt');
end


try
    screens = Screen('Screens');
    screenNumber = max(screens);
    
    HideCursor;
    
    gray = GrayIndex(screenNumber);
    [w, wRect]=Screen('OpenWindow', screenNumber, gray, [], 32);
    
    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % tilting - Right or left (randomization)
    thetaindex = [20 -20];
    thetaindexvec = repmat(thetaindex,1,110); % 110
    
    %contrast
    contrasts =  [ 0 0 0 round(exp(4.5:.43:7.7))./100] % in percent ... will be divided by 100 below
    contrastindexvec = repmat(contrasts,1,20); % to test:3 ; should be 20
    
    % use same random permutation on both vectors such that all contrast
    % occur equally often in each orientation
    randvec = randperm(220) % to test: 20 should be 220
    theta = thetaindexvec(randvec);
    contrast = contrastindexvec(randvec);
    ntrials = length(theta);
    
    % here: determine the gabor patch
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    gray = (white+black)/2;
    inc = white-gray;
    
    mask = rand(201,201);
    [x,y] = meshgrid(-100:100, -100:100);
    m2 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(20*pi/180)*(2*pi*0.02)*x + sin(20*pi/180)*(2*pi*0.02)*y));
    m1 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(-20*pi/180)*(2*pi*0.02)*x + sin(-20*pi/180)*(2*pi*0.02)*y));
    % here : add mouse click to start
    % write message to subject
    Screen('DrawText', w, 'Welcome to the experiment. Today, please click left when you see a pattern as shown below, between the gray squares.', 10, 10, 255);
    Screen('DrawText', w, 'Please click the right mouse button when you do not see a pattern. if nothing happens, click right again.', 10, 60, 255);
    Screen('DrawText', w, 'If you are not sure, please guess. Some patterns will be hard to see, but you will get a chance to practice.', 10, 120, 255);
    Screen('PutImage', w, gray+inc*(30./100)*m1,[480,400, 680, 600]);
    Screen('PutImage', w, gray+inc*(30./100)*m2,[780,400, 980, 600]);
    Screen('DrawText', w, 'Please press mouse key to start practicing...', 10, 900, 255);
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
    WaitSecs(rand(1,1)* + 4);
    
    for trial = 1:12
        % Fixation cross
        Screen('TextSize', w, 22);
        Screen('PutImage', w, gray+inc*mask);
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)*1.5+1.7);
        
        % Draw tilted Low spatial frequency gabor patch (2cpd): 6 cycles per 3 degree (visual angle)
        Screen('FillRect', w, gray);
        [x,y] = meshgrid(-100:100, -100:100);
        m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.02)*x + sin(theta(trial)*pi/180)*(2*pi*0.02)*y));
        
        % first, assign default values to 'buttons(mouse)' & 'response'
        buttons=0;
        respvec = 0;
        checkvec = 0;
        
        Screen('PutImage', w, gray+inc*(contrast(trial)./100)*m);
        [dummy, startrt] = Screen('Flip', w); 
        WaitSecs(durationgabor+.05);
        Screen('PutImage', w, gray+inc*mask);
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip',w);
        while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse;
            if any(buttons) % wait for press
                respvec = buttons; pressed=GetSecs;
            end
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
        end
        
        
    end   % trial
    
    % clear screen
    Screen('Flip', w);
    
    % wait a bit before starting trial
    WaitSecs(rand(1,1)* + 4);
    
    
    % write message to subject
    Screen('DrawText', w, 'Thank you. Please click the mouse to begin the experiment...', 10, 10, 255);
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
    WaitSecs(rand(1,1)* + 4);
    
    
    % @@@@@@@ 1 @@@ baseline CRF

    block = 1;
  
    for trial = 1:ntrials
        % Fixation cross
        Screen('TextSize', w, 22);
        Screen('PutImage', w, gray+inc*mask);         DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)*1.5+1.5);
        
        
        % Draw tilted Low spatial frequency gabor patch (2cpd): 6 cycles per 3 degree (visual angle)
        Screen('FillRect', w, gray);
        [x,y] = meshgrid(-100:100, -100:100);
        m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.02)*x + sin(theta(trial)*pi/180)*(2*pi*0.02)*y));         
        
        % first, assign default values to 'buttons(mouse)' & 'response'
        buttons=0;
        respvec = 0;
        checkvec = 0;
           
        
        % fprintf(s3, 'TT');
        Screen('PutImage', w, gray+inc*(contrast(trial)./100)*m);
        [dummy, startrt] = Screen('Flip', w);
        WaitSecs(durationgabor);
        Screen('PutImage', w, gray+inc*mask);         DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip',w);
        while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse;
            if any(buttons) % wait for press
                respvec = buttons; pressed=GetSecs;
            end
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
        end
        
        
        if length(respvec) == 3
            rt = round(1000*(pressed-startrt));
            if respvec == [1 0 0]
                resp(trial) = 1; % left mouse
            elseif respvec == [0 0 1]
                resp(trial) = 2; % right mouse
            end
        else resp(trial) = 0; rt =0; % caution: in case of 'no' clicks!
        end
        disp(resp);
        
        
        
        %% compute accuracy
        if ( resp(trial) == 1 & contrast(trial) > 0 )
            ac = 'A';
        elseif ( resp(trial) == 2 & contrast(trial) == 0 )
            ac = 'A';
        else
            ac = 'I';
        end
        
        
        %% Write results to file
        fprintf(datafilepointer,'%i %i %i %i %i %i %i %s \n', ...
            subNo, ...
            block, ...
            trial, ...
            theta(trial), ... % orientation of gabor patch
            resp(trial), ... % main response
            contrast(trial), ...
            rt,...
            ac);
        
    end   % trial
    
    % Fixation cross
    Screen('TextSize', w, 22);
    Screen('PutImage', w, gray+inc*mask);
    DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
    Screen('Flip', w);
    WaitSecs(rand(1,1)*1.2+1.4);
    
    
    % @@@@ 2 @@@@@  conditioning phase
    
    % write message to subject
    Screen('DrawText', w, 'You may now hear occasional loud noises, and some of the patterns will be visible', 10, 10, 255);
    Screen('DrawText', w, 'for longer durations. Please click to continue ...', 10, 60, 255);
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
    WaitSecs(rand(1,1)* + 5);
    
    USvec = [ 1 0 1 1 0 0 1 0 1 0 0 1 0 0 1 1 0 1];
    
    for conditrial = 1: 12
        
        if USvec(conditrial)
            th = 20
        else
            th = -20
        end
        
        [x,y] = meshgrid(-100:100, -100:100);
        m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(th*pi/180)*(2*pi*0.02)*x + sin(th*pi/180)*(2*pi*0.02)*y));
        
        
        % Fixation cross
        Screen('TextSize', w, 22);
        Screen('PutImage', w, gray+inc*mask);         
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)*1.5+1.5);
        
        Screen('PutImage', w, gray+inc*(9.3./100)*m);
        Screen('Flip', w);
        WaitSecs(1.5);
        if USvec(conditrial)
           play(p)
        end
        Screen('PutImage', w, gray+inc*(9.3./100)*m);
        Screen('Flip', w);
        waitsecs(1.0)
        
        % Fixation cross
        Screen('TextSize', w, 22);
        Screen('PutImage', w, gray+inc*mask);
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)*1.5+1.5);
        
        
    end
    
    Screen('Flip', w);
    
    % write message to subject
    Screen('DrawText', w, 'Now the patterns will appear rapidly again, and there still will be occasional noises.', 10, 10, 255);
    Screen('DrawText', w, 'Please click to continue ...', 10, 60, 255);
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
    WaitSecs(rand(1,1)* + 3);
    
    
    
    % @@@@@@ 3 @@@@@@@ intermittent phase
    block = 2
    conditrials = [8 17 40 69 84 100 125 135];
    safetrials =[4 25 50 88 91 108 119 140];
    
    for trial = 1:ntrials
        
        % Draw tilted Low spatial frequency gabor patch (2cpd): 6 cycles per 3 degree (visual angle)
        Screen('FillRect', w, gray);
        [x,y] = meshgrid(-100:100, -100:100);
        m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.02)*x + sin(theta(trial)*pi/180)*(2*pi*0.02)*y));
        
        m1 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(5*pi/180)*(2*pi*0.02)*x + sin(5*pi/180)*(2*pi*0.02)*y));
        m2 = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(-5*pi/180)*(2*pi*0.02)*x + sin(-5*pi/180)*(2*pi*0.02)*y));
        
        if ismember(trial, conditrials)
            Screen('PutImage', w, gray+inc*(9.3./100)*m1);
            DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
            Screen('Flip', w);
            WaitSecs(1.5);
            if USvec(conditrial)
                play(p)
            end
            Screen('PutImage', w, gray+inc*(9.3./100)*m1);
            DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
            Screen('Flip', w);
            WaitSecs(3.5);
        elseif ismember(trial, safetrials)
            Screen('PutImage', w, gray+inc*(9.3./100)*m2);
            DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
            Screen('Flip', w);
            WaitSecs(3.5);
        end
        
        
        % Fixation cross
        Screen('TextSize', w, 22);
        Screen('PutImage', w, gray+inc*mask);
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip', w);
        WaitSecs(rand(1,1)*1.3+1.3);        
        
        % Draw tilted Low spatial frequency gabor patch (2cpd): 6 cycles per 3 degree (visual angle)
        Screen('FillRect', w, gray);
        [x,y] = meshgrid(-100:100, -100:100);
        m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.02)*x + sin(theta(trial)*pi/180)*(2*pi*0.02)*y));
                
        % first, assign default values to 'buttons(mouse)' & 'response'
        buttons=0;
        respvec = 0;
        checkvec = 0;
              
        %  fprintf(s3, 'TT');
        Screen('PutImage', w, gray+inc*(contrast(trial)./100)*m);
        [dummy, startrt] = Screen('Flip', w);
        WaitSecs(durationgabor);
        Screen('PutImage', w, gray+inc*mask);
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
        Screen('Flip',w);
        
        % get the mouse-clicking responses
        while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse;
            if any(buttons) % wait for press
                respvec = buttons; pressed=GetSecs;
            end
            % Wait 10 ms before checking the mouse again to prevent
            % overload of the machine at elevated Priority()
            WaitSecs(0.01);
        end
        
      
        
        if length(respvec) == 3
            rt = round(1000*(pressed-startrt));
            if respvec == [1 0 0]
                resp(trial) = 1; % left mouse
            elseif respvec == [0 0 1]
                resp(trial) = 2; % right mouse
            end
        else resp(trial) = 0; rt =0; % caution: in case of 'no' clicks!
        end
        
        
        
        %% compute accuracy
        if ( resp(trial) == 1 & contrast(trial) > 0 )
            ac = 'A';
        elseif ( resp(trial) == 2 & contrast(trial) == 0 )
            ac = 'A';
        else
            ac = 'I';
        end
        
        
        %% Write results to file
        fprintf(datafilepointer,'%i %i %i %i %i %i %i %s \n', ...
            subNo, ...
            block, ...
            trial, ...
            theta(trial), ... % orientation of gabor patch
            resp(trial), ... % main response
            contrast(trial), ...
            rt,...
            ac);
        
    end   % trial
    
     
    % write message to subject
    Screen('DrawText', w, 'Thank you very much for participating!', 10, 10, 255);
    Screen('DrawText', w, 'The experimenter will be with you shortly...', 10, 60, 255);
    Screen('Flip', w); % show text
    
    % wait for mouse press ( no GetClicks  :(  )
    buttons=0;
    while ~any(buttons) % wait for press
        [xm,ym,buttons] = GetMouse;
        % Wait 10 ms before checking the mouse again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.01);
    end
    
     Screen('Flip', w);
     waitsecs(1)
     
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
    
    %  fclose(s3);
    psychrethrow(psychlasterror);
end
