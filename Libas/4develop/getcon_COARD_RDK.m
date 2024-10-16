function [ conditionvector, targetpresent, reportvector] = getcon_COARD_RDK(datfilepath)

conditionvector = []; 

targetpresent = []; 

reportvector = []; 

fid = fopen(datfilepath);

trialcount = 1;

a = 1;


while a > 0
    
    a = fgetl(fid);
        
    if a < 0, break, return, end
    
    blankindex = find(a == ' ');

   letter =  a(blankindex(7)+1);

   targetpresent =  [targetpresent; str2num(a(blankindex(3)+1))];
   reportvector = [reportvector; str2num(a(blankindex(5)+1))];

   if strcmp(letter, 'p'), conditionvector  = [conditionvector 1]; 
   elseif strcmp(letter, 'n'), conditionvector  = [conditionvector 2]; 
   elseif strcmp(letter, 'u'), conditionvector  = [conditionvector 3];
   else conditionvector  = [conditionvector 4];
   end

end


conditionvector = column(conditionvector);




