%% Script for analyzing all konio data

% info for spectrum
spectime = 201:2200; 
Fbin  = 31; 
Hbin = 61; 

% Get a list of all files and folders in the current directory
files = dir('konio*');

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
faxis = 0:1000/4000:125; 

taxis= -600:2:3800; 

% loop pver subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    % remove prior spec files
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

    figure(1),  set(gcf, 'Position', [1800 500 800 800])
    subplot(3,1,1) % spectrum 
    plot(faxis(1:80), spec21(75,1:80)), title(folderNames{subindex}), hold on
    plot(faxis(1:80), spec22(75,1:80))
    plot(faxis(1:80), spec23(75,1:80))
    plot(faxis(1:80), spec24(75,1:80)), legend, xline(faxis(Fbin)), xline(faxis(Hbin)), hold off

    subplot(3,1,2)
    plot(taxis, at21(75,:)), title(folderNames{subindex}), hold on
    plot(taxis, at22(75,:))
    plot(taxis, at23(75,:))
    plot(taxis, at24(75,:)), hold off
    
    subplot(3,1,3)
    plot(taxis, at21(55,:)), title(folderNames{subindex}), hold on
    plot(taxis, at22(55,:))
    plot(taxis, at23(55,:))
    plot(taxis, at24(55,:)), xline(taxis(spectime(end))), hold off

    difflumiF = spec22(:,Fbin) - spec21(:,Fbin); 

    diffkoniF= spec24(:,Fbin) - spec23(:,Fbin); 

    difflumiH = spec22(:,Hbin) - spec21(:,Hbin); 

    diffkoniH= spec24(:,Hbin) - spec23(:,Hbin); 

    % topomap([difflumiF diffkoniF difflumiH diffkoniH (difflumiF+difflumiH)./2 (diffkoniF+diffkoniH)./2])
    topomap([difflumiF diffkoniF]); 

    outvecF = [spec21(75,Fbin) spec22(75,Fbin) spec23(75,Fbin) spec24(75,Fbin)]
    outvecH = [spec21(75,Hbin) spec22(75,Hbin) spec23(75,Hbin) spec24(75,Hbin)]
    sumvec = outvecF+outvecH

    artfname = getfilesindir(pwd, '*artiflog.mat');
    load(artfname)
    disp(artifactlog)

    pause

    output(subindex,:) = [outvecF outvecH];

    cd ..

    close all; 
    fclose('all'); 

end
