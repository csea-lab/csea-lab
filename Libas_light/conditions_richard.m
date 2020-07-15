
function [condivect] = conditions_richard(filemat)

for findex = 1: size(filemat,1)

        filepath = deblank(filemat(findex,:))

        %read set file
        EEG = pop_loadset(filepath);

        %find indices for a condition
        for x = 1:length(EEG.epoch)

            string = char(EEG.epoch(x).eventtype(:,1));

            start =strfind(string, '(') + 1; stop =strfind(string, ')')-1;

            if isempty(start), condivect(x) = 0; 
            else condivect(x) = str2num(string(start:stop));
            end

        end

        % find submatrix with trials in the 4 conditions
        data31 = EEG.data(:,:,find(condivect==31));
        data231 = EEG.data(:,:,find(condivect==231));
        data41 = EEG.data(:,:,find(condivect==41));
        data241 = EEG.data(:,:,find(condivect==241));


        disp('numbers of trials:')
        disp([size(data31, 3) size(data231, 3) size(data41,3) size(data241,3)])

         if ~all(([size(data31, 3) size(data231, 3) size(data41,3) size(data241,3)]-41).*-1), error('wrong number of trials!!!'), end

        eval(['save ' filepath '.31.mat data31 -mat'])
        eval(['save ' filepath '.231.mat data231 -mat'])
        eval(['save ' filepath '.41.mat data41 -mat'])
        eval(['save ' filepath '.241.mat data241 -mat'])

end % loop 



