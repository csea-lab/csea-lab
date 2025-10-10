function [GALmatrix] = paircompare_GALmatrix(subjects, conditions, cluster, filename, path)
% function to run timeGAL on multiple conditions of data; pairwise
% comparison
% subjects = list of subject numbers
% conditions = list of condition numbers
% cluster = sensors to average for timeGAL
% filename = name to store grid 
% path = path to folder of matfiles

GALmatrix = [];
GALmatrix.GALgrid = zeros(length(conditions)); 

% load empty vectors to store data
for con = 1:length(conditions)
    Cond = ['Cond' num2str(conditions(con))];
    data.(Cond) = zeros(129, 950, 1);  
    subj.(Cond) = zeros(1);
end

% store data
for con = 1:length(conditions)
    Cond = ['Cond' num2str(conditions(con))];
    for sub = 1:length(subjects)
        disp(sub)
        eval(['load("', path, num2str(subjects(sub)), '.trls.', num2str(conditions(con)), '.mat");'])
        data.(Cond) = cat(3, data.(Cond), Mat3D);
        subj.(Cond) = cat(1, subj.(Cond), ones(size(cat(3,Mat3D),3) , 1) * sub);
    end
end

% remove fillers and resave
conds = fieldnames(data);
for i = 1:length(conds)
    datafield = conds{i};
    currdata = data.(datafield);
    currdata(:,:,1) = [];
    data.(datafield) = currdata;
end
subs = fieldnames(subj);
for j = 1:length(subs)
    subfield = subs{j};
    subdata = subj.(subfield);
    subdata(1) = [];
    subj.(subfield) = subdata;
end

%% Now do the GAL stuff

% Loop over all condition pairs
for i = 1:length(conditions)
    Cond1 = ['Cond' num2str(conditions(i))];
    for j = 1:length(conditions)  
        Cond2 = ['Cond' num2str(conditions(j))];
        Pair = ['Pair' num2str(conditions(i)) num2str(conditions(j))];
        
        disp(Pair)

        con1subj = subj.(Cond1);
        con1 = data.(Cond1);
        con2subj = subj.(Cond2);
        con2 = data.(Cond2);

        permutationInds = randperm(length(con1subj));
        datcon1_2TimeGAL = con1(:,:,permutationInds);
        datcon1_Subj2TimeGAL = con1subj(permutationInds);

        permutationInds = randperm(length(con2subj));
        datcon2_2TimeGAL = con2(:,:,permutationInds);
        datcon2_Subj2TimeGAL = con2subj(permutationInds);

        minlengths = min([ length(con1subj) length(con2subj) ])

        datcon1_2TimeGAL = datcon1_2TimeGAL(:,:,1:minlengths);
        datcon2_2TimeGAL = datcon2_2TimeGAL(:,:,1:minlengths);
        datcon1_Subj2TimeGAL =  datcon1_Subj2TimeGAL(1:minlengths);
        datcon2_Subj2TimeGAL =  datcon2_Subj2TimeGAL(1:minlengths);

        [timeGALoutput] = timeGAL(datcon1_2TimeGAL, datcon2_2TimeGAL, datcon1_Subj2TimeGAL, datcon2_Subj2TimeGAL, 'ParallelComputing', true, 'ParallelComputingCores', 4, 'Channels', [1:124 129], 'Filename', 'resultsTimeGAL.mat')

        GALmatrix.GALgrid(i,j) = mean(timeGALoutput.GeneralizationMatrix.Topography(cluster,:));

        % To validate matrix results
        GALmatrix.(Pair) = mean(timeGALoutput.GeneralizationMatrix.Topography(cluster,:));

    end

    % show progress and save grid at this point in time
    disp(Cond1)
    save(filename, "GALmatrix")

end

end


