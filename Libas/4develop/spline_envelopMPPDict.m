function [dictWin] = spline_envelopMPPDict(x, fs)
% find te enevelope shape of a short gaussian 
x = x(:); % makes sure it's right dim
N = numel(x);
t = (0:N-1)'/fs;
% fs is sample rate 

% Peaks and valleys
[~,ip] = findpeaks(x);
[~,iv] = findpeaks(-x);

% Edge guards (mirror a point near each end if needed)
guard = @(idxs) unique([1; idxs(:); N]);
ip = guard(ip); iv = guard(iv);

% Interpolate with PCHIP
env_up = interp1(t(ip), x(ip), t, 'pchip');
env_lo = interp1(t(iv), x(iv), t, 'pchip');

dictWin = (env_up)-(env_lo); 
end

