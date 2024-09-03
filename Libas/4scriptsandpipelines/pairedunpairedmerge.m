function pairedunpairedmerge(matfilemat1, matfilemat2, igfilemat1, igfilemat2)

for fileindex = 1:size(matfilemat1,1)

    igfile1 = igfilemat1(fileindex,:);
    igfile2 = igfilemat2(fileindex,:);
    
    matfile1 = matfilemat1(fileindex,:);
    matfile2 = matfilemat2(fileindex,:);

    igfolder = '/home/laura/Documents/Gaborgen24_Day1_Day2/Day2/raw_eeg_files/';

    matfolder = '/home/laura/Documents/Gaborgen24_Day1_Day2/Day2/raw_eeg_files/app_files/';


    igfid1 = fopen([igfolder igfile1]);
    throwaway = fgetl(igfid1) ;
    indexvec1 = str2num(fgetl(igfid1));


    igfid2 = fopen([igfolder igfile2]);
    throwaway = fgetl(igfid2) ;
    indexvec2 = str2num(fgetl(igfid2));

    ordervec = [indexvec1, indexvec2];

    [~, sortindexvec] = sort(ordervec); 

    temp1 = load([matfolder matfile1]);

    mat1 = temp1.outmat; 

    temp2 = load([matfolder matfile2]);

    mat2 = temp2.outmat; 

    matboth = cat(3, mat1, mat2); 

    outmat = matboth(:, :, sortindexvec); 

    matfileout = matfile1; 

    matfileout(end-5:end-4) = '20';

    eval(['save ' matfileout ' outmat -mat']); 

end



