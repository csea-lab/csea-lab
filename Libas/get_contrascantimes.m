function [onsets, R128times]=get_contrascantimes(filemat)
% point to .mrk files

for file = 1:size(filemat)
       
    filepath = deblank(filemat(file,:)); 
        
    fid = fopen(filepath); 

        a = 1; 

        onsets = []; 
        R128times = []; 
        
        for temp = 1:7; 
             dummy =  fgetl(fid)
        end

        while a > 0

        a =  fgetl(fid)


                if a > 0

                tabs = findstr(',', a)
                if length(tabs)>2
                    label = a( tabs(1)+1:tabs(2)-1);
                    time = str2num(a( tabs(2)+1:tabs(3)-1))./5000;
                    if strcmp(label, 'R128'), R128times = [R128times; time]; end
                    if strcmp(label, 'S  2'), onsets = [onsets; (time)]; end
                end
                

                end
        
        end
end