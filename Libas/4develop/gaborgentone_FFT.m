


clc
clear
cd '/Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline';
% Define the main directory containing participant folders
mainDir = '/Users/csea/Documents/SarahLab/Sarah_Data/GaborgenTone/Data/pipeline';

% Define file pattern for participant folders
participantFolderPattern = 'gg*';

% Define file pattern for data files
dataFilePattern = 'gaborgentone_*.trls*.mat';

% Get a list of participant folders
participantFolders = dir(fullfile(mainDir, participantFolderPattern));

relevantFrequencyIndices = 1:32;
%alphaFrequencyIndices = 22:32; %8hz starts at 22


% Loop through each participant folder
for i = 1:length(participantFolders)

    % Get current participant folder name
    currentFolder = participantFolders(i).name;

    cd(fullfile(currentFolder))

    % Create full path to participant folder
    participantFolderPath = fullfile(mainDir, currentFolder);

    % Get a list of data files within the participant folder
    dataFiles = dir(fullfile(participantFolderPath, dataFilePattern));

    % Loop through each data file
    for j = 1:length(dataFiles)

        % Get current data file name
        dataFile = dataFiles(j).name;

        % Create full path to data file
        dataFilePath = fullfile(participantFolderPath, dataFile);

        % Load data
        ggtone = load(dataFilePath);

        % Extract data matrix
        ggtone_mat = ggtone(1).Mat3D;
        [amp, freqs, fftcomp] = freqtag_FFT3D(ggtone_mat, 500);

        conditionNumberStr = extractBetween(dataFile, 'trls.', '.mat');
        conditionNumber = str2double(conditionNumberStr);

        freqs(relevantFrequencyIndices), amp(62,relevantFrequencyIndices);
        plot(freqs(relevantFrequencyIndices), amp(62,relevantFrequencyIndices));
    end
    cd ..
end