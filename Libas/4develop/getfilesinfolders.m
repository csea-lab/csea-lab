function filePaths = getfilesinfolders(parentFolder, prefix, suffix)
    % GETFILESINFOLDERS Collect paths of files with a specific suffix in subfolders with a specific prefix.
    %
    % Inputs:
    %   - parentFolder: Path to the parent folder (string/char array).
    %   - prefix: Prefix of the subfolder names to search (string/char array).
    %   - suffix: Suffix of the files to collect (string/char array).
    %
    % Output:
    %   - filePaths: Character array with the full paths to the files matching the criteria.

    % Initialize output
    filePaths = {};

    % Get a list of subfolders with the specified prefix
    subfolders = dir(fullfile(parentFolder, [prefix, '*']));
    subfolders = subfolders([subfolders.isdir]); % Only keep directories

    % Loop through each matching subfolder
    for i = 1:numel(subfolders)
        % Get the full path of the subfolder
        subfolderPath = fullfile(subfolders(i).folder, subfolders(i).name);

        % Get a list of files in the subfolder with the specified suffix
        files = dir(fullfile(subfolderPath, ['*', suffix]));

        % Collect the full paths of the matching files
        for j = 1:numel(files)
            filePaths{end+1} = fullfile(files(j).folder, files(j).name); %#ok<AGROW>
        end
    end

    % Convert output to a character array if non-empty
    if ~isempty(filePaths)
        filePaths = char(filePaths);
    else
        filePaths = ''; % Return empty string if no files are found
    end
end
