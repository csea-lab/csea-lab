%% Script for postprocessing all emo pictures pupil data
%cd '/Users/andreaskeil/Desktop/Data'
clear
% Get a list of all files and folders in the current directory
files = dir('emo*'); % start of the name

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

pupoutsum = zeros(3,11001);   

% loop over subjects
for subindex = 1:size(folderNames,2)

    eval(['cd ' folderNames{subindex}])

    pupfile = getfilesindir(pwd, '*pup.out.mat');

    if ~isempty(pupfile)

        tmp = load(pupfile); 

        databsl = bslcorr(tmp.matout', 400:500);

        time = -1000:size(databsl, 2)-1001;

        pupoutsum = pupoutsum+databsl; 

       figure(101), 
       subplot(2,1,1), plot(time, databsl(1,:), 'g', time, databsl(2,:), 'k', time, databsl(3,:), 'r'), title(['set1 subject: ' num2str(subindex)])


    end

      subplot(2,1,2), plot(time, pupoutsum(1,:), 'g', time, pupoutsum(2,:), 'k', time, pupoutsum(3,:), 'r'),  legend('p', 'n', 'u', 'location', 'southwest'), title('set1 cumulative sum')


pause

    cd ..

    if subindex<size(folderNames,2)
    close all; 
    fclose('all'); 
    end

end
