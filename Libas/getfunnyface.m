function [firstresp,secondresp] = getfunnyface(file)
% plots response functions for funnyface 

a = load(file); 

first = a(1:120, :); 

for comp = 1:6; 
    indices = find(first(:,5) == comp);
    firstresp(comp) = mean(first(indices,6));
end

second = a(121:240, :); 

for comp = 1:6; 
    indices = find(second(:,5) == comp);
    secondresp(comp) = mean(second(indices,6));
end

plot(firstresp)
hold on 
plot(secondresp)