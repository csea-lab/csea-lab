% input: a; 
% order; 

valence = a([1:3], :); 
arousal = a([4:6], :); 
expectancy = a([7:9], :); 

valenceout(:, order) = valence;
arousalout(:, order) = arousal;
expectancyout(:, order) = expectancy;

figure(1), bar(valenceout)
figure(2), bar(arousalout)
figure(3), bar(expectancyout)

