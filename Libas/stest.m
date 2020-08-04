
% the s-tranform test script
len = 128;
freq = 5;   
t = 0:len-1;

% CREATE CROSS CHIRP TIME SERIES
cross_chirp = cos(2*pi*(10+t/7).*t/len) + cos(2*pi*(len/2.8-t/6.0).*t/len);
% CREATE MODULATED SIN FUNCTION TIME SERIES
mod_freq=4*cos(2*pi*t/len)+len/5;
sin_of_sin = cos(2*pi*mod_freq.*t/len);
% CREATE the Distinct sinusoids example
midfreq = 20;
lowfreq = 5;
highfreq = 45;
distinct = cos(2*pi*midfreq.*t/len);
distinct(1:len/2) = cos(2*pi*lowfreq.*t(1:len/2)/len);
distinct(20:30) = cos(2*pi*highfreq .*t(20:30)/len);
% CREATE the chirp example
chirp = cos(2*pi*(10+t/7).*t/len);



[st_matrix,st_times,st_frequencies] = st(sin_of_sin);
[st_matrix_chirp,st_times,st_frequencies] = st(chirp);
[st_matrix_chirps,st_times,st_frequencies] = st(cross_chirp);
[st_matrix_distinct,st_times,st_frequencies] = st(distinct);

contourf(st_times,st_frequencies,abs(st_matrix_chirps));
%mesh(abs(st_matrix_chirp));
