function [] = trialcorrpupil(filemat)
% this function takes a list of files with matcorr info from the pupil
% pipeline. These are time points by trials in size 

for fileindex = 2:size(filemat,1)

    temp1 = load(deblank(filemat(fileindex, :)));
    data = temp1.matcorr;

    figure(101)
    for trialindex = 1:size(data,2)
        STDQC = std(data(:, trialindex));
        transientindices  = find(abs(diff(data(:, trialindex))) > .0075);
        if STDQC < .02 || ~isempty(transientindices)|| STDQC > .15
            plot(data(:, trialindex), 'r'), axis([1 length(data(:, trialindex)) 0 1]), 
            title(num2str(fileindex)), pause(.5)
            
            STDflag = 1;
        else
            plot(data(:, trialindex), 'b'), axis([1 length(data(:, trialindex)) 0 1]), 
            title(num2str(fileindex)), pause(.1)
        end
    end % trials
end % files

