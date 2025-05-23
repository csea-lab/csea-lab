function [conditionvec_actual, timecourse, abstimecourseout, RTout]=get_condispas(filemat)


for file = 1:size(filemat)

    filepath = deblank(filemat(file,:));

    fid = fopen(filepath);

    a = 1;

    conditionvec = [];
    conditionvec_actual = []; 
    timecourse = [];
    abstimecourse = [];
    RT = [];
    blockvec = ones(350,1);
    blockvec(1:150) = 100; 
    blockvec(151:350) = 200; 

    while a > 0

        a =  fgetl(fid);


        if a > 0

            b = str2num(a);

            if length(b) > 4

                conditionvec  = [conditionvec b(5)];

                conditionvec_temp = relabel_circle(5, b(6)); 

                b(5)
                conditionvec_actual = [conditionvec_actual conditionvec_temp(b(5))+1]; 


                    conditioned = b(6);

                    rated = b(7);

                    RTime = b(8);

              end

                if rated > 0
                    timecourse = [timecourse conditioned-rated];

             	   abstemp = abs(conditioned-rated);

            	   if abstemp == 4, abstemp = 1; end
            	   if abstemp == 3, abstemp = 2; end

                   abstimecourse = [abstimecourse abstemp];

                   RT = [RT RTime];
                end

            end

        end

        RTout(file,:) = RT;
        abstimecourseout(file,:) = abstimecourse;

end
conditionvec_actual = conditionvec_actual'+ blockvec;
end

function relabel = relabel_circle(N, ref)
    relabel = zeros(1, N);
    for i = 1:N
        cw = mod(i - ref, N);      % clockwise distance
        ccw = mod(ref - i, N);     % counter-clockwise distance
        relabel(i) = min(cw, ccw); % minimal circular distance
    end
end
