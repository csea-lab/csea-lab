time = 0:0.002:6; % fake EEG signal sampled at 500 Hz

signal = rand(3001,1);

[alow,blow] = butter(4, 12/250);   % 12 Hz lowpass when sampled at 500 Hz

siglow = filtfilt(alow, blow, signal);

[ahigh,bhigh] = butter(2, 7/250, 'high')% 7 Hz highpass (2nd order) when sampled at 500 Hz

sighighlow = filtfilt(ahigh, bhigh, siglow);

figure(1)

plot(time, sighighlow), title(' signal, hilbert analytical signal, and envelope')

test = hilbert(sighighlow);

hold on, plot(time, imag(test))

plot(time, abs(test))

figure(2), 
plot(time, angle(test)), title('screwed up phase :-)')


%now do it again, with narrow band bass :) 

[alow,blow] = butter(6, 10.5/250);   % 12 Hz lowpass when sampled at 500 Hz

siglow = filtfilt(alow, blow, signal);

[ahigh,bhigh] = butter(4, 9.5/250, 'high')% 7 Hz highpass (2nd order) when sampled at 500 Hz

sighighlow = filtfilt(ahigh, bhigh, siglow);

figure(3)

plot(time, sighighlow), title(' new signal, hilbert analytical signal, and envelope')

test = hilbert(sighighlow);

hold on, plot(time, imag(test))

plot(time, abs(test))

figure(4)

plot(time, angle(test)), title('still pretty bad phase :-)')
