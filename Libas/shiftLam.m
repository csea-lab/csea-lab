% shiftLam.m
% makes connectivity matrix MX by laminating shifted versions of the 
% same row vector rv that contains the desired connectivity profile

function MX = shiftLam(rv) % declare the function

[dum,nUnits] = size(rv); % find the number of units in the network
for i = 1:nUnits % for each unit in the network
   MX(i,:) = rv; % set its row of the weight matrix to the profile
   rv = [rv(nUnits) rv(1:nUnits-1)]; % shift the profile
end % end the loop
