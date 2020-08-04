%convert2edith
%reads ascii plv file, converts to flipped ascii with header
function [] = convert2edith(inmat);

chanvec = [ 'F7          F5          F3          Fz          F4          F6          F8         FT7         FC5         FC3         FCz         FC4         FC6         FT8          T7          C5          C3          Cz          C4          C6          T8         TP7         CP5         CP3         CPz         CP4         CP6         TP8          P7          P5          P3          Pz          P4          P6          P8          O1          O2        EOGV        EOGH' ];

for index = 1:size(inmat)
    a = load(deblank(inmat(index,:))); 
    a = a'; 
    fid = fopen([deblank(inmat(index,:)) '.dat'], 'w');
    fprintf(fid, '%s\n', chanvec);
    %dlmwrite([deblank(inmat(index,:)) '.dat'],a,'delimiter','\t','precision',6, '-append');
    dlmwrite([deblank(inmat(index,:)) '.dat'],a,'delimiter','\t', '-append');
    fclose(fid)
end