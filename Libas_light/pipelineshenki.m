function [specavg, freqs] = pipelineshenki(filemat, locations); 


% top part is rutgers2d3d, then phaseampcoupling
for fileindex = 1:size(filemat,1);

    filepath = filemat(fileindex,:); 
    
rawfile = deblank(filepath)

disp('reading data, this may take a while') 

events = ft_read_event(rawfile);
orig = ft_read_data(rawfile);

disp('done reading data, finding resting triggers') 

for x = 1:length(events) , triggers(x) = events(x).sample; end

% find resting period 
indexvecresting = []; 
 for x = 1:length(events), if strcmp(events(x).value, 'REEO'), indexvecresting = [indexvecresting x]; end, end
 
%get rid of inital resting, if any...
indexvecresting = indexvecresting(indexvecresting>1000); 

restingstartsample = events(indexvecresting(1)).sample

orig = orig(1:62, restingstartsample:restingstartsample+45000-1); % extract 3 minutes and the first 62 channels

       [Blow,Alow] = butter(4, .5); 
    
     [Bhigh,Ahigh] = butter(2, 0.008, 'high'); 
	
	% flip AvgMat and filter over all channels
    orig = orig'; 
    
    % filter now
     lowpasssig = filtfilt(Blow,Alow, orig); 
     lowhighpasssig = filtfilt(Bhigh, Ahigh, lowpasssig);
     
     orig = lowhighpasssig';


% averager reference and add two empty channels at 63 and 64, put avg ref
% channel at 65
orig = avg_ref_add(orig);

orignew = zeros(65, size(orig,2)); 

orignew(1:62, :) = orig(1:62,:); 
orignew(end, :) = orig(63,:); 

disp('epoching and artifact correction') 

% put in 3d and find bad segments
        datamat = reshape(orignew, [65 500 90]); % 90 segments with 500 sample point = 2 secs, 3 minutes total
        
        stdvec = squeeze(median(std(datamat)));
        badindex = find(stdvec > median(stdvec) .* 1.5) ;
        datamat(:, :, badindex) = [];
        
  % find and interpolate bad trials      
       datamat =  scadsAK_3dchan(datamat, locations);
   
disp('done. percent good segments:')
disp(100-(length(badindex)./90).*100)

 [specavg, freqs] = FFT_spectrum3D(datamat, 1:500, 250);
 

    
%    [File,Path,FilePath]=SaveAvgFile([rawfile '.spec'],specavg,[],[], fsmapnew);
    
 
for low = 12:1:12
 [powermat, phasemat, CFC_norm, fullspecmat ] = phaseampcoupling_mat(datamat, low, 60, 38, 2, 1, 1:500, 0, rawfile); 
 
end


 
end % loop over files




