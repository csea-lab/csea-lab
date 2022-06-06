
tonetime = 0:1/22000:5; 
targettonebase = sin(2*pi*440*tonetime); 
modulation = 0.5* (sin(2*pi*41.2*tonetime).^5 + 1); 

event = sin(2*pi*523*tonetime(1:2200)); 

targettone = targettonebase .* modulation; 

filemat = getfilesindir(pwd);

for x = 1:36

    temp = importdata(filemat(x,:)),  
 
    Y = resample(temp.data(:,1)',22000, temp.fs); 

    %Ynew = [zeros(1,22000) Y./rms(Y)]; % plus one second at the beginning
    %for compund
    
    Ynew = [Y./rms(Y)];

    %psound = audioplayer((Ynew(1:5*22000+1)./2 + targettone)./2, 22000);
    %%compound: natural plus tone
    
    soundmat = (Ynew(1:5*22000+1)./3);
    %sound(soundmat, 22000), pause
    
    eval(['save ' filemat(x,:) '.mat soundmat -mat'])

    % play(psound)

    rms(Y) 

pause(1)

end   