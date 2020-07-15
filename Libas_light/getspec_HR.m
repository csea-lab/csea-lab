function [specmat, faxis, IDvec] = getspec_HR(filemat)
% opens the file from lisa (HR for patients a 30 segments with 20 samples each )
% reads in 30 segments for each subject...
% calculates one spectrum over all of these
% saves the spectrum in a new file
% empty cells are interpolated by that person's overall mean

specmat = []; 
IDvec = []; 
% define window function
        
        M2 = 4;
        
        squarecos1 = (cos(pi/2:(pi-pi/2)/M2:pi-(pi-pi/2)/M2)).^2;
        
        squarecosfunction = [squarecos1 ones(1,19 -length(squarecos1).*2) fliplr(squarecos1)];
        
 % read data and start putting it together
        
line = []; 

for fileinindex = 1:size(filemat,1); 

    fid = fopen(filemat(fileinindex,:)); 
    
    line = fgetl(fid);
    
    while length(line) > 1
        
        subjectmat = [];
        
        fprintf('.')
        
    
        for lineindex = 1:30   % loop 30 segments of one subject
          
             line = fgetl(fid);
          
             if line < 0, break, end
             
             if lineindex == 1; 
                IDvec = [IDvec str2num(line(1:4));]
               end
            
             line = str2num(line(18:length(line)));
         
             
             if length(line) ~= 20
                 if lineindex ==1 || lineindex == 2
                     line = zeros(1,20); % zero padding
                 else
                     line = mean(subjectmat); 
                 end
                 fprintf('/')
             end
             
             line = bslcorr(line, 2:18); 
            
             subjectmat = [subjectmat; line(1:19) .* squarecosfunction];
                     
        end
        
        if ~isempty(subjectmat)
        
            b = reshape(subjectmat', 1,19*30);
        
        %plot(b), pause(.1);
    
        % here: do FFT and get amplitude
                     
                NFFT = 570; 
                NumUniquePts = ceil((NFFT+1)/2); 
                fftMat = fft (b, 570);  % 
                Mag = abs(fftMat);                                                   % Amplitude berechnen
                Mag = Mag*2;   

                Mag(1) = Mag(1)/2;                                                   % DC trat aber nicht doppelt auf
                if ~rem(NFFT,2),                                                        % Nyquist Frequenz (falls vorhanden) auch nicht doppelt
                    Mag(length(Mag))=Mag(length(Mag))/2;
                end

                Mag=Mag/NFFT;                                                         % FFT so skalieren, dass sie keine Funktion von NFFT ist
                spec = real(fftMat.*conj(fftMat)/570);
                spec = spec(1:285); 
                faxis = 0:0.00352:1; 
                
          
               % plot(faxis, spec), pause
                
                specmat = [specmat; spec]; 
        end

       
    end
    
    
end




