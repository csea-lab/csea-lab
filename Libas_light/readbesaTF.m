%readbesaTF
% reads an ascii exported text file into matlab (optional: and save as a matlab .mat
% file with freq X time points X brain region/electrodes)
% then plots the selected channel(s)
function [outmat] = readbesaTF(filepath, channels4plot) 

outmat = []; 
fid = fopen(filepath); 

headerline1 = fgetl(fid); 
headerline2 = fgetl(fid); 

indexchans = findstr(headerline1, ['NumberChannels=']);
numchans = str2num(headerline1(indexchans+15:indexchans+17))

indexfreqs = findstr(headerline1, ['NumberFrequencies=']);
numfreqs = str2num(headerline1(indexfreqs+18:indexfreqs+20))

indextsamples = findstr(headerline1, ['NumberTimeSamples=']);
numtsamples = str2num(headerline1(indextsamples+18:indextsamples+20))

% find out frequency axis and time axis
% time
indextiminterval = findstr(headerline1, ['IntervalInMS=']);
timeinterval = str2num(headerline1(indextiminterval+13:indextiminterval+17))

indextimestart = findstr(headerline1, ['TimeStartInMS=']);
timestart = str2num(headerline1(indextimestart+14:indextimestart+20))

%frequency
indexfreqstart = findstr(headerline1, ['FreqStartInHz=']);
freqstart = str2num(headerline1(indexfreqstart+14:indexfreqstart+18))

indexfreqinterval = findstr(headerline1, ['FreqIntervalInHz=']);
freqinterval = str2num(headerline1(indexfreqinterval+17:indexfreqinterval+20))

% read it int matrix
% create empty matrix

outmat = zeros(numfreqs, numtsamples, numchans); 

for chan = 1:numchans
    for freq = 1:numfreqs+1;
    line = fgetl(fid); if ~isempty(line), outmat(freq,:,chan) = str2num(line)'; end
    end
end


% creat axes for plot
taxis = timestart:timeinterval:(numtsamples*timeinterval)-(abs(timestart))-timeinterval
faxis = freqstart:freqinterval:(numfreqs*freqinterval)+freqstart-freqinterval

contourf(taxis, faxis, outmat(:,:,channels4plot)), colorbar
xlabel('time in ms')
ylabel('frequency')









