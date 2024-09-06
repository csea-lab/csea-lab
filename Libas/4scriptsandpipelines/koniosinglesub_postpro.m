%% Script for analyzing all konio data
% Get a list of all files and folders in the current directory
files = dir('konio*');

% Filter out the non-folder entries
dirFlags = [files.isdir];

% Extract the names of the folders
folderNames = {files(dirFlags).name};

% Remove the '.' and '..' folders
folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

% Display the folder names
disp('Folders in the current working directory:');
disp(folderNames);

% info for spectrum
spectime = 1000:2200; 
Fbin  = 19; 
Hbin = 37; 

% axes for plots: 
% faxis=  0:0.3125:125;  % for 601:2200
% faxis=  0:1000/2800:125;  % for 801:2200
faxis=  0:1000/2400:125;  % for 1000:2200

taxis= -600:2:3800; 

% loop pver subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    datfile = getfilesindir(pwd, '*.dat');
    rawfile = getfilesindir(pwd, '*.RAW');

    % remove rior spec files
   delete *.ar.spec

   % calculate the spectrum 
    [spec] = get_FFT_atg(getfilesindir(pwd, '*.ar'), spectime);

    % read at files
    fname21 = getfilesindir(pwd, '*.at21.ar');
    fname22 = getfilesindir(pwd, '*.at22.ar');
    fname23 = getfilesindir(pwd, '*.at23.ar');
    fname24 = getfilesindir(pwd, '*.at24.ar');

    at21 = ReadAvgFile(fname21);
    at22 = ReadAvgFile(fname22);
    at23 = ReadAvgFile(fname23);
    at24 = ReadAvgFile(fname24);

    % read spec files
    fnamea21 = getfilesindir(pwd, '*.at21.ar.spec');
    fnamea22 = getfilesindir(pwd, '*.at22.ar.spec');
    fnamea23 = getfilesindir(pwd, '*.at23.ar.spec');
    fnamea24 = getfilesindir(pwd, '*.at24.ar.spec');

    spec21 = ReadAvgFile(fnamea21);
    spec22 = ReadAvgFile(fnamea22);
    spec23 = ReadAvgFile(fnamea23);
    spec24 = ReadAvgFile(fnamea24);

    subplot(3,1,1) % spectrum 
    plot(faxis(1:80), spec21(75,1:80)), title(folderNames{subindex}), hold on
    plot(faxis(1:80), spec22(75,1:80))
    plot(faxis(1:80), spec23(75,1:80))
    plot(faxis(1:80), spec24(75,1:80)), xline(faxis(Fbin)), xline(faxis(Hbin)), legend, hold off

    subplot(3,1,2)
    plot(taxis, at21(75,:)), title(folderNames{subindex}), hold on
    plot(taxis, at22(75,:))
    plot(taxis, at23(75,:))
    plot(taxis, at24(75,:)), legend, hold off
    
    subplot(3,1,3)
    plot(taxis, at21(55,:)), title(folderNames{subindex}), hold on
    plot(taxis, at22(55,:))
    plot(taxis, at23(55,:))
    plot(taxis, at24(55,:)), xline(taxis(spectime(end))), hold off

    difflumi = spec22(:,Fbin) - spec21(:,Fbin); 
    topomap(difflumi) 

    diffkoni= spec24(:,Fbin) - spec23(:,Fbin); 
    topomap(diffkoni) 

    outvecF = [spec21(75,Fbin) spec22(75,Fbin) spec23(75,Fbin) spec24(75,Fbin)]
    outvecH = [spec21(75,Hbin) spec22(75,Hbin) spec23(75,Hbin) spec24(75,Hbin)]
    sumvec = outvecF+outvecH

    pause

    output(subindex,:) = [outvecF outvecH];

    cd ..

    close all; 
    fclose('all'); 

end
