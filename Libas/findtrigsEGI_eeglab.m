
function [EEG]=findtrigsEGI_eeglab(EEG)

temp = EEG.event;
for x = 1:length(temp);
latencies(x) = temp(x).latency;
end

latencies2 =[-200 latencies];

trigsdist = diff(latencies2);

loseindices = find(trigsdist < 100);

if ~isempty(loseindices)
temp(loseindices) = [];
 
end

EEG.event = temp;




