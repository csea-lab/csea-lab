function test_rayleigh()
% Tests the circmean.m function using Examples 4.12, 4.14, and 5.8
% from Fisher (1993).
%
% Tests check out fine. ---  3/26/04 D. Rizzuto

% Data from Appendix B.4
data = [
    2 9 18 24 30 35 35 39 39 44 ...
    44 49 56 70 76 76 81 86 91 112 ...
    121 127 133 134 138 147 152 157 166 171 ...
    177 187 206 210 211 215 238 246 269 270 ...
    285 292 305 315 325 328 329 343 354 359 ...
        ]';

% convert to radians
data = data / 180 * pi;

[theta, rbar] = circmean( data );
fprintf('Rbar = %.4f, expected = 0.1798\n', rbar);


% Data from Appendix B.6, Set 2
data = [
    294 301 329 315 277 281 254 245 272 242 ...
    177 257 177 229 250 166 232 245 224 186 ...
    ]';

% convert to radians
data = data / 180 * pi;

theta = circmean( data );
fprintf('Theta = %.1f, expected = 248.7\n', theta/pi*180);


% Data from Appendix B.15
data = [28 354 332 59 25 43 36 51 50 48 330 23 32 325 ]' / 180 * pi;

% convert to vector from axial
data = mod(2*data,2*pi);

[theta, rbar, delta] = circmean( data );
fprintf('Delta = %.3f, expected = 1.462\n', delta);



