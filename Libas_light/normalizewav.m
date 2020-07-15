% normalizewav
function [] = normalizewav(path); 

[a, b] = wavread(path);

rmswav = mean(sqrt(sum(a.^2)./length(a))); 

a = a./(rmswav.*5);

figure, plot(a)
sound(a,b)

wavwrite(a,b,16,['n_' path])
