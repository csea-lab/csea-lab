
time = 0:0.002:5;

a1 = sin(2*pi*10*time);

a2 = a1(3:end);  %sensor 1
a3 = a1(1:end-2); %sensor 2

fftvec = []; count = 1; 

for x =1:50 :340; x2 = x+round(rand(1,1).*9); plot(a2(x:x+150)), hold on, plot(a3(x2:x2+150), 'r'), title(['time window shift' num2str(count)]), pause, hold off
    ffta = fft(a2(x:x+150)); fft10bina = ffta(4);
    fftb = fft(a3(x2:x2+150)); fft10binb = fftb(4); fftvec(count) = fft10bina-fft10binb; count = count+1;
end

(fftvec) % shoudl NOT be on a unit circle

pause

fftvecnorm = fftvec./abs(fftvec);

(fftvecnorm) % shoudl be on a unit circle

disp('phase locking of the difference:')
abs(mean(fftvecnorm))

% and another test: 

for x = 1:15;
phi1 = (0.6+rand(1,1)./20)+0.4i; phi2 = (0.6-rand(1,1)./20)+(0.4 +rand(1,1)./30)*i;
figure(1), compass(phi1), hold on, compass(phi2, 'r'), hold off
phidiff = (phi1-phi2)%./abs(phi1-phi2); 
figure(2), compass(phidiff), pause
if x ==1, phisum = phidiff, else, phisum = phisum+ phidiff; end
end, plv = abs(phisum)./15