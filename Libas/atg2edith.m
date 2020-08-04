%convert2edith
%reads at file, converts each time point to flipped ascii with header
function [] = atg2edith(atfilemat);

chanvec = [ 'F7          F5          F3          Fz          F4          F6          F8         FT7         FC5         FC3         FCz         FC4         FC6         FT8          T7          C5          C3          Cz          C4          C6          T8         TP7         CP5         CP3         CPz         CP4         CP6         TP8          P7          P5          P3          Pz          P4          P6          P8          O1          O2        EOGV        EOGH' ];

for fileindex = 1:size(atfilemat,1)
    
    deblank(atfilemat(fileindex,:))

    mat = readavgfile(deblank(atfilemat(fileindex,:))); 

        for index = 1:size(mat,2)
            a = [mat(:,index)' 0 0]; % append 2 zeros for veog chan and heog chan
            fid = fopen([deblank(atfilemat(fileindex,:)) '.' num2str(index) '.dat'], 'w');
            fprintf(fid, '%s\n', chanvec);
            dlmwrite([deblank(atfilemat(fileindex,:)) '.' num2str(index) '.dat'],a,'delimiter','\t', '-append');
            fclose(fid)
        end
        
end