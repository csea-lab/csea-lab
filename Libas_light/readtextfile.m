function [ textmat ] = readtextfile( path );

     fid = fopen(path); 

      textmat = []; 
      
      newline = [2 3 4]; 
      
while length(newline) > 2
    
      newline =  fgetl(fid)
      
      if length(newline)  > 2
    
      textmat = [textmat; newline];
      
      end
    
end

fclose(fid);