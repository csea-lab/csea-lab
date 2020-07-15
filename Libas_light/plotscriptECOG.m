
% plot all the conditions and channels for each person
for chnloop = 1:20
for fileindex = 25:32;
    a = load(deblank(filemat_pow(fileindex,:)));
    for chan = chnloop  
    contourf(taxis(200:end-100), faxis, squeeze(a.WaPower(chan,200:end-100, :))'),caxis([0.6 1.4]),    colorbar; %caxis([0.2 3.4]),   
    title([deblank(filemat_pow(fileindex,:)) '    '  num2str(chan)])
    pause, 
    end, 
end
end

%%
%%%
% plot all the conditions for each person, averaged across channels
for fileindex = 9: 16;
    a = load(deblank(filemat_pow(fileindex,:)));
    contourf(taxis(200:end-100), faxis, squeeze(mean(a.WaPower(:,200:end-100, :)))'), caxis([0.6 1.4]),colorbar;  
    title([deblank(filemat_pow(fileindex,:))])
    pause, 
end 

%%
mat1 = LTGbestmat1to8(:,:,[1 7 ]); 
mat2 = LTGbestmat1to8(:,:,[2 8]); 
diffmat = mat1-mat2; 
faxisindex = 1:18;

figure, subplot(3,1,1), contourf(taxis(200:700), faxis(faxisindex), squeeze(mean(mat1(200:700, faxisindex, :),3))', 15), caxis([0.9 1.07]), colorbar
subplot(3,1,2), contourf(taxis(200:700), faxis(faxisindex), squeeze(mean(mat2(200:700, faxisindex, :),3))', 15), caxis([0.9 1.08]), colorbar
subplot(3,1,3), contourf(taxis(200:700), faxis(faxisindex), squeeze(mean(diffmat(200:700, faxisindex, :),3))', 12),  caxis([-0.1 +.07]), colorbar

pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 500 700])

%%
mat1 = FGbestmat1to8;
faxisindex = 1:18;
figure
for x = 1:4
subplot(4,1,x), contourf(taxis(200:700), faxis(faxisindex), squeeze(mean(mat1(200:700, faxisindex, x),3))', 10), caxis([0.9 1.06]), colorbar
end


pos = get(gcf,'pos');
set(gcf,'pos',[pos(1) pos(2) 500 700])
