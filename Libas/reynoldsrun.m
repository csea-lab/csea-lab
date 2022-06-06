
biasindex = 1; 
weightindex = 1; 
X11index =1; 


for X11 = .02:0.02:1; 
    biasindex = 1; 
   weightindex = 1; 

    for bias = .02:0.02:.5
        weightindex = 1; 
        for weight = 0.02:0.02:0.5

          t = 300;
         vector =  reynovarleft(t, bias, weight, X11);
            outmat3d(biasindex, weightindex, X11index) = max(vector);
             
weightindex = weightindex+1;   
        end
biasindex = biasindex +1;  plot(vector), pause(.02)
    end
X11index = X11index +1; 
    if X11index/1 == round(X11index/1), fprintf('.'), end, 
end