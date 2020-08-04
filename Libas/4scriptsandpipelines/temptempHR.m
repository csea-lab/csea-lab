function  [newmat] = temptempHR(filemat)
%

srate = 500; 

for fileindex = 1:size(filemat,1)
  
    name = deblank(filemat(fileindex,:));
    
  nameout = filemat(fileindex,[1:19 33]);
    
  con = str2num(filemat(fileindex,33:33)); 
       
   data = ReadAvgFile(name); 
    
   newmat = zeros(size(data,1), size(data,2)); 
  
   tempy = []; 
   
    for trial = 1:size(data,1); 
        
        temp = squeeze(data(trial,:));
        
        timestamps(1) = round(rand(1,1) .* 350)+1;
        
        if con ==1 
                for timestampindex = 2:7
                    timestamps(timestampindex) = timestamps(timestampindex-1) + rand(1,1).*120+400+rand(1,1)*30;
                end
        else
                for timestampindex = 2:4
               timestamps(timestampindex) = timestamps(timestampindex-1) + rand(1,1).*120+400+rand(1,1)*30+1.5;
                end
                 for timestampindex = 5:7
              timestamps(timestampindex) = timestamps(timestampindex-1) + rand(1,1).*120+395+rand(1,1)*30;
                end
        end
            
       
         tempy(trial,:) = 60./(diff(timestamps).*2./1000); 
         
        timestamps(timestamps>3100) = []; 
        
        newmat(trial, round(timestamps)) = 1; 
        
       
              
    end
    
 plot(mean(tempy)), axis([0 7 52 70]), title(num2str(con)), pause
    
 SaveAvgFile([nameout '.Rwaves.at' ], newmat); 

end % loop pver files


