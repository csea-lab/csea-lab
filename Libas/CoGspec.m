function [CoGmat] = CoGspec(inmat, freqvec)
%finds center of gravity according to Klimesch 1993
% input is a part of a channel by frequency spectrum that contains ONLY the
% frequency range of interest

for channel = 1:size(inmat,1)
    CoGmat(channel,:) = sum(freqvec .* inmat(channel,:))./ sum(inmat(channel, :)); 
end