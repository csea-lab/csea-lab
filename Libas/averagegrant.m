function [medianvector] = averagegrant(BPMvec); 
%takes a vector of BPMvalues (70) and calculates 7 medians for 10 secs each

index = 1; 
for start = 1:10:64
    medianvector(index) =median( BPMvec(start:start+9)); 
    index = index+1; 
end


