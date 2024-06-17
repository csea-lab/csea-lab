function [ conditionvector] = getcon_COARD_RDK(datfilepath)

conditionvector = []; 

fid = fopen(datfilepath);

trialcount = 1;

a = 1;


while a > 0
    
    a = fgetl(fid);
        
    if a < 0, break, return, end
    
    blankindex = find(a == ' ');

   letter =  a(blankindex(end)+1)

   if strcmp(letter, 'p'), conditionvector  = [conditionvector 1]; 
   elseif strcmp(letter, 'n'), conditionvector  = [conditionvector 2]; 
   elseif strcmp(letter, 'u'), conditionvector  = [conditionvector 3];
   else conditionvector  = [conditionvector 4];
   end

end


conditionvector = column(conditionvector);