function [string, maintrigtimevec] = bingham_findgoodtrig(EEG)

string = []; 

trigvec = {'S235', 'S239', 'S 76', 'S204'};
counter1 = 0; 
counter2 = 0;
counter3 = 0; 
counter4 = 0; 

timestamp = 0; 
trigtimes = zeros(size(EEG.event,2),1); 

 for x = 1:size(EEG.event,2) % this is a change by ak 10/18/23 to accomodate extra markers
          if strcmp(EEG.event(x).type, 'S235')
                  counter1 = counter1+1; 
                  timestamp = EEG.event(x).latency; 
              elseif strcmp(EEG.event(x).type, 'S239')
                  counter2 = counter2+1; 
                  timestamp = EEG.event(x).latency; 
              elseif strcmp(EEG.event(x).type, 'S 76')
                  counter3 = counter3+1; 
              elseif strcmp(EEG.event(x).type, 'S204')
                  counter4 = counter4+1; 
          end
          trigtimes(x) = [ timestamp];
 end


 countervec = [counter1 counter2 counter3 counter4]

 if ismember(94, countervec )
     countindex = find(countervec == 94);
 elseif ismember(92, countervec )
     countindex = find(countervec == 92);
 elseif  ismember(93, countervec )
     countindex = find(countervec == 93);
 end


string = trigvec{countindex}
checksumvec = diff(trigtimes);
test1 = length(find(checksumvec ==7));
test2 = length(find(checksumvec ==8)); 
checksum1 = length(find(checksumvec >1000));


      for x = 1:size(EEG.event,2) %  
          if strcmp(EEG.event(x).type, string), maintrigtimevec(x) = EEG.event(x).latency;
          end
      end


maintrigtimevec = diff(maintrigtimevec(maintrigtimevec~=0));



