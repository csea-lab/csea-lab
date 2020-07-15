% verhulst
function [outvec] =verhulst(B)

x = 0.1

for n = 1 :50

    x(n+1) = B*x(n)*(1-x(n));
    if x(n+1) < 0 , x(n+1) = 0; end
    if x(n+1) > 1 , x(n+1) = 1;  end   
        
end


plot(x)

