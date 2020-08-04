function MergeAvgCons(studypre,blocks,stims,suffix)

%studypre should be a string with the prefix used for files from the study
%blocks should be the number of phases or blocks.
%stims should be the number of different stimuli that repeat per block.
%suffix shoud be a set of empty brackets [] if the files are .at files. For
%other file suffixes, include a string that should be tagged onto the end
%(e.g., '.spec').

%Create the total list of condition labels as a column vector:
%(number of blocks * number of stims)
bmat = repmat(1:blocks,stims,1);
blocksmat = bmat(:);
blocksmat = blocksmat*100; %presumes that the conditions are labeled with blocks in the hundreds place.
smat = repmat(1:stims,1,blocks);
stimsmat = smat(:);
cons = blocksmat + stimsmat;

%Create a filematrix with a list of filematrices that match the list of
%conditions.
filemat = repmat('filemat',(blocks*stims),1);
matpre = repmat('*at*',(blocks*stims),1);
matpost = repmat('*.ar*',(blocks*stims),1);
matnos = [matpre (char(num2str(cons))) matpost];
filematnos = [filemat (char(num2str(cons)))];

%For each condition, create the filematrices mentioned in filematnos. 
%Also, save matrices to base workspace.
for x = 1:[size(cons)]
    (assignin('base',filematnos(x,:), getfilesindir(pwd,matnos(x,:))));
    (eval([filematnos(x,:) '= getfilesindir(pwd,matnos(x,:))']));
    GM = size(eval(filematnos(x,:)));
    GM = num2str(GM(1,1)); %measure number of files in each matrix of filematnos.
    y = eval(filematnos(x,:)); %y is each filematrix listed in filematnos.
    [OutFilePath,NormVec]=MergeAvgFiles(y,['GM' (GM) '_' (studypre) '.at' (char(num2str(cons(x,:)))) '.ar' (suffix)],1,1,[],0,[],[],0,0); %Create GMs.
end

end