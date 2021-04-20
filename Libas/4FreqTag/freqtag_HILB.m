function [power, phase, complex] = freqtag_HILB(dataset, taggingfreq, filterorder, sensor2plot, plotflag, fsamp);

%This function applies the Fast Fourier Transform on a 2-D data, where M are sensors and N time points.
%taggingfreq is the tagging frequency
%filterorder is the order of the filter to be aplied on the data
%fsamp is the sampling rate 

    taxis = 0:1000/fsamp:size(dataset,2)*1000/fsamp - 1000/fsamp;   % Calculate the time axis
    taxis = taxis/1000; 
   
    uppercutoffHz = taggingfreq + .5;                            % Design the LOW pass filter around the taggingfreq   
    [Blow,Alow] = butter(filterorder, uppercutoffHz/(fsamp/2));  
    
    lowercutoffHz = taggingfreq - .5;                            % Design the HIGH pass filter around the taggingfreq
    [Bhigh,Ahigh] = butter(filterorder, lowercutoffHz/(fsamp/2)); 
	
	
     dataset = dataset';             % The filtfilt function takes the time-point as rows and sensors as columns
    
  
     lowpassdata = filtfilt(Blow,Alow, dataset);               % Filter the data using the low-pass filter 
     lowhighpassdata = filtfilt(Bhigh, Ahigh, lowpassdata);    % Filter the low-pass data using the high-pass filter
     
   
     tempmat = hilbert(lowhighpassdata);                    % Calculate Hilbert Transform on the filtered data
     
    
     tempmat = tempmat';                                    % Sensors as rowls again
     
         
     if plotflag                                            % Plot filtered Oz data in blue, imaginary part in red, real part in black 
         
    figure(10)
      plot(taxis, lowhighpassdata(:,sensor2plot)), hold on, plot(taxis, imag(tempmat(sensor2plot,:)), 'r'), plot(taxis, abs(tempmat(sensor2plot,:)), 'k')
    pause(.5)
     end
     
     hold off
    
 power = abs(tempmat);                                 % Amplitude over time (real part)
 phase = angle(tempmat);                               % Phase over time 
 complex = tempmat;                                    % Imaginary part