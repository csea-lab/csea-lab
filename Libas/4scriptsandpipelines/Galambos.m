% first a time axis for the oscillation
 time = 0:0.002:.5; 
 sin10Hz = sin(2*pi*10*time);
 cos10Hz = cos(2*pi*10*time);
 x = spatialPattern([1 750],-2)./2; 
 
 timefull = 0:0.002:1.5-0.002; 
 
 sigall =  x;
 sigall(251:501) = x(251:501) + sin10Hz; 
 
 plot(sigall)
 
 
 
 
