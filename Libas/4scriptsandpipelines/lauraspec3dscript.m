% cd /Users/andreaskeil/Desktop/Gaborgen_Laura/StartingPoint/Gaborgen24/CSDfiles

filemat = getfilesindir(pwd, '*app*.mat');

timewinSP = 501:1500; %start after onset ERP
    
% [spec] = get_FFT_mat3d(filemat, timewinSP, 500);

[RESS_time] = RESS_mat(filemat, 51:97, timewinSP, 500, 15, 1);
% RESS does not seem to work well with extinction because few trials

filemat = getfilesindir(pwd, '*RESSpow.mat');

%% pipeline for RESS files
filemat = getfilesindir(pwd, '*.RESSpow.at');
mergemulticons(filemat, 14, 'GM31.RESSpow')
bin = 31

[repmat] = makerepmat(filemat, bin, 14, []);

mat4plot = squeeze(repmat(1, bin,:, [1 2 3 4 5 7 8 9 11 12 13 14]))


%% pipeline for spec files
filemat = getfilesindir(pwd, '*.spec');
mergemulticons(filemat, 14, 'GM31.3dspec.spec')
bin = 31

[repmat] = makerepmat(filemat, bin, 14, []);

mat4plot = squeeze(repmat(52, bin,:, [1 2 3 4 5 7 8 9 11 12 13 14]))

[Fcontmat,rcontmat,MScont,MScs, dfcs]=contrast_rep_sign(squeeze(repmat(:,bin, :, [5 7 8 9])), [ 1.5 0.5 -.5 -1.5]);

 generMcteague = [1.75 1.25 0.25 -3.25];

figure, plot(Fcontmat)

%%

for index = 1:size(filemat,1)
    
    name = deblank(filemat(index,:));
    
    load(name);
    
    % data = CSDarray; 

    data = outmat; 
    

 
  
end