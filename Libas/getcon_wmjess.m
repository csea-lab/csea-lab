function [anglediff2] = getcon_wmjess(filepath)

fid = fopen(filepath); 

anglediff2 = []; 




a = 1; 

while a > 0
   
    a =  fgetl(fid);
       
   if a > 0
       
       b = str2num(a); 
       
       setsize = b(4);
       
       if setsize == 2, 
           anglediff2 = [anglediff2; b(11:12) - b(17:18)];
       end
     
       
   end
   
end


anglediff2(abs(anglediff2)>90) = abs(anglediff2(abs(anglediff2)>90))-180;

anglediff2(abs(anglediff2)>90) = abs(anglediff2(abs(anglediff2)>90))-180;

anglediff2(abs(anglediff2)>90) = abs(anglediff2(abs(anglediff2)>90))-180;

anglediff2 = abs(anglediff2);
