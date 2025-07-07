%% Script for postprocessing all emo pictures pupil data
%cd '/Users/andreaskeil/Desktop/Data'

% Get a list of all files and folders in the current directory
files = dir('pic*'); % start of the name

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


pupoutsum = zeros(2001,6);  

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    pupfile = getfilesindir(pwd, '*pup.out.mat');

    if ~isempty(pupfile)

        tmp = load(pupfile); 
        
        pupoutsum = pupoutsum+tmp.matout; 

       figure(101), plot(tmp.matout), pause

    end





    cd ..

    close all; 
    fclose('all'); 

end
