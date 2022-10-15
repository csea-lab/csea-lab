function [onsets, names, durations] = OldSPM2SPM(filemat)

% reads in old SPM condition file and writes new format condition file for
% use with halfpipe

for fileindex = 1:size(filemat)
   a = load(deblank(filemat(fileindex,:))); 

   namesold = a.spm.cond;
   onsetsold = a.spm.onset;
   durationsold = a.spm.duration;

   temp1 = namesold{1};
   temp2 = namesold{3};

   % now make the new ones
   names = {temp1(1:7), temp2(1:7)}

   onsets = {[onsetsold(1,:) onsetsold(2,:)], [onsetsold(3,:) onsetsold(4,:)]}

   durations = {[durationsold(1,:) durationsold(2,:)], [durationsold(3,:) durationsold(4,:)]}

   eval(['save ' deblank(filemat(fileindex,:)) 'new.mat names onsets durations -mat'])

end