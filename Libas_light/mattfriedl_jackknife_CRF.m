
mat = who('h*')

outmathabCSplus = zeros(44,4); 
outmathabCSmin = zeros(44,4); 
outmatacqCSplus = zeros(44,4); 
outmatacqCSmin = zeros(44,4); 

for subject = 1:44; 
    
    matnew = mat; 
    
    matnew(subject) = []; 

            for x = 1:size(matnew,1)
                
             if x == 1; eval(['tempsum =' matnew{1}]), else, eval(['tempsum = tempsum + ' matnew{x}]); end
            
            end
            
            tempavg = tempsum./size(mat,1);
            
            plot(tempavg(1,:)), hold on, 

            paratemp1 = Naka_inky(tempavg(1,:), [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700] ,[ 0.5 0.5 1 3], 'green');
            paratemp2 = Naka_inky(tempavg(2,:), [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700] ,[ 0.5 0.5 1 3], 'green');
            paratemp3 = Naka_inky(tempavg(3,:), [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700] ,[ 0.5 0.5 1 3], 'green');
            paratemp4 = Naka_inky(tempavg(4,:), [0  1.3400    1.8100    2.4500    3.3000    4.4600    6.0200    8.1200   10.9700] ,[ 0.5 0.5 1 3], 'green');
            
            
         outmathabCSplus(subject,:) = paratemp1';
          outmathabCSmin(subject,:) = paratemp2';
           outmatacqCSplus(subject,:) = paratemp3';
            outmatacqCSmin(subject,:) = paratemp4';
            
            
            
            
            
end
