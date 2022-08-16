FF = fft(move,2048);

Pyy = FF.*conj(FF)/2048;

FF=[];


%	frequency axis:

f = 100/2048*(0:1024);

plot(f(1:300),Pyy(1:300)), title('Power spectral density'), ...
xlabel('Frequency (Hz)')

[fre,c]=ginput(1);

disp(' ')
fprintf ('maximale power bei %g Hertz\n',fre)
teilfrq = num2str(fre)


