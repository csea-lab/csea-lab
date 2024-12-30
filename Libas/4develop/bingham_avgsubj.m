function [GMspectrum_15HzFace] = bingham_avgsubj(filemat, outname)
% this function takes processed spectrum files ending in Spec.mat
% and computes an avg spectrum across subjects
% to run function you must have filemat defined
% e.g., filemat = getfilesindir(pwd, '*spec.mat') gets all files with spec.mat in the name
% outname is what you want to name outputted file
%
% if you are only calling specific conditions (e.g. angry) it may be helpful
% to define [GMspectrum] as something more specific e.g., [GMspectrumAngry]
% 
% you can also utilize the plot function by plotting GMspectrum.your variable
% of interest 
% e.g., plot(GMspectrum.freqs(1:100), GMspectrum.amphappy(17, 1:100)) plots
% the frequency from 1-100 with the amplitude for happy face from sensor 20
% for frequencies 1-100
filemat = getfilesindir(pwd, '*spec.mat');
outname = 'GMspectrum_15HzFace.mat';

GMspectrum_15HzFace = []; 

for fileindex = 1:size(filemat,1)
    
  load(deblank(filemat(fileindex,:))); 
  
        if fileindex == 1

        Sumamphappy = spectrum.amphappy;
        Sumampangry = spectrum.ampangry;
        Sumampsad = spectrum.ampsad;

        else

        Sumamphappy = Sumamphappy + spectrum.amphappy;
        Sumampangry = Sumampangry+ spectrum.ampangry;
        Sumampsad = Sumampsad+ spectrum.ampsad;

        end
        
 end
        
        GMspectrum_15HzFace.amphappy = Sumamphappy / fileindex;
        GMspectrum_15HzFace.ampangry = Sumampangry / fileindex;
        GMspectrum_15HzFace.ampsad = Sumampsad / fileindex;
        GMspectrum_15HzFace.freqs = spectrum.freqs;
        

  save (outname, 'GMspectrum_15HzFace')
  
end

