function [outinnerprodvec] = movgavgPupil(conditionvec,matcorr, apriorimodel)

outinnerprodvec = [];

apriorimodel = column(apriorimodel);

matcorrbsl = bslcorr(matcorr', 300:500)'; % baseline correction by subtraction

for segment = 1:length(conditionvec)-12

    meantrialbslpupil = mean(matcorrbsl(1251:1500, segment:segment+11)); %pupil dat for 12 cons trials

    conditionvec12 = conditionvec(segment:segment+11);
    
    conditionspresent = unique(conditionvec12);

    if length(conditionspresent) == 7

        vec4innerprod =[]; 

        for conditionindex = 1:length(conditionspresent)

        index = find(conditionvec12 == conditionspresent(conditionindex));

        vec4innerprod(conditionindex) = mean(meantrialbslpupil(index));
   
        end
        outinnerprodvec = [outinnerprodvec; vec4innerprod*apriorimodel];

    end

end



