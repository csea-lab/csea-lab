%% Script for analyzing all rdk data
cd '/Users/andreaskeil/Desktop/day2data/'

% info for the analysis
% tag frequencies are at 6.666 and 15 Hz
 spectime = 301:1300;
 faxis = 0:0.5:250; 
 Fbin1 = 31;

% Get a list of all files and folders in the current directory
files = dir('gaborgen*');

%clear output
output = []; 

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);


% loop pver subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    % remove prior spec files
   delete *.ar.spec
   delete *.a1
   delete *.hamp15

      % names of at files
    fname1 = getfilesindir(pwd, '*.trls.10.mat');
    fname2 = getfilesindir(pwd, '*.trls.20.mat');
    fname3 = getfilesindir(pwd, '*.trls.30.mat');
    fname4 = getfilesindir(pwd, '*.trls.40.mat');

    % Read trls.mat files
    spec1 = load(fname1);
    spec2 = load(fname2);
    spec3 = load(fname3);
    spec4 = load(fname4);
   
    % do 3d spec
   [specavg1, ~] = FFT_spectrum3D(spec1.Mat3D, spectime, 500); 
   [specavg2, ~] = FFT_spectrum3D(spec2.Mat3D, spectime, 500); 
   [specavg3, ~] = FFT_spectrum3D(spec3.Mat3D, spectime, 500); 
   [specavg4, freqs] = FFT_spectrum3D(spec4.Mat3D, spectime, 500); 

 % plotting
    figure(1),  set(gcf, 'Position', [1800 500 800 800])
    plot(faxis(1:70), specavg1(75,1:70)), title(folderNames{subindex}), hold on
    plot(faxis(1:70), specavg2(75,1:70))
    plot(faxis(1:70), specavg3(75,1:70))
    plot(faxis(1:70), specavg4(75,1:70)), legend, xline(faxis(Fbin1)),  hold off


    artfname = getfilesindir(pwd, '*artiflog.mat');
    load(artfname)
    disp(artifactlog)

    pause

    cd ..

    close all; 
    fclose('all'); 

end
