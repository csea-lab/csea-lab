%simulates rt data for comparison with real data
function [respvec] = testdatfile(subNo,rtbase)


respvec = [];
convector =[]; 

block = [ones(120, 1); ones(120,1).*2; ones(120,1).*3];


datafilename = strcat('KNreplic_3_',num2str(subNo),'.txt');
 
 datafilepointer = fopen(datafilename,'wt');
 
 a101 = ones(10,1).* 101; 
  a102 = ones(10,1).* 102; 
   a103 = ones(10,1).* 103; 
    a104 = ones(10,1).* 104; 
     a105 = ones(10,1).* 105; 
      a106 = ones(10,1).* 106; 
       a201 = ones(10,1).* 201; 
        a202 = ones(10,1).* 202; 
         a203 = ones(10,1).* 203; 
          a204 = ones(10,1).* 204; 
           a205 = ones(10,1).* 205; 
            a206 = ones(10,1).* 206; 
            
 
 convector_total1block = [a101; a102; a103; a104; a105; a106; a201; a202; a203; a204; a205; a206];
 
 convector = [convector_total1block(randperm(120)) convector_total1block(randperm(120)) convector_total1block(randperm(120))];

for trial = 1:360
    
    if convector(trial) < 200   %change !!!!
        respvec(trial) = round(rand(1,1)+.46); 
    else
        respvec(trial) = round((rand(1,1)-.5+rand(1,1))./2.7) ;
    end
    
    if respvec(trial) == 1
        if convector(trial) == 101, rt = round(rand(1,1).*250 + rtbase+10)
        elseif convector(trial) == 102, rt = round(rand(1,1).*260 + rtbase+2)
        elseif convector(trial) == 103, rt = round(rand(1,1).*250 + rtbase+20)
        elseif convector(trial) == 104, rt = round(rand(1,1).*260 + rtbase+30)
        elseif convector(trial) == 105, rt = round(rand(1,1).*260 + rtbase+30)
        elseif convector(trial) == 106, rt = round(rand(1,1).*250 + rtbase+30)
        elseif convector(trial) == 201, rt = round(rand(1,1).*250 + rtbase+10)
        elseif convector(trial) == 202, rt = round(rand(1,1).*245 + rtbase+10)
        elseif convector(trial) == 203, rt = round(rand(1,1).*245 + rtbase+20) 
        elseif convector(trial) == 204, rt = round(rand(1,1).*220 + rtbase+10)
        elseif convector(trial) == 205, rt = round(rand(1,1).*290 + rtbase+30)
        elseif convector(trial) == 206, rt = round(rand(1,1).*290 + rtbase+50)   
            
          %    if block(trial) ==2; rt = round(rt.*0.90); elseif block(trial) ==3; rt = round(rt.*0.81); end
             
            
        end
        
    else rt = 0; 
    
    end
    
    
                fprintf(datafilepointer,'%i %i %i %i %i %i \n', ...   
                            subNo, ...
                            block(trial), ...
                            trial, ...
                            respvec(trial), ...
                           convector(trial), ...
                           rt);
                       
                       
end
