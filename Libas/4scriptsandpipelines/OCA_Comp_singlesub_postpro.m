%% Script for analyzing all rdk data
cd '/Volumes/G-RAID Thunderbolt 3/OCA_project/OCA_comp'

% info for the analysis
% tag frequencies are at 6.666 and 15 Hz
 spectime = 1051:4050;
 Fbin1 = 21; 
 Fbin2 = 46; 
 taxis = -599:4200;

% Get a list of all files and folders in the current directory
files = dir('Comp*');

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
   delete *.hamp9


   % calculate the spectrum 
    [spec, faxis] = get_FFT_atg(getfilesindir(pwd, '*.ar'), spectime);

    % names of at files
    fname1 = getfilesindir(pwd, '*.at1.ar');
    fname2 = getfilesindir(pwd, '*.at2.ar');
    fname3 = getfilesindir(pwd, '*.at3.ar');
    fname4 = getfilesindir(pwd, '*.at4.ar');

    % do the hilbert transform at 6.666
    [demodmat1, ~]=steadyHilbert(fname1, 6.66, 500:600, 9, 0, []);
    [demodmat2, ~]=steadyHilbert(fname2, 6.66, 500:600, 9, 0, []);
    [demodmat3, ~]=steadyHilbert(fname3, 6.66, 500:600, 9, 0, []);
    [demodmat4, ~]=steadyHilbert(fname4, 6.66, 500:600, 9, 0, []);

     % do the hilbert transform
    [demodmat11, ~]=steadyHilbert(fname1, 15, 500:600, 9, 0, []);
    [demodmat12, ~]=steadyHilbert(fname2, 15, 500:600, 9, 0, []);
    [demodmat13, ~]=steadyHilbert(fname3, 15, 500:600, 9, 0, []);
    [demodmat14, ~]=steadyHilbert(fname4, 15, 500:600, 9, 0, []);

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
    plot(faxis(1:200), spec4(137,1:200)), legend, xline(faxis(Fbin1)), xline(faxis(Fbin2)), hold off

    subplot(3,1,2) % ERP
    plot(taxis, at1(137,:)), title(folderNames{subindex}), hold on
    plot(taxis, at2(137,:))
    plot(taxis, at3(137,:))
    plot(taxis, at4(137,:)), hold off
    
   subplot(3,1,3) % hilberts
    plot(taxis, demodmat1(137,:)), title(folderNames{subindex}), hold on
    plot(taxis, demodmat2(137,:))
    plot(taxis, demodmat3(137,:))
    plot(taxis, demodmat4(137,:)), 
    plot(taxis, demodmat11(137,:))
    plot(taxis, demodmat12(137,:))
    plot(taxis, demodmat13(137,:))
    plot(taxis, demodmat14(137,:))
    hold off

    artfname = getfilesindir(pwd, '*artiflog.mat');
    load(artfname)
    disp(artifactlog)

    pause

    cd ..

    close all; 
    fclose('all'); 

end
