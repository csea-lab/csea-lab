function [outmat] = get_tagbinsWM3(filemat, tagcondition);


for fileindex = 1:size(filemat,1); 
    
    data = ReadAvgFile(deblank(filemat(fileindex,:))); 
    
    topo10Hz  = data(:, 34); 
    topo13Hz  = data(:, 45); 
    
    
    %tagcondition 1 = 1:16 VP, except number 7 
    %tagcondition 2 = 17:25 VP #s
    
    % caution: in the outfiles, top is first value (time point) then
    % bottom...
    
    if tagcondition == 2
        
        outmat = [topo10Hz topo13Hz ]; % top = 10 Hz; bottom = 13.33Hz
        
    elseif tagcondition ==1
        
        outmat = [topo13Hz topo10Hz]; % top = 13.33 Hz; bottom = 10 Hz; 
        
    end
    
    
  SaveAvgFile([deblank(filemat(fileindex,:)) '.tbtag'],outmat,[],[],1)
    
    
end    
    


