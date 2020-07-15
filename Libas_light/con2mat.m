function [convec] = con2mat(confilemat); 

for x = 1: size(confilemat) 
    
    filename = deblank(confilemat(x,:))
    
   [convec] = ReadData(filename, 1, [], 'ascii', 'ascii'); 
   
   [PATHSTR,NAME] = fileparts(filename); 
   
   eval(['save ' NAME '.mat convec -mat'])
   
   
   
end
