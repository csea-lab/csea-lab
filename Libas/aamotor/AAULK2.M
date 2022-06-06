
FF = fft(move,256);
Pyy = FF.*conj(FF)/256;

FF=[];


%	frequency axis:

f = 100/256*(0:128);

plot(f(1:40),Pyy(1:40)), title('Power spectral density'), ...
xlabel('Frequency (Hz)')

[fre,c]=ginput(1);

disp(' ')
fprintf ('maximale power bei %g Hertz\n',fre)
teilfrq = num2str(fre)

