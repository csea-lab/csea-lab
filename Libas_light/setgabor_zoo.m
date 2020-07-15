function [thetauser, rt]=setgabor_zoo(locationmat, w, wRect, tex_noise);

    % set priority - also set after Screen init
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
            
    % here: determine the gray etc
    
    white = WhiteIndex(w); % pixel value for white
    black = BlackIndex(w); % pixel value for black
    gray = (white+black)/2;
    inc = white-gray;
    
    
     [x,y] = meshgrid(-100:100, -100:100);
    mzero = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(180*pi/180)*(2*pi*0.04)*x + sin(180*pi/180)*(2*pi*0.04)*y));
    gratingzero = gray+inc*((60./100)*mzero);  
    tex_gratingzero = Screen('MakeTexture', w, gratingzero);  
    
    %gray background
    Screen('FillRect', w, gray);
    
    locindex = size(locationmat,1);
    
    for location = 1:size(locationmat,1); 
        
        % find non-rotate locations
       
        locationmat_no = locationmat(locindex(locindex ~= location),:); 
        
        for tempindex = 1:size(locationmat_no,1)
        Screen('DrawTexture', w, tex_noise,[],locationmat_no(tempindex,:),[],[],1);
        end
        
        Screen('DrawTexture', w, tex_gratingzero,[],locationmat(location,:),[],[],1);
        
        DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
    
    Screen('Flip', w);
        WaitSecs(1); 
                    
       
       pressed = 0; 
       xnew = 0; 
       
       tic
       while sum(pressed) < 1 
             
              WaitSecs(0.05)
               
                                thetauser = 180+xnew./3
                               
                                m = (exp(-((x/50).^2)-((y/50).^2)) .* sin(cos(thetauser*pi/180)*(2*pi*0.04)*x + sin(thetauser*pi/180)*(2*pi*0.04)*y));
                                gratingzero = gray+inc*((60./100)*m);  
                                tex_gratingzero = Screen('MakeTexture', w, gratingzero);  
                                                                
                                    for tempindex = 1:size(locationmat_no,1)
                                    Screen('DrawTexture', w, tex_noise,[],locationmat_no(tempindex,:),[],[],1);
                                    end
        
                                Screen('DrawTexture', w, tex_gratingzero,[],locationmat(location,:),[],[],1);
        
                                DrawFormattedText(w,'o','Center','Center',BlackIndex(w));
    
                                Screen('Flip', w);
                                
                                [xnew,ynew,pressed] = GetMouse(w);
                            
                                WaitSecs(.05); 
                                
                                
                                   
       end  
       rt = toc; 
       
               while thetauser > 180
                   thetauser = thetauser-180;
               end
       
       
       Screen('Flip', w);
     WaitSecs(1); 
     
    end
                                                         