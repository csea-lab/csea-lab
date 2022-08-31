function [amplitude] = Ricker(std, t)
Fc = std; % DOG width
p = Fc.*Fc.*t.*t;
amplitude = ((1-2*pi*pi.*p).*exp(-pi*pi.*p))';
plot(t,amplitude)
ylabel('Amplitude')
xlabel('Timeseries (s)')
grid on