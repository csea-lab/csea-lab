function [convec, EEG] = bop2con(datfilepath, EEG); 

mat = load(datfilepath); 

y = quantile(mat(:,4), [0.33 0.66]); 

convec = zeros(size(mat,1),1); 
convec(mat(:,4) <= y(1))=1;
convec(mat(:,4) >= y(2))=2;

if nargin > 1
    disp('EEG struc given; replacing event types')
    if length(convec) == size(EEG.event,2)
    for index = 1:length(convec)
        EEG.event(index).type = num2str(convec(index)); 
    end
    end
end



