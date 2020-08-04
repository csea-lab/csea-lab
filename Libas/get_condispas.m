function [timecourse, abstimecourseout, RTout, conditionvec]=get_condispas(filemat)


for file = 1:size(filemat)
       
    filepath = deblank(filemat(file,:)); 
        
    fid = fopen(filepath); 

        a = 1; 

        conditionvec = []; 
        timecourse = []; 
        abstimecourse = []; 
        RT = []; 

        while a > 0

        a =  fgetl(fid);


        if a > 0

          b = str2num(a); 

          if length(b) > 4 

           conditionvec  = [conditionvec b(5)]; 

           conditioned = b(6);

           rated = b(7); 

           RTime = b(8); 

          end

           if rated > 0 
           timecourse = [timecourse conditioned-rated]; 

	   abstemp = abs(conditioned-rated)

	   if abstemp == 4, abstemp = 1; end
	   if abstemp == 3, abstemp = 2; end

           abstimecourse = [abstimecourse abstemp]; 
		
           RT = [RT RTime]; 
           end

        end

        end

        RTout(file,:) = RT;
        abstimecourseout(file,:) = abstimecourse; 
                     
        conditionvec = conditionvec'; 
        conditionvec = conditionvec + ([ones(150,1).*100;  ones(200,1).*200]); 
        
end