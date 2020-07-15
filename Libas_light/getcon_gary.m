function [anglediff2, anglediff4, anglediff6] = getcon_gary(filepath)

fid = fopen(filepath); 

anglediff2 = []; 
anglediff4 = []; 
anglediff6 = []; 



a = 1; 

while a > 0
   
    a =  fgetl(fid);
       
   if a > 0
       
       b = str2num(a); 
       
       setsize = b(3);
       
       if setsize == 2, 
           anglediff2 = [anglediff2; b(10:11) - b(16:17)];
       elseif setsize == 4,
           anglediff4 = [anglediff4; b(10:13) - b(16:19)];
       else
            anglediff6 = [anglediff6; b(10:15) - b(16:21)];
       end
       
   end
   
end
anglediff2(abs(anglediff2)>90) = abs(anglediff2(abs(anglediff2)>90))-180;
anglediff4(abs(anglediff4)>90) = abs(anglediff4(abs(anglediff4)>90))-180;
anglediff6(abs(anglediff6)>90) = abs(anglediff6(abs(anglediff6)>90))-180; 

anglediff2 = abs(anglediff2);
anglediff4 = abs(anglediff4);
anglediff6 = abs(anglediff6);
       