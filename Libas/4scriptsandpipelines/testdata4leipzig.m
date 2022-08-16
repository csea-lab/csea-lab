% make simulated data for featuer leizpig
 data = rand(31, 200000); 
 
 time = 0:0.002:4; 
 ssvepsig = sin(2*pi*time*12); 
 
 for x = 1:32
 onsets(x) = x.*6000 + round(rand(1,1).*1000)
 end
 
 
 for x = 1:32
 data(:, onsets(x):onsets(x)+2000) = noise(:, onsets(x):onsets(x)+2000) + repmat(ssvepsig, 31,1); 
 end