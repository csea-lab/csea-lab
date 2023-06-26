%%
clear
cd '/Users/andreaskeil/Desktop/MPP_atFiles/beta'

searchstring = '*long.at11.ar'

savestring = searchstring; 

savestring([1, strfind(searchstring, '.')]) = []; 

filemat = getfilesindir(pwd, searchstring)

taxis = -2600:2:2600; 

for sub = 1:29

    dataPP = ReadAvgFile(deblank(filemat(sub,:)));

    if size(dataPP,1) == 128;
        dataPP = [dataPP; dataPP(55,:)]; 
    end

        for sens = 1:129
            dataConv(sens,:) = conv(dataPP(sens,:), gausswin(300));        
        end

        SaveAvgFile(['Conv_' deblank(filemat(sub,:))], dataConv, [], [], 500);

       if sub ==1
        datasum = dataConv; 
       else
        datasum  = datasum + dataConv; 
       end

      %  plot(dataConv'), pause(1)

end

%datasum = [datasum; datasum(55,:)];

eval(['sum' savestring ' = datasum;'])

%SaveAvgFile(['sumgam' searchstring(2:end)], datasum, [], [], 500);

%%

filemat_11 = getfilesindir(pwd, 'Con*11.ar')
filemat_12 = getfilesindir(pwd, 'Con*12.ar')
[topo_tmat, mat3d_1, mat3d_2] = topottest(filemat_12, filemat_11, [300:1300], 'test.at');

data2 = cat(1, mat3d_1, mat3d_2);
labels = [ones(129,1); ones(129,1).*2];
meandata = squeeze(mean(data([61:100 189:228], : , :), 3));

%%
for x = 1:2900
    VMdl = fitclinear(meandata(:,x)',labels3,'ObservationsIn','columns','KFold',10,...
    'Learner','logistic','Solver','sparsa','Regularization','lasso');
    ce(x) = kfoldLoss(VMdl);
    if round(x./100) == x./100, fprintf(num2str(x)), end
end
%%
for subject = 1:87
meandata = squeeze((data(:, :, subject)));
    for x = 1:2900
        VMdl = fitclinear(meandata(:,x)',labels,'ObservationsIn','columns','KFold',5,...
        'Learner','logistic','Solver','sparsa','Regularization','lasso');
        ce(subject, x) = kfoldLoss(VMdl);
        if round(x./100) == x./100, fprintf(num2str(x)), end
    end
    subject
end