% Root folder where participant subfolders are stored
rootDir = '/Volumes/TOSHIBA_EXT/CondiSpa/OG_Data';

% Get a list of all participant folders
participantDirs = dir(rootDir);
participantDirs = participantDirs([participantDirs.isdir] & ~startsWith({participantDirs.name}, '.'));

% Initialize full output table
allData = [];

for i = 1:length(participantDirs)
    pid = participantDirs(i).name;
    participantPath = fullfile(rootDir, pid);

    % Find required files within the participant's folder
    matFile = dir(fullfile(participantPath, '*trls.g.mat'));
    artiflogFile = dir(fullfile(participantPath, '*artiflog.mat'));
    datFile = dir(fullfile(participantPath, '*.dat'));

    if isempty(matFile) || isempty(artiflogFile) || isempty(datFile)
        fprintf('Missing file(s) for participant %s. Skipping.\n', pid);
        continue;
    end

    % Full paths
    matfilepath = fullfile(participantPath, matFile(1).name);
    artiflogfilepath = fullfile(participantPath, artiflogFile(1).name);
    datfilepath = fullfile(participantPath, datFile(1).name);

    % Run the function
    try
        outmat = hannahsingtrialscondispa(matfilepath, artiflogfilepath, datfilepath, 0);
        t = array2table(outmat, ...
            'VariableNames', {'ParticipantID', 'Trial', 'Condition', 'ssVEP', 'AlphaBaseline', 'AlphaStim'});
        allData = [allData; t];
    catch ME
        fprintf('Error processing %s: %s\n', pid, ME.message);
    end
end

% Save to CSV
writetable(allData, 'condispa_singletrial_df.csv');
