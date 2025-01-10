%% Script for analyzing all rdk data
cd '/Volumes/G-RAID Thunderbolt 3/OCA_project/OCA_RDK'

% info for the analysis
 spectime = 601:9600;
 Fbin = 78;

% Get a list of all files and folders in the current directory
files = dir('RDK*');

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

% axes for plots: 
% faxis=  0:1000/3200:125;  % for 601:2200
% faxis=  0:1000/2800:125;  % for 801:2200
% faxis=  0:1000/2400:125;  % for 1000:2200

taxis= -599:9000; 

% loop pver subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    % remove prior spec files
   delete *.ar.spec
   delete *.a1
   delete *.hamp9


   % calculate the spectrum 
    [spec, faxis] = get_FFT_atg(getfilesindir(pwd, '*.ar'), spectime);

    % names of at files
    fname1 = getfilesindir(pwd, '*.at1.ar');
    fname2 = getfilesindir(pwd, '*.at2.ar');
    fname3 = getfilesindir(pwd, '*.at3.ar');
    fname4 = getfilesindir(pwd, '*.at4.ar');

    % do the hilbert transform
    [demodmat1, ~]=steadyHilbert(fname1, 8.57, 500:600, 9, 0, []);
    [demodmat2, ~]=steadyHilbert(fname2, 8.57, 500:600, 9, 0, []);
    [demodmat3, ~]=steadyHilbert(fname3, 8.57, 500:600, 9, 0, []);
    [demodmat4, ~]=steadyHilbert(fname4, 8.57, 500:600, 9, 0, []);

    % Read at files
    at1 = ReadAvgFile(fname1);
    at2 = ReadAvgFile(fname2);
    at3 = ReadAvgFile(fname3);
    at4 = ReadAvgFile(fname4);

    % names of spec files
    fnamea1 = getfilesindir(pwd, '*.at1.ar.spec');
    fnamea2 = getfilesindir(pwd, '*.at2.ar.spec');
    fnamea3 = getfilesindir(pwd, '*.at3.ar.spec');
    fnamea4 = getfilesindir(pwd, '*.at4.ar.spec');
    
    % Read at files
    spec1 = ReadAvgFile(fnamea1);
    spec2 = ReadAvgFile(fnamea2);
    spec3 = ReadAvgFile(fnamea3);
    spec4 = ReadAvgFile(fnamea4);

    figure(1),  set(gcf, 'Position', [1800 500 800 800])
    subplot(3,1,1) % spectrum 
    plot(faxis(1:200), spec1(137,1:200)), title(folderNames{subindex}), hold on
    plot(faxis(1:200), spec2(137,1:200))
    plot(faxis(1:200), spec3(137,1:200))
    plot(faxis(1:200), spec4(137,1:200)), legend, xline(faxis(Fbin)), hold off

    subplot(3,1,2) % ERP
    plot(taxis, at1(137,:)), title(folderNames{subindex}), hold on
    plot(taxis, at2(137,:))
    plot(taxis, at3(137,:))
    plot(taxis, at4(137,:)), hold off
    
   subplot(3,1,3) % hilberts
    plot(taxis, demodmat1(137,:)), title(folderNames{subindex}), hold on
    plot(taxis, demodmat2(137,:))
    plot(taxis, demodmat3(137,:))
    plot(taxis, demodmat4(137,:)), hold off

    artfname = getfilesindir(pwd, '*artiflog.mat');
    load(artfname)
    disp(artifactlog)

    pause

    cd ..

    close all; 
    fclose('all'); 

end
