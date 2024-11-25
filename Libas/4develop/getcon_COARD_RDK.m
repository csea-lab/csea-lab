function [ conditionvector, percentcorrect, targetpresent, reportvector] = getcon_COARD_RDK(datfilepath)

conditionvector = [];

targetpresent = [];

reportvector = [];

percentcorrect = zeros(1,4);

targvec = []; 

repvec =[];

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

crosstab(targetpresent, reportvector)

percentcorrectoverall = 1-sum(diag( crosstab(targetpresent, reportvector)))./sum(sum(crosstab(targetpresent, reportvector)));


for condition=1:4
    targvec =  targetpresent(conditionvector==condition);
    repvec = reportvector(conditionvector==condition);
    if size(crosstab(targvec, repvec)) == [2,2]
        percentcorrect(condition) =1-sum(diag( crosstab(targvec, repvec)))./sum(sum(crosstab(targvec, repvec)));
    else
        percentcorrect(condition) = .5;
    end
end