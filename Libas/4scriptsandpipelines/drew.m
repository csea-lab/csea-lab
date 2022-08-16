time = 0:0.001:1;
a = sin(2*pi*time*10);
b = sin(2*pi*time*11);
c = sin(2*pi*time*15);
d = cos(2*pi*time*15);
%%
plot(time, a+b+c), 
hold on 
plot(time, a+b+d)
%%
fft1 = fft(a+b+c);
fft2 = fft(a+b+d);

testsig = a+b+c; 
for x = 1:30; fftdot(x) = testsig*sin(time*2*pi*x)'; end
%%
figure
plot(0:30, abs(fft1(1:31)))
hold on
plot(0:30, abs(fft2(1:31)))
%%
figure
plot(0:30, angle(fft1(1:31)))
hold on
plot(0:30, angle(fft2(1:31)))