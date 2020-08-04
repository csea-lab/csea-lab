function [outvec, criterion] = get_jacknifevec(inmat, searchwindowvector); 

% inmat is matrix of waveforms with subjects as ythe first dimension and
% time as the scond 
% searchwindowvector is the vector of the sample points in time, in which
% we are to search for the maximum or minimum, IN SAMPLE POINTS of the
% whole epoch submitted in inmat

subjectvec = 1:size(inmat,1); 

for subject = 1:size(inmat,1)
    
    % create a mean vector that replaces this subject: 
    
    subjectvec(subjectvec~=subject)
    
    tempvec = mean(inmat(subjectvec(subjectvec~=subject),:));
    
    plot(tempvec)
    
    pause(.1)
    
    hold on 
    
    
    % from that tempvec, estimate latency at 50% criterion
    
    criterion(subject) = min(tempvec(searchwindowvector))./2;
    
    findvec = find(tempvec(searchwindowvector) < criterion(subject)); 
    
    outvec(subject) = findvec(1) + searchwindowvector(1); 
    
end

outvec = outvec'
mean(criterion)
