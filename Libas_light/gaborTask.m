function gaborTask(subNo)

clc;
rand('state', sum(100*clock));

AssertOpenGL;

% duration of cues and probes (only probes are flickering!)
durationcue = 1;
durationprobe = .02;
durationscreen = .035;

% open serial port for trigger writing
% s3 = serial('com3'); % on PC only
% fopen(s3)

% files
datafilename = strcat('gaborTask_',num2str(subNo),'.dat'); % name of data file to write to

% Prevent accidentally overwriting data (except for subject numbers > 99)
if subNo < 99 && fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Result data file exists!');
else
    datafilepointer = fopen(datafilename, 'wt');
end

% Experiment start: try ...and... catch
try
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    HideCursor;
    % Get Screen with fixation cross on gray background
    gray = GrayIndex(screenNumber);
    [w, wRect]=Screen('OpenWindow', screenNumber, gray, [], 32);
    Screen('TextSize', w, 22);
    DrawFormattedText(w,'+','Center','Center',WhiteIndex(w));
    
    [center(1), center(2)] = RectCenter(wRect);
    
    dot_w = 0.2;        % width of dot (deg)
    mon_width = 39;   % horizontal dimension of viewable screen (cm)
    v_dist = 60;   % viewing distance (cm)
    ppd = pi * (wRect(3)-wRect(1)) / atan(mon_width/v_dist/2) / 360;
    s = dot_w * ppd;
    
    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % Randomization of cues
    tempvector = [ones(1,5) ones(1,5).*2];
    ntrials = length(tempvector);
    cuevector = tempvector(randperm(ntrials));
    
    % taskCue (No-task/Detection task conditions)
    taskvector = [ones(1,4) ones(1,1).*2];
    ntasks = length(taskvector);
    taskCuevec = taskvector(randperm(ntasks));
    halfindex = 0;
    
    % Tilting - Right or left
    thetaindex = [2 -2];
    thetaindexvec = repmat(thetaindex,1,10);
    theta = thetaindexvec(randperm(10));
    
    % here: determine the gray etc
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    gray = (white+black)/2;
    inc = white-gray;
    gray_change = gray*1.05; % background change
    
    % here : add mouse click to start
    % write message to subject
    Screen('DrawText', w, 'Please press mouse key to start ...', 10, 10, 255);
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
    WaitSecs(1);
    % WaitSecs(rand(1,1)* + 9);
    
    for trial = 1:ntrials
        
        
        % Draw Cues that indicate either No task or Secondary task
        if cuevector(trial) == 1  % no task (10% of target detection tasks)
        halfindex = halfindex +1;     
            
            DrawFormattedText(w,'o','Center','Center',WhiteIndex(w));
            Screen('Flip',w);
            %             fprintf(s3, 'TT')
            WaitSecs(durationcue);
            
            WaitSecs(.6)  % ITI
            
            [VBLTimestamp startrt] = Screen('Flip',w);
            
            
            Screen('FillRect', w, gray);
            [x,y] = meshgrid(-100:100, -100:100);
            
            
            buttons=0;
            respvec = 0;
            
            
            
            if taskCuevec(halfindex) == 1   % no task at all!
                % now, ready for flickering gabor patch with incremental
                % changes in contrast
                
                m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(halfindex)*pi/180)*(2*pi*0.03)*x + sin(theta(halfindex)*pi/180)*(2*pi*0.03)*y));
                
                for flicker = 1:40
                    Screen('PutImage', w, gray+inc*(flicker/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('Flip',w);
                    WaitSecs(durationscreen);
                end
                
                for flicker = 1:40
                    Screen('PutImage', w, gray-inc*((flicker-40)/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('Flip',w);
                    WaitSecs(durationscreen);
                    % get the mouse-clicking responses
                    [x,y,buttons] = GetMouse;
                    
                    if any(buttons) % wait for press
                        respvec = buttons; pressed=GetSecs;
                    end
                end
                disp(respvec);
                
                if length(respvec) == 3
                    rt = round(1000*(pressed-startrt));
                    
                    if ( (respvec == [1 0 0]) | (respvec == [0 0 1]) )
                        resp(trial) = 9;
                    end
                    disp(resp);
                    
                    % caution: in case of 'no' clicks!
                else resp(trial) = 0; rt =0; disp(resp);
                end
                
          
                
                
            else %taskCuevec(halfindex) == 2  % Background change detection task
                
                m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(halfindex)*pi/180)*(2*pi*0.03)*x + sin(theta(halfindex)*pi/180)*(2*pi*0.03)*y));
                
                % first, assign default values to 'buttons(mouse)' & 'response'
                
                for flicker = 1:34
                    Screen('PutImage', w, gray+inc*(flicker/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('Flip',w);
                    WaitSecs(durationscreen);
                end
                
                for flicker = 35:37
                    Screen('PutImage', w, gray+inc*(flicker/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('FillRect',w, gray_change);
                    Screen('Flip', w);
                    WaitSecs(durationscreen);
                    % get the mouse-clicking responses
                    [x,y,buttons] = GetMouse;
                    
                    if any(buttons) % wait for press
                        respvec = buttons; pressed=GetSecs;
                    end
                end
                disp(respvec);
                
                
                for flicker = 38:40
                    Screen('PutImage', w, gray+inc*(flicker/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('FillRect',w, gray);
                    Screen('Flip', w);
                    WaitSecs(durationscreen);
                    % get the mouse-clicking responses
                    [x,y,buttons] = GetMouse;
                    
                    if any(buttons) % wait for press
                        respvec = buttons; pressed=GetSecs;
                    end
                end
                disp(respvec);
                
                
                for flicker = 1:40
                    Screen('PutImage', w, gray-inc*((flicker-40)/270*4/3+.005)*m);
                    Screen('Flip', w);
                    WaitSecs(durationprobe);
                    Screen('Flip',w);
                    WaitSecs(durationscreen);
                    % get the mouse-clicking responses
                    [x,y,buttons] = GetMouse;
                    
                    if any(buttons) % wait for press
                        respvec = buttons; pressed=GetSecs;
                    end
                end
                disp(respvec);
                
                if length(respvec) == 3
                    rt = round(1000*(pressed-startrt));
                    
                    if ( (respvec == [1 0 0]) | (respvec == [0 0 1]) )
                        resp(trial) = 1;
                    end
                    disp(resp);
                    
                    % caution: in case of 'no' clicks!
                else resp(trial) = 0; rt =0; disp(resp);
                end
                
               
                
            end
            
     
            
        else % cuevector(trial) == 2 (same orientation discrimination task)
            Screen('DrawDots', w, [0 0], s, white, center,1);
            Screen('Flip',w);
            %             fprintf(s3, 'TT')
            WaitSecs(durationcue);
            
            WaitSecs(.6);  % ITI
            
            [VBLTimestamp startrt] = Screen('Flip',w);
            
            %             Screen('FillRect', w, gray);
            [x,y] = meshgrid(-100:100, -100:100);
            m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.03)*x + sin(theta(trial)*pi/180)*(2*pi*0.03)*y));
            
            % change levels of contrast
            
            % first, assign default values to 'buttons(mouse)' & 'response'
            buttons=0;
            discvec = 0;
            checkvec = 0;
            
            % now, ready for flickering gabor patch with incremental
            % changes in contrast
            for flicker = 1:40
                Screen('PutImage', w, gray+inc*(flicker/270*4/3+.005)*m);
                Screen('Flip', w);
                WaitSecs(durationprobe);
                Screen('Flip',w);
                WaitSecs(durationscreen);
                % get the mouse-clicking responses
                [x,y,buttons] = GetMouse;
                
                if any(buttons) % wait for press
                    discvec = buttons; pressed=GetSecs;
                end
                
            end
            
            disp(discvec);
            
            for flicker = 1:40
                Screen('PutImage', w, gray-inc*((flicker-40)/270*4/3+.005)*m);
                Screen('Flip', w);
                WaitSecs(durationprobe);
                Screen('Flip',w);
                WaitSecs(durationscreen);
                % get the mouse-clicking responses
                [x,y,buttons] = GetMouse;
                
                if any(buttons) % wait for press
                    checkvec = buttons; pressed=GetSecs;
                end
            end
            
            disp(checkvec);
            
            
            if length(discvec) == 3
                rt = round(1000*(pressed-startrt));
                if discvec == [1 0 0]
                    disc(trial) = 1; % left mouse
                elseif discvec == [0 0 1]
                    disc(trial) = 2; % right mouse
                end
            else disc(trial) = 0; rt =0; % caution: in case of 'no' clicks!
            end
            disp(disc);
            
            if length(checkvec) == 3
                if (checkvec == [1 0 0] | checkvec == [0 0 1] )
                    check(trial) = 1;
                end
            else check(trial) = 9; % caution: in case of 'no' second clicks!
            end
            disp(check);
            
        end
        
        
        
        
        %
        %         % Write restults to file
        
        if  ( cuevector(trial) == 1 )
           
            
            
            if ( taskCuevec(halfindex) == 1 )
                fprintf(datafilepointer,'%i %i %s %s %i %s %s %s %s \n', ...
                    subNo, ...
                    trial, ...
                    '1', ...
                    '1', ...
                    theta(halfindex), ...
                    'N', ...
                    'N', ...
                    'N', ...
                    'N');
                
            else
                fprintf(datafilepointer,'%i %i %s %s %i %s %s %s %s \n', ...
                    subNo, ...
                    trial, ...
                    '1', ...
                    '2', ...
                    theta(halfindex), ...
                    'N', ...
                    'N', ...
                    'N', ...
                    'N');
                
            end
            
            
        elseif ( cuevector(trial) == 2 )
            fprintf(datafilepointer,'%i %i %s %s %i %s %i %i %i \n', ...
                subNo, ...
                trial, ...
                '2', ...
                'N', ...
                theta(trial), ...
                'N', ...
                disc(trial), ...
                check(trial), ...
                rt);
            
            
            
        end
        
        
    end
    
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    %     fclose(s3);
    
    % End of experiment:
    return;
catch
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    %     fclose(s3);
    psychrethrow(psychlasterror);
end
