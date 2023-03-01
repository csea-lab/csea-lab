function BrandonTriggertest(subNo)

clc;
rand('state', sum(100*clock));

AssertOpenGL;

% Define KeyPad/Response
KbName('UnifyKeyNames');
advancestudytrial = KbName('n');

%%%%Commented out, 92614 because we are using parallel port, see below
% open serial port for trigger writing
% s3 = serial('com3'); % on PC only
% fopen(s3)
%[handle, errmsg] = IOPort('OpenSerialPort', 'COM4');
%      IOPort('ConfigureSerialPort',handle,'BaudRate=2400'); %lower the baud rate 
%       IOPort('Purge',handle); %first clear the COM port of crap
%       data=uint8(1); %specify exactly 1 byte of data to be written to the COM port

 s=serialport('/dev/ttyUSB0',1200);
 fopen(s);

%%%%Parallel port script
% open parallel port for trigger writing
% dio = digitalio('parallel','lpt1');     % This computer requires LPT2 to send triggers to the BP MR-Plus amplifier
%addline(dio,0:7,0,'out');
    
%uddobj = daqgetfield(dio,'uddobject');
%putvalue(uddobj,[0 0 0 0 0 0 0 0],1:8); 


% files
datafilename = strcat('facebor_',num2str(subNo),'.dat'); % name of data file to write to

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
    [w, wRect]=Screen('OpenWindow', screenNumber, gray-2.5, [], 32);
    % enable alpha-blending*
    Screen(w,'BlendFunction',GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize', w, 22);
    DrawFormattedText(w,'+','Center','Center',WhiteIndex(w));

    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    % Randomization of cues (indicating which stimuli - gabor or face - to be attended)
    tempvector = [ones(1,30) ones(1,30).*2 ones(1,30).*3];
    ntrials = length(tempvector);
    cuevector = tempvector(randperm(ntrials));
    
    thetavector = [ones(1,30) ones(1,30).*2 ones(1,30).*3];
    ntrials = length(thetavector);
    thetavec = thetavector(randperm(ntrials));

    % here: determine the gray etc
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    gray = (white+black)/2;
    inc = white-gray;
    alpha = 0.5;
 
    % stimulus folder (PC)
    Sstimdir = '/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/sad/';
    Hstimdir = '/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/happy/';
    Nstimdir = '/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/angry/';

    % read stimuli
    filemat_apics = dir([Sstimdir '*.JPG']); % file type should be in 'capital'
    filemat_hpics = dir([Hstimdir '*.JPG']);
    filemat_npics = dir([Nstimdir '*.JPG']);

    filemat_hpics = [filemat_hpics; filemat_hpics]; 
    filemat_npics = [filemat_npics; filemat_npics]; 
    filemat_apics = [filemat_apics; filemat_apics]; 
    
    %     here : add mouse click to start
    %     instruction screen
          imdata_instructions=imread('/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/Instructions.JPG');
          tex_instructions=Screen('MakeTexture', w, imdata_instructions);
          tRect_1=Screen('Rect', tex_instructions);
         % draw texture to backbuffer
          Screen('DrawTexture', w, tex_instructions, [], CenterRect(tRect_1, wRect));
          Screen('Flip', w); % show instructions

    % wait for mouse press ( no GetClicks  :(  )
    buttons=0;
    while ~any(buttons) % wait for press
        [x,y,buttons] = GetMouse;
        % Wait 10 ms before checking the mouse again to prevent
        % overload of the machine at elevated Priority()
        WaitSecs(0.01);
    end

  
    restingconditions = {'RestOpen.JPG', 'RestClosed.JPG'}.';
    
    
    for r=1:2;
        
   %sending out markers for each condition
   
        if strcmp(restingconditions(r), 'RestOpen.JPG') %i.e. Happy 
                write(s,zeros(1,5),"uint8")         
        elseif strcmp(restingconditions(r), 'RestClosed.JPG')
                write(s,zeros(1,5),"uint8") 
        end
            
    %     here : add mouse click to start
    %     instruction screen
          imdata_instructions=imread(['/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/' restingconditions{r}]);
          tex_instructions=Screen('MakeTexture', w, imdata_instructions);
          tRect_1=Screen('Rect', tex_instructions);
    % draw texture to backbuffer
          Screen('DrawTexture', w, tex_instructions, [], CenterRect(tRect_1, wRect));
          Screen('Flip', w); % show instructions   
     
    WaitSecs(60);  %changed from 60 to 0.5
   % putvalue(uddobj,[0 0 0 0 0 0 0 0],1:8);% set parallel back to zero
    
    % clear screen and reset parallel ports
    Screen('Flip', w);
           
    end 
    
    
   
    %Second Intruction Screen (For main task)
   
    %     here : add mouse click to start
    %     instruction screen
          imdata_instructions=imread('/home/gibbgrad/Desktop/SSVEP Change Detection Task_MIMIC3/15Hz Face_Facebor/Instructions1.JPG');
          tex_instructions=Screen('MakeTexture', w, imdata_instructions);
          tRect_1=Screen('Rect', tex_instructions);
         % draw texture to backbuffer
          Screen('DrawTexture', w, tex_instructions, [], CenterRect(tRect_1, wRect));
          Screen('Flip', w); % show instructions

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
    WaitSecs(rand(1,1) + 4);
 
    %%%%%%%%%%%TASK START
    
    % Randomorder of conditions (happy, angry, sad faces)
    tempvec = [ones(1,30) ones(1,30).*2 ones(1,30).*3];
    ntrials = length(tempvec);
    convector = tempvec(randperm(ntrials));
    
    % Randomization of gabor angles (indicating left, right or no tilt)
    %%%30 is equivalent to number of trials in each condition
    thetavector = [ones(1,23) ones(1,22).*2 ones(1,45).*3];
    ntrials = length(thetavector);
    thetavec = thetavector(randperm(ntrials));
    
    hapindex = 1;
    ntrindex = 1;
    sadindex = 1;
    timevector = [];
    
    for trial = 1:ntrials
 
        %%Break
        
        if trial == 31 || trial == 61   %as an example -- this would insert a break right after the 95th trial for example
            
          % write message to subject
          Screen('DrawText', w, 'Take a brief break...', 10, 10, 255);
          Screen('Flip', w); % show text
 
          % wait for mouse press ( no GetClicks  :(  )
           buttons=0;
 
           while ~any(buttons) % wait for press
           [x,y,buttons] = GetMouse;
           % Wait 10 ms before checking the mouse again to prevent
           % overload of the machine at elevated Priority()
           WaitSecs(0.01);
           end
 
           % clear scren
           Screen('Flip', w);
 
                                % wait a bit before starting trial
                                WaitSecs(1.000);
        end
        
        %%END Break       

        
        theta(trial) = 90;
        buttons=0;
        respvec = 0;

        % determine when the cue occurs during presentation
        %temp1 = 15; targonset = temp1(1) + 2; %Generates random #'s between 1-5 and adds 2

        if convector(trial) == 1, conlabel='happy'; imdata_happy = imread([Hstimdir filemat_hpics(hapindex).name]); tex_face = Screen('MakeTexture', w, imdata_happy); tRect_face = Screen('Rect', tex_face);
        elseif convector(trial) == 2, conlabel='angry'; imdata_neut = imread([Nstimdir filemat_npics(ntrindex).name]); tex_face = Screen('MakeTexture', w, imdata_neut); tRect_face = Screen('Rect', tex_face);
        elseif convector(trial) == 3, conlabel='sad'; imdata_sad = imread([Sstimdir filemat_apics(sadindex).name]); tex_face = Screen('MakeTexture', w, imdata_sad); tRect_face = Screen('Rect', tex_face);
        end
tic
        for flicker = 1:15 %this will determine the overall trial duration ((1000/refresh rate * number of flips)*the # of iterations in the for loop)
            
            %sending out markers for each condition 
            if strcmp(conlabel,'happy') %i.e. Happy 
               write(s,zeros(1,5),"uint8") 
            elseif strcmp(conlabel,'angry')%i.e. Angry 
                write(s,zeros(1,5),"uint8") 
            elseif strcmp(conlabel,'sad')%i.e., Sad 
                write(s,zeros(1,5),"uint8")    
            end
             
      
           %was160
           ms = 180; dms = ms/2;% size of gabor patch 

            %[VBLTimestamp startrt] = Screen('Flip',w);
            [x,y] = meshgrid(-ms:ms, -ms:ms);
            if flicker > 9 && flicker < 12 && thetavec(trial) == 1, theta(trial) = 100; %set first part for wehn shift occurs (9*333.33=~3sec;Second part is angle of patch, right now set at 115 deg.)
            elseif flicker > 9 && flicker < 12 && thetavec(trial) == 2, theta(trial) = 80; %this is a second orientation shift
            else theta(trial) = 90;
            end
            m = (exp(-((x/dms).^2)-((y/dms).^2)) .* sin(cos(theta(trial)*pi/180)*(2*pi*0.06)*x + sin(theta(trial)*pi/180)*(2*pi*0.06)*y));
            grating = gray+inc*(40/270*16/3+.005)*m ;
            tex_grating = Screen('MakeTexture', w, grating);
            tRect_grating = Screen('Rect', tex_grating);
            
            
            % 1st to 20th retrace (Face 15 Hz - 2on2off, Gabor 12 Hz - 2on3off, on 60 Hz monitor)
             Screen('Flip', w); %1st flip
             Screen('Flip', w); %2nd flip
             Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
              Screen('Flip', w); %3rd flip
              Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
              
            Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('Flip', w); %4th flip
            
             Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('Flip', w); %5th flip
            Screen('Flip', w); %6th flip
             Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha); 
             
              Screen('Flip', w); %7th flip
               Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha); 
               
              Screen('Flip', w); %8th flip
              Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('Flip', w); %9th flip
             Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('Flip', w); %10th flip
            Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
            
              Screen('Flip', w); %11th flip
               Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
             
              Screen('Flip', w); %12th flip
            Screen('Flip',w); %13th flip
             Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('Flip', w); %14th flip
            Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
           
            Screen('Flip', w); %15th flip
            Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
          
            Screen('Flip', w); %16th flip
            Screen('Flip', w); %17th
            Screen('Flip', w); %18th
            Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha);
           
            Screen('Flip', w); %19th flip
            Screen('DrawTexture',w,tex_grating,[],CenterRect(tRect_grating,wRect),[],[],alpha);
            Screen('DrawTexture', w, tex_face,[],CenterRect(tRect_face,wRect),[],[],alpha); 
            
            Screen('Flip', w); %20th flip

        end
        % putvalue(uddobj,[0 0 0 0 0 0 0 0],1:8);%
timevector=[timevector;toc];
        Screen('Flip', w);
        Screen('Close'); %close drawn textures
        %WaitSecs(rand(1,1)*2 + 2);

        if convector(trial) == 1, hapindex = hapindex + 1; ntrindex = ntrindex; sadindex = sadindex;
        elseif convector(trial) == 2, hapindex = hapindex; ntrindex = ntrindex+1; sadindex = sadindex;
        elseif convector(trial) == 3, hapindex = hapindex; ntrindex = ntrindex; sadindex = sadindex+1;
        end
 Screen('DrawText', w, 'Was there a change? Yes = Left click, No = Right Click', 190, 512, 255);
          Screen('Flip', w); % show text
respvec = 0;
[x,y,respvec] = GetMouse;

while ~any(respvec)
    [x,y,respvec] = GetMouse;
end
Screen('Flip', w);
        if length(respvec) == 3
            if respvec == [1 0 0]
                resp(trial) = 1; % left mouse
            elseif respvec == [0 0 1]
                resp(trial) = 2; % right mouse
            else resp(trial) = 0; rt =0;
            end
        else resp(trial) = 0; rt =0; % caution: in case of 'no' clicks!
        end
        WaitSecs(rand(1,1)*2 + 2);

        % Write results to file
        fprintf(datafilepointer,'%i %i %i %s %i %i \n', ...
            subNo, ...
            trial, ...
            cuevector(trial), ...
            conlabel, ...
            resp(trial), ...
            thetavec(trial));

    end % trials

    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
%    fclose(s3);

    % Cleanup at end of experiment
    return;

    % Catch errors
catch

    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
 %   fclose(s3);
    psychrethrow(psychlasterror);

end
