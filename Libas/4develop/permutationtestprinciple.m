

for x = 1:5000

    a2 = a; 
    b2 = b; 

for x2 = 1:32

    coin = logical(round(rand(1,1)));
    if coin 

        a2(x2) = b(x2); 
        b2(x2) = a(x2); 

    end
        
end

[~, ~, ~, stats] = ttest(a2,b2);
distribution(x) = stats.tstat; 

end
